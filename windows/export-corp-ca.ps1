<#
.SYNOPSIS
    Export the corporate TLS-inspection root CA (and intermediates) from the Windows
    certificate stores to PEM files that WSL can import. No admin needed.

.DESCRIPTION
    Walks the Root and CA (intermediate) stores of both LocalMachine and CurrentUser,
    picks every certificate whose Subject or Issuer matches -Filter (a regex, case
    insensitive), and writes each one as a Base64 PEM file into -OutDir
    (default %USERPROFILE%\corp-ca). Prints the WSL path to use afterwards.

    Public roots never match the default filter, so nothing extra gets trusted.

.EXAMPLE
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
    .\export-corp-ca.ps1                         # default filter: Zscaler|Corporate|Proxy
    .\export-corp-ca.ps1 -Filter 'Zscaler|Contoso'  # your company's CA name
    .\export-corp-ca.ps1 -ListAll                # list every root so you can find the name
    .\export-corp-ca.ps1 -Probe github.com       # show the chain the proxy presents right now

.NOTES
    Not sure what to filter on? Run -Probe github.com. The top of the chain is the
    proxy's root CA; the issuers above the leaf are its intermediates. Put a word from
    those names into -Filter. Alternatively open https://github.com in Edge, click the
    padlock, "Connection is secure", then the certificate icon, and read the chain.
#>
[CmdletBinding()]
param(
    [string]$Filter = 'Zscaler|Corporate|Proxy',
    [string]$OutDir = (Join-Path $env:USERPROFILE 'corp-ca'),
    [switch]$ListAll,
    [string]$Probe
)

$ErrorActionPreference = 'Stop'

$Stores = @(
    'Cert:\LocalMachine\Root',
    'Cert:\CurrentUser\Root',
    'Cert:\LocalMachine\CA',
    'Cert:\CurrentUser\CA'
)

function Get-CommonName([string]$DistinguishedName) {
    if ($DistinguishedName -match 'CN=([^,]+)') { return $matches[1].Trim() }
    return $DistinguishedName
}

function ConvertTo-WslPath([string]$WindowsPath) {
    $p = $WindowsPath -replace '\\', '/'
    if ($p -match '^([A-Za-z]):/(.*)$') {
        return ('/mnt/{0}/{1}' -f $matches[1].ToLower(), $matches[2])
    }
    return $p
}

function ConvertTo-Pem([System.Security.Cryptography.X509Certificates.X509Certificate2]$Cert) {
    $b64 = [Convert]::ToBase64String($Cert.RawData, 'InsertLineBreaks')
    $b64 = $b64 -replace "`r`n", "`n"
    return "-----BEGIN CERTIFICATE-----`n" + $b64 + "`n-----END CERTIFICATE-----`n"
}

function Show-ChainFor([string]$HostName) {
    # Opens a TLS connection without validation and prints the chain we were given.
    # Behind an explicit proxy (no direct port 443) this fails; use the browser instead.
    $tcp = $null
    $ssl = $null
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient($HostName, 443)
        $accept = [System.Net.Security.RemoteCertificateValidationCallback] { param($s, $c, $ch, $e) $true }
        $ssl = New-Object System.Net.Security.SslStream($tcp.GetStream(), $false, $accept)
        $ssl.AuthenticateAsClient($HostName)
        $leaf = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($ssl.RemoteCertificate)
        $chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
        $null = $chain.Build($leaf)
        Write-Host ""
        Write-Host "Certificate chain presented for ${HostName}:" -ForegroundColor Cyan
        $i = 0
        foreach ($el in $chain.ChainElements) {
            Write-Host ("  [{0}] subject: {1}" -f $i, $el.Certificate.Subject)
            Write-Host ("      issuer : {0}" -f $el.Certificate.Issuer)
            $i++
        }
        Write-Host ""
        Write-Host "If the issuers are not a public CA (DigiCert, Sectigo, Let's Encrypt, ...), that is the proxy."
        Write-Host "Use a word from its name as -Filter."
    }
    finally {
        if ($ssl) { $ssl.Dispose() }
        if ($tcp) { $tcp.Dispose() }
    }
}

# --- modes -----------------------------------------------------------------

if ($Probe) {
    Show-ChainFor $Probe
    exit 0
}

if ($ListAll) {
    Write-Host "All certificates in the root and intermediate stores (subject CN, store, expiry):" -ForegroundColor Cyan
    $all = foreach ($store in $Stores) {
        Get-ChildItem -Path $store -ErrorAction SilentlyContinue | ForEach-Object {
            [pscustomobject]@{
                Subject  = Get-CommonName $_.Subject
                Issuer   = Get-CommonName $_.Issuer
                Store    = ($store -replace '^Cert:\\', '')
                NotAfter = $_.NotAfter.ToString('yyyy-MM-dd')
            }
        }
    }
    $all | Sort-Object Subject | Format-Table -AutoSize | Out-String -Width 200 | Write-Host
    exit 0
}

# --- export ----------------------------------------------------------------

Write-Host "Filter : $Filter" -ForegroundColor Cyan
Write-Host "Output : $OutDir" -ForegroundColor Cyan

if (-not (Test-Path -LiteralPath $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir | Out-Null
    Write-Host "created $OutDir"
}

$seen = @{}
$exported = @()

foreach ($store in $Stores) {
    $certs = Get-ChildItem -Path $store -ErrorAction SilentlyContinue |
        Where-Object { ($_.Subject -match $Filter) -or ($_.Issuer -match $Filter) }

    foreach ($cert in $certs) {
        if ($seen.ContainsKey($cert.Thumbprint)) { continue }
        $seen[$cert.Thumbprint] = $true

        $cn = Get-CommonName $cert.Subject
        $safe = ($cn -replace '[^A-Za-z0-9._-]+', '-').Trim('-')
        if (-not $safe) { $safe = 'cert' }
        $file = Join-Path $OutDir ("{0}-{1}.pem" -f $safe, $cert.Thumbprint.Substring(0, 8).ToLower())

        $pem = ConvertTo-Pem $cert
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        $existing = ''
        if (Test-Path -LiteralPath $file) { $existing = [IO.File]::ReadAllText($file) }
        if ($existing -eq $pem) {
            $action = 'unchanged'
        }
        else {
            [IO.File]::WriteAllText($file, $pem, $utf8NoBom)
            $action = 'written'
        }

        $exported += [pscustomobject]@{
            Subject  = $cn
            Issuer   = Get-CommonName $cert.Issuer
            Store    = ($store -replace '^Cert:\\', '')
            NotAfter = $cert.NotAfter.ToString('yyyy-MM-dd')
            File     = Split-Path -Leaf $file
            Action   = $action
        }
    }
}

if ($exported.Count -eq 0) {
    Write-Host ""
    Write-Host "No certificate matched '$Filter'." -ForegroundColor Yellow
    Write-Host "Find the right name with:  .\export-corp-ca.ps1 -Probe github.com   or   .\export-corp-ca.ps1 -ListAll"
    Write-Host "Then re-run with:          .\export-corp-ca.ps1 -Filter '<word from the CA name>'"
    exit 2
}

$exported | Format-Table -AutoSize | Out-String -Width 200 | Write-Host

$wslPath = ConvertTo-WslPath $OutDir
Write-Host "Exported $($exported.Count) certificate(s) to $OutDir" -ForegroundColor Green
Write-Host ""
Write-Host "Inside WSL this folder is:  $wslPath/"
Write-Host "Next, inside WSL:           bash ~/src/devbox/wsl/install-corp-ca.sh $wslPath"
