<#
.SYNOPSIS
    ADMIN step: enable WSL 2 and install Ubuntu 22.04.

.DESCRIPTION
    Tries the modern one-liner (wsl --install) first. If wsl.exe is missing or the
    one-liner fails, falls back to enabling the two Windows features by hand with
    DISM. Then sets WSL 2 as the default and updates the WSL kernel/runtime.
    A reboot is needed after enabling the features. Safe to re-run.

    If you have no local admin, do not run this. Send the IT message from README.md.

.EXAMPLE
    Open PowerShell as administrator (Win+X, "Terminal (Admin)"), then:
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
    .\wsl-enable.ps1
    .\wsl-enable.ps1 -WebDownload    # when the Microsoft Store is blocked
    .\wsl-enable.ps1 -FeaturesOnly   # only enable the Windows features, nothing else

.NOTES
    When company policy gets in the way:
    - "Virtual Machine Platform" greyed out or failing: virtualization is disabled in
      the BIOS or blocked by policy (Intune/Group Policy). Only IT can change that.
    - Microsoft Store blocked: use -WebDownload. wsl --install then fetches WSL and the
      distro from GitHub/Microsoft servers instead of the Store.
    - Both blocked: install WSL from the MSI at https://github.com/microsoft/WSL/releases
      and import an Ubuntu root filesystem by hand:
        $tar = "$env:USERPROFILE\Downloads\ubuntu-jammy-wsl-amd64-wsl.rootfs.tar.gz"
        (download from https://cloud-images.ubuntu.com/wsl/jammy/current/)
        wsl --import Ubuntu-22.04 "$env:LOCALAPPDATA\WSL\Ubuntu-22.04" $tar --version 2
      An imported distro starts as root. Inside it: adduser <name>; usermod -aG sudo <name>;
      then put "[user]\ndefault=<name>" into /etc/wsl.conf and run wsl --shutdown.
    - Windows 10 needs build 19041 or newer for wsl --install.
#>
[CmdletBinding()]
param(
    [string]$Distro = 'Ubuntu-22.04',
    [switch]$WebDownload,
    [switch]$FeaturesOnly
)

$ErrorActionPreference = 'Continue'

function Write-Step([string]$Message) {
    Write-Host ""
    Write-Host ("==> " + $Message) -ForegroundColor Cyan
}

function Test-Elevated {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# --- preflight -------------------------------------------------------------

Write-Step "Preflight"
if (-not (Test-Elevated)) {
    Write-Host "This script needs an elevated PowerShell (Run as administrator)." -ForegroundColor Red
    Write-Host "No local admin? Send the IT message in README.md instead."
    exit 1
}

$build = [Environment]::OSVersion.Version.Build
Write-Host "Windows build: $build"
if ($build -lt 19041) {
    Write-Host "wsl --install needs Windows 10 build 19041 or newer. Ask IT for an OS update." -ForegroundColor Yellow
}

$features = @('Microsoft-Windows-Subsystem-Linux', 'VirtualMachinePlatform')
$rebootNeeded = $false
foreach ($f in $features) {
    $state = (Get-WindowsOptionalFeature -Online -FeatureName $f -ErrorAction SilentlyContinue).State
    Write-Host ("{0,-40} {1}" -f $f, $state)
}

# --- path A: modern one-liner ---------------------------------------------

$usedModernPath = $false
$wsl = Get-Command wsl.exe -ErrorAction SilentlyContinue
if ($wsl -and -not $FeaturesOnly) {
    Write-Step "wsl --install -d $Distro --no-launch"
    $installArgs = @('--install', '-d', $Distro, '--no-launch')
    if ($WebDownload) { $installArgs += '--web-download' }
    & wsl.exe @installArgs
    if ($LASTEXITCODE -eq 0) {
        $usedModernPath = $true
        Write-Host "wsl --install succeeded. If it enabled features, it will ask for a reboot."
    }
    else {
        Write-Host "wsl --install returned $LASTEXITCODE. Falling back to DISM." -ForegroundColor Yellow
    }
}

# --- path B: manual feature enablement -------------------------------------

if (-not $usedModernPath) {
    Write-Step "Enabling Windows features with DISM"
    foreach ($f in $features) {
        $state = (Get-WindowsOptionalFeature -Online -FeatureName $f -ErrorAction SilentlyContinue).State
        if ($state -eq 'Enabled') {
            Write-Host "$f already enabled"
            continue
        }
        & dism.exe /online /enable-feature /featurename:$f /all /norestart
        if ($LASTEXITCODE -eq 3010 -or $LASTEXITCODE -eq 0) {
            $rebootNeeded = $true
        }
        else {
            Write-Host "dism failed for $f with $LASTEXITCODE. Try the PowerShell cmdlet:" -ForegroundColor Yellow
            Write-Host "  Enable-WindowsOptionalFeature -Online -FeatureName $f -All -NoRestart"
        }
    }
}

if ($FeaturesOnly) {
    Write-Host "Features done. Reboot, then run: wsl --update; wsl --set-default-version 2; wsl --install -d $Distro"
    exit 0
}

# --- common tail -----------------------------------------------------------

$wsl = Get-Command wsl.exe -ErrorAction SilentlyContinue
if ($wsl) {
    Write-Step "wsl --set-default-version 2"
    & wsl.exe --set-default-version 2

    Write-Step "wsl --update"
    $updateArgs = @('--update')
    if ($WebDownload) { $updateArgs += '--web-download' }
    & wsl.exe @updateArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Host "wsl --update failed ($LASTEXITCODE). If the Store is blocked, re-run with -WebDownload" -ForegroundColor Yellow
        Write-Host "or install the MSI from https://github.com/microsoft/WSL/releases"
    }

    Write-Step "Installed distributions"
    & wsl.exe --list --verbose
}

# --- next steps ------------------------------------------------------------

Write-Step "Next"
if ($rebootNeeded) {
    Write-Host "1. Reboot now (features were just enabled)." -ForegroundColor Yellow
    Write-Host "2. After the reboot: wsl --update ; wsl --install -d $Distro"
}
else {
    Write-Host "1. If wsl --install asked for a reboot, reboot now."
}
Write-Host "3. Start the distro and create your Linux user: wsl -d $Distro"
Write-Host "4. Continue in ..\wsl\README.md"
