<#
.SYNOPSIS
    Install the winget packages listed in winget-packages.json, user scope first.

.DESCRIPTION
    "winget import" cannot pass --scope, so this script reads the same JSON file
    and runs "winget install" per package with --scope user. If the package has no
    user-scope installer it retries without --scope (which may trigger a UAC prompt).
    Packages that are already installed are skipped. Packages that always need admin
    (Docker Desktop) are skipped unless -IncludeAdmin is given.

    Safe to re-run. Works on Windows PowerShell 5.1 and PowerShell 7.

.EXAMPLE
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
    .\install.ps1                  # core packages, user scope where possible
    .\install.ps1 -Optional        # also winget-packages-optional.json
    .\install.ps1 -IncludeAdmin    # also the admin-only packages (Docker Desktop)
    .\install.ps1 -DryRun          # only print what would happen
#>
[CmdletBinding()]
param(
    [switch]$Optional,
    [switch]$IncludeAdmin,
    [switch]$DryRun
)

# Native commands report failure through $LASTEXITCODE. Keep PowerShell from
# turning stderr noise into terminating errors (a Windows PowerShell 5.1 gotcha).
$ErrorActionPreference = 'Continue'

$Here = Split-Path -Parent $MyInvocation.MyCommand.Path

# Packages whose installer always needs elevation. Skipped unless -IncludeAdmin.
$AdminOnly = @('Docker.DockerDesktop')

# winget exit codes that mean "nothing to do".
$AlreadyInstalledCodes = @(-1978335189, -1978335135)

function Write-Step([string]$Message) {
    Write-Host ""
    Write-Host ("==> " + $Message) -ForegroundColor Cyan
}

function Get-PackageIds([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Package list not found: $Path"
    }
    $json = Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
    $ids = @()
    foreach ($source in $json.Sources) {
        foreach ($pkg in $source.Packages) {
            $ids += $pkg.PackageIdentifier
        }
    }
    return $ids
}

function Test-WingetInstalled([string]$Id) {
    # Exit code 0 means at least one installed package matched the exact id.
    $null = & winget list --id $Id -e --accept-source-agreements --disable-interactivity 2>&1
    return ($LASTEXITCODE -eq 0)
}

function Install-WingetPackage([string]$Id) {
    $common = @(
        '--id', $Id, '-e',
        '--accept-source-agreements',
        '--accept-package-agreements',
        '--disable-interactivity'
    )

    Write-Host "    winget install --scope user ..." -ForegroundColor DarkGray
    & winget install @common --scope user
    $code = $LASTEXITCODE
    if ($code -eq 0) { return 'installed (user scope)' }
    if ($AlreadyInstalledCodes -contains $code) { return 'already installed' }

    Write-Host "    user scope failed ($code), retrying with the default scope ..." -ForegroundColor DarkGray
    & winget install @common
    $code = $LASTEXITCODE
    if ($code -eq 0) { return 'installed (default scope)' }
    if ($AlreadyInstalledCodes -contains $code) { return 'already installed' }
    return "FAILED ($code)"
}

# --- preflight -------------------------------------------------------------

Write-Step "Checking winget"
$winget = Get-Command winget -ErrorAction SilentlyContinue
if (-not $winget) {
    Write-Host "winget is not available. See 'If winget is missing' in README.md." -ForegroundColor Red
    Write-Host "Short version: Microsoft Store > App Installer, or Add-AppxPackage on the msixbundle from https://aka.ms/getwinget"
    exit 1
}
& winget --version

# --- package list ----------------------------------------------------------

$lists = @((Join-Path $Here 'winget-packages.json'))
if ($Optional) {
    $lists += (Join-Path $Here 'winget-packages-optional.json')
}

$ids = @()
foreach ($list in $lists) {
    Write-Step "Reading $list"
    $ids += Get-PackageIds $list
}
$ids = $ids | Select-Object -Unique
Write-Host ("{0} packages to consider" -f $ids.Count)

# --- install loop ----------------------------------------------------------

$results = @()
foreach ($id in $ids) {
    Write-Step $id
    $status = ''

    if (($AdminOnly -contains $id) -and (-not $IncludeAdmin)) {
        $status = 'skipped (needs admin; use -IncludeAdmin)'
    }
    elseif (Test-WingetInstalled $id) {
        $status = 'already installed'
    }
    elseif ($DryRun) {
        $status = 'dry-run (would install)'
    }
    else {
        $status = Install-WingetPackage $id
    }

    Write-Host ("    -> " + $status)
    $results += [pscustomobject]@{ Package = $id; Status = $status }
}

# --- summary ---------------------------------------------------------------

Write-Step "Summary"
$results | Format-Table -AutoSize | Out-String | Write-Host

$failed = @($results | Where-Object { $_.Status -like 'FAILED*' })
if ($failed.Count -gt 0) {
    Write-Host ("{0} package(s) failed. Common causes: no user-scope installer and no admin rights," -f $failed.Count) -ForegroundColor Yellow
    Write-Host "or the proxy blocking the download. See the admin table in README.md for the no-admin alternatives." -ForegroundColor Yellow
    exit 2
}
Write-Host "Done."
