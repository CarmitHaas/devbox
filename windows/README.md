# Windows side: day one on a corporate laptop

Target: a corporate Windows 10/11 laptop behind a web proxy that does TLS inspection
(Zscaler-style). You may or may not have local admin. Everything here has a no-admin
path where one exists. Steps that need admin are marked ADMIN.

Order matters: the corporate root CA must be exported before anything inside WSL can
download. The WSL side continues in [`../wsl/README.md`](../wsl/README.md).

## Order of operations

Open PowerShell (Win+X, then "Terminal" or "Windows PowerShell"). Each step is one line
plus the command to run.

1. Find out whether you can elevate. No output means no local admin.
   `whoami /groups | findstr /c:"S-1-5-32-544"`
2. Check that winget works. If it is missing, see "If winget is missing" below.
   `winget --version`
3. Allow scripts for this PowerShell window only (nothing persists).
   `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`
4. Get this repo into `%USERPROFILE%\src\devbox`. No git yet? In the browser open https://github.com/CarmitHaas/devbox, Code > Download ZIP, extract to `%USERPROFILE%\src\devbox` (the browser trusts the proxy, so this always works). With git, note that Git for Windows needs the Windows cert store (`schannel`) to get through the proxy.
   `mkdir $env:USERPROFILE\src; git -c http.sslBackend=schannel clone https://github.com/CarmitHaas/devbox.git $env:USERPROFILE\src\devbox`
5. Install the core tools with winget, user scope first. Re-run safe. Prints a summary table.
   `cd $env:USERPROFILE\src\devbox\windows; .\install.ps1`
6. See which CA the proxy injects into TLS, then export it to `%USERPROFILE%\corp-ca\`.
   `.\export-corp-ca.ps1 -Probe github.com; .\export-corp-ca.ps1`
7. ADMIN: enable WSL 2 and install Ubuntu 22.04. Reboot after. If you cannot elevate, send the IT message below and continue with steps 10 to 14 meanwhile.
   `.\wsl-enable.ps1`
8. After the reboot, start Ubuntu once and create your Linux user (lowercase, short, no spaces).
   `wsl -d Ubuntu-22.04`
9. Cap WSL memory and turn on the networking options that make VPN life easier (Windows 11). Then restart WSL.
   `notepad $env:USERPROFILE\.wslconfig` (paste the block from `../wsl/README.md`), then `wsl --shutdown`
10. Windows Terminal: default profile Ubuntu, font, copy on select. Details in `terminal-settings.md`.
    `wt` then `Ctrl+,`
11. VS Code: the extensions in `vscode-extensions.txt` (WSL, Copilot, Terraform, YAML, Kubernetes, Jenkinsfile, GitHub Actions, shell, draw.io), then merge `vscode-settings.json` into your user settings (default terminal = WSL, LF line endings). Extensions go through the proxy fine because VS Code uses the Windows cert store. Linter credentials (for example a Jenkins pipeline linter user) are typed into user settings by hand and never committed anywhere.
    `.\install-vscode-extensions.ps1 -DryRun; .\install-vscode-extensions.ps1`
12. ADMIN: Docker Desktop, then Settings > Resources > WSL integration > enable for Ubuntu-22.04. No admin or no licence? Docker Engine inside WSL works without it: `sudo apt-get install -y docker.io docker-compose-v2 && sudo usermod -aG docker $USER` (needs `systemd=true` in `/etc/wsl.conf`, see `../wsl/README.md`).
    `.\install.ps1 -IncludeAdmin`
13. PowerToys: turn on Run (Alt+Space), FancyZones, PowerRename, File Locksmith, Text Extractor, Paste as Plain Text. Everything else off.
    Start PowerToys, then Settings (gear in the tray icon)
14. Browser: create a dedicated work profile and pin its shortcut. Keep personal accounts out of it. Sign in to the company identity provider and the VPN client as IT instructs.
    Chrome: profile icon > Add. Edge: profile icon > Add profile
15. Continue inside WSL.
    `wsl -d Ubuntu-22.04` then follow `../wsl/README.md`

## Admin vs no-admin

| Task | Admin needed | No-admin path |
|---|---|---|
| winget packages (PowerToys, Terminal, VS Code, Everything, Notepad++, WinMerge, ShareX, draw.io, Obsidian) | No | `install.ps1` uses `--scope user` |
| Git for Windows (`Git.Git`) | Usually (machine MSI) | `winget install --id Git.MinGit -e` (portable), or use git inside WSL only |
| 7-Zip, PowerShell 7 (MSI installers) | Yes | Windows has `tar` and zip built in. PowerShell 7 per-user from the Store: `winget install --id 9MZ1SNWT0N5D -s msstore` |
| WSL features (Windows Subsystem for Linux, Virtual Machine Platform) | Yes | None. Ask IT once (message below) |
| Docker Desktop | Yes (install, plus `docker-users` group) | Docker Engine inside WSL with systemd (`sudo apt install docker.io`), or Podman |
| Fonts (JetBrains Mono) | No | Right-click the `.ttf` files > Install (installs for the current user) |
| User environment variables | No | `rundll32 sysdm.cpl,EditEnvironmentVariables` |
| Trusting the corporate CA inside WSL | No (you are root inside WSL) | `../wsl/install-corp-ca.sh` |
| Windows `hosts` file | Yes | Use `/etc/hosts` inside WSL for WSL-side names |
| Long paths (`LongPathsEnabled`) | Yes | Keep repos in WSL `~/src`, never under OneDrive |
| VPN adapter metric fix for WSL DNS | Yes | `networkingMode=mirrored` in `.wslconfig` (Windows 11, no admin) |
| Developer Mode, symlinks on NTFS | Yes | Work inside WSL where symlinks just work |

## If winget is missing

winget ships as "App Installer". Try one of these, no admin needed:

1. Microsoft Store > search "App Installer" > Update or Install.
2. If the Store is blocked: download `Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle` from `https://aka.ms/getwinget` in the browser, then
   `Add-AppxPackage -Path "$env:USERPROFILE\Downloads\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"`
3. If `Add-AppxPackage` is blocked by policy, winget is off the table. Install each tool from its vendor site (user-mode installers for VS Code, PowerToys, Windows Terminal all exist) and ask IT to allow App Installer.

## What to ask IT (one message)

Send this once, early, so the admin pieces land together.

```
Subject: Dev laptop setup: WSL 2, Docker Desktop, proxy CA

Hi, I need a few things for my DevOps work on the new laptop:

1. Local admin, or alternatively someone to run these two once and reboot:
   - Enable Windows features "Windows Subsystem for Linux" and "Virtual Machine Platform"
     (wsl --install -d Ubuntu-22.04), and make sure virtualization is on in the BIOS
     and not blocked by policy.
   - Install Docker Desktop (WSL 2 backend) and add me to the local "docker-users" group.
     If the company needs a Docker Desktop license seat, please assign one to me.

2. The web proxy / TLS inspection root CA certificate as a .cer or .pem file (the
   certificate the proxy uses to re-sign HTTPS). I need to trust it inside WSL,
   where the Windows certificate store is not visible.

3. Proxy details for command-line tools inside WSL: is the proxy transparent
   (no configuration needed) or explicit (host:port or PAC URL, and whether it
   needs authentication)?

4. Please confirm these domains are reachable from the laptop, since all my tooling
   installs from them: github.com, api.github.com, raw.githubusercontent.com,
   objects.githubusercontent.com, registry.npmjs.org, pypi.org, files.pythonhosted.org,
   archive.ubuntu.com, security.ubuntu.com, pkgs.k8s.io, dl.k8s.io, get.helm.sh,
   apt.releases.hashicorp.com, releases.hashicorp.com, awscli.amazonaws.com,
   registry-1.docker.io, auth.docker.io, ghcr.io, update.code.visualstudio.com,
   marketplace.visualstudio.com, copilot-proxy.githubusercontent.com.

5. Confirm that winget (App Installer) and Node.js/npm are allowed. GitHub Copilot CLI
   is installed through npm.

6. When on VPN, DNS inside WSL sometimes breaks. If there is a known fix for our VPN
   client (DNS server IPs or a networking mode), please point me to it.

Thanks.
```

## Files in this folder

| File | What it does |
|---|---|
| `install.ps1` | winget installs from the JSON lists, user scope first, summary table |
| `install-vscode-extensions.ps1`, `vscode-extensions.txt` | VS Code extensions from the list; `-DryRun` |
| `vscode-settings.json` | user-settings keys to merge: WSL as default terminal, LF, 2-space YAML and Terraform |
| `winget-packages.json` | core package list (`winget import` compatible) |
| `winget-packages-optional.json` | optional packages (browsers) |
| `wsl-enable.ps1` | ADMIN: enable WSL 2, install Ubuntu 22.04, with the manual fallback |
| `export-corp-ca.ps1` | export the proxy root CA from the Windows store to PEM files for WSL |
| `terminal-settings.md` | Windows Terminal settings and a `settings.json` fragment |
| `windows-cheatsheet.md` | Linux-to-Windows muscle memory |
