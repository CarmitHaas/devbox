<#
.SYNOPSIS
  Installs the VS Code extensions listed in vscode-extensions.txt.
.DESCRIPTION
  Re-run safe: VS Code skips what is already installed. Extensions download through the
  Windows certificate store, so the corporate proxy is not a problem here.
  Extensions marked "remote" by VS Code (language servers, linters) must also be installed
  inside WSL: open a WSL window (Ctrl+Shift+P, "WSL: Connect to WSL"), open the Extensions
  view and press "Install in WSL" on the ones under "Local - Installed".
.PARAMETER DryRun
  Print what would be installed, change nothing.
.PARAMETER List
  Path to another list file.
#>
[CmdletBinding()]
param(
  [switch]$DryRun,
  [string]$List = (Join-Path $PSScriptRoot 'vscode-extensions.txt')
)
$ErrorActionPreference = 'Stop'
if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
  Write-Host 'code is not on the PATH. Install VS Code first (install.ps1), then open a new terminal.' -ForegroundColor Yellow
  exit 1
}
$ids = Get-Content $List | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') }
$have = @(code --list-extensions) | ForEach-Object { $_.ToLower() }
$results = foreach ($id in $ids) {
  if ($have -contains $id.ToLower()) { [pscustomobject]@{ Extension = $id; Result = 'present' }; continue }
  if ($DryRun) { [pscustomobject]@{ Extension = $id; Result = 'would install' }; continue }
  code --install-extension $id --force | Out-Null
  $ok = ($LASTEXITCODE -eq 0)
  [pscustomobject]@{ Extension = $id; Result = $(if ($ok) { 'installed' } else { 'FAILED' }) }
}
$results | Format-Table -AutoSize
