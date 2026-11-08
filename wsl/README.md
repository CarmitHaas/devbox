# WSL side: Ubuntu 22.04 inside a corporate Windows laptop

You are inside WSL once `wsl -d Ubuntu-22.04` opens and you have created your Linux
user. From here on it is Linux, with three corporate twists: the TLS-inspecting proxy,
VPN DNS, and the Windows file system next door.

Everything here runs as your user. `install-corp-ca.sh` and `bootstrap.sh` call `sudo`
for the system parts (you are the admin of your own distro, no IT needed).

## Order of operations

0. Get the repo into WSL without needing TLS yet. The Windows clone (or extracted ZIP) sits at `/mnt/c/Users/<you>/src/devbox`.
   `mkdir -p ~/src && git clone /mnt/c/Users/<you>/src/devbox ~/src/devbox` (local clone, no network)
1. Check the exported corporate CA is visible. `windows/export-corp-ca.ps1` wrote it on the Windows side.
   `ls /mnt/c/Users/<you>/corp-ca/`
2. Trust it in the distro and wire every CLI to it. Shows the certificates and asks before trusting.
   `bash ~/src/devbox/wsl/install-corp-ca.sh`
3. Check what the network lets through. CA-MISSING means step 2 did not take; BLOCKED goes into the IT message.
   `bash ~/src/devbox/wsl/proxy-check.sh`
4. Install the toolchain. `--minimal` gives apt basics, gh and Node only.
   `bash ~/src/devbox/wsl/bootstrap.sh` (or `bash ~/src/devbox/wsl/bootstrap.sh --minimal`)
5. Dotfiles: bashrc.d, readline, starship, tmux, gitconfig. Then start a new shell.
   `bash ~/src/devbox/wsl/install-dotfiles.sh --email you@company.tld && exec bash`
6. Sign in to GitHub and let gh handle git credentials.
   `gh auth login` then `gh auth setup-git`
7. Copilot CLI: see [`../copilot/`](../copilot/). `bootstrap.sh` already ran `npm i -g @github/copilot`; that folder owns login and usage.
8. Point the repo back at GitHub now that TLS works.
   `cd ~/src/devbox && git remote set-url origin https://github.com/CarmitHaas/devbox.git`

Re-run any script at any time. They skip what is already done.

## The proxy, in one paragraph

A TLS-inspecting proxy terminates every HTTPS connection and re-signs it with its own CA.
Windows trusts that CA because IT pushed it into the Windows certificate store. WSL has
its own trust store and knows nothing about it, so `curl`, `apt` over https, `pip`, `npm`,
`git`, `aws`, `gh`, `kubectl` and the VS Code server download all fail with
"certificate verify failed" or "self-signed certificate in certificate chain".
`install-corp-ca.sh` copies the CA into `/usr/local/share/ca-certificates/corp/`, runs
`update-ca-certificates`, and exports the environment variables each tool wants
(`NODE_EXTRA_CA_CERTS`, `REQUESTS_CA_BUNDLE`, `SSL_CERT_FILE`, `AWS_CA_BUNDLE`,
`CURL_CA_BUNDLE`, `GIT_SSL_CAINFO`, `PIP_CERT`) from `~/.bashrc.d/90-corp-ca.sh`. The
bundle path for anything else is `~/.config/corp-ca/bundle.pem`; the corporate certs
alone are in `~/.config/corp-ca/corp-only.pem` (Java keytool, Docker daemons).

Transparent vs explicit proxy: a transparent proxy (client agent on Windows) needs only
the CA. An explicit proxy (host:port or PAC) also needs `HTTPS_PROXY` and friends: copy
`dotfiles/bashrc.d/85-proxy.sh.example` to `~/.bashrc.d/85-proxy.sh`, fill it in, and
`bootstrap.sh` mirrors it into `/etc/apt/apt.conf.d/`.

## WSL configuration

### `/etc/wsl.conf` (inside the distro, needs `wsl --shutdown` from Windows to apply)

```ini
[boot]
systemd=true

[automount]
enabled=true
options="metadata,umask=22,fmask=11"

[interop]
enabled=true
appendWindowsPath=false

[network]
generateResolvConf=true

[user]
default=<your-linux-user>
```

- `systemd=true`: services work (`systemctl`), needed for Docker Engine inside WSL and
  for `snap`. Harmless otherwise.
- `appendWindowsPath=false`: the Windows PATH (dozens of directories on a slow 9P mount)
  stops being appended to the Linux PATH. Shell startup and every `command -v` gets
  faster, and no Windows `python.exe` or `node.exe` shadows the Linux one. The cost:
  `code`, `explorer.exe`, `clip.exe`, `wsl.exe` are not found by default. The dotfiles
  (`10-path.sh`) add back only `System32`, PowerShell and VS Code, at the end of PATH.
  Set it to `true` if you prefer the simple life.
- `options="metadata,..."`: lets Linux permissions and ownership stick on `/mnt/c`
  files, so `chmod 600 ~/.ssh/key` copied from Windows actually works. `umask=22,fmask=11`
  stops every Windows file from looking executable.
- Apply: `wsl --shutdown` in PowerShell, then reopen the terminal.

### `%USERPROFILE%\.wslconfig` (Windows side, applies to all distros)

```ini
[wsl2]
memory=8GB
processors=4
swap=2GB
localhostForwarding=true

# WSL 2.0+ (wsl --version shows 2.x). Windows 11 only for the networking keys.
autoMemoryReclaim=gradual
sparseVhd=true
networkingMode=mirrored
dnsTunneling=true
autoProxy=true
firewall=true
```

- `memory` defaults to 50% of RAM; WSL grabs it and gives it back slowly. Cap it.
- `networkingMode=mirrored` + `dnsTunneling=true` make WSL share the Windows network
  stack: VPN DNS, localhost in both directions and VPN split tunnels mostly just work.
  Windows 10 lacks both keys (WSL ignores unknown keys, so leaving them in is safe).
- `autoProxy=true` mirrors an explicit Windows proxy setting into WSL as `HTTP_PROXY`
  variables when the session starts. With a transparent proxy it does nothing.
- Apply: `wsl --shutdown`, wait 8 seconds, reopen.

### git line endings and where repos live

```bash
git config --global core.autocrlf input   # commit LF even if a Windows editor wrote CRLF
```

Keep clones in `~/src` (Linux file system), never under `/mnt/c`:

| Location | `git status` on a mid-size repo | Permissions | Antivirus | OneDrive |
|---|---|---|---|---|
| `~/src` (ext4 inside WSL) | milliseconds | real | not scanned by Windows | not synced |
| `/mnt/c/...` (9P to NTFS) | seconds | emulated via metadata | scanned on every read | synced if under Desktop/Documents |

Reach `~/src` from Windows (VS Code, Explorer, WinMerge) via `\\wsl$\Ubuntu-22.04\home\<you>\src`.
If you must work on a repo under `/mnt/c`, add it to `safe.directory` and set
`core.filemode false` in that repo.

### Docker Desktop and WSL

Docker Desktop (admin install, see `../windows/README.md`) runs the engine in its own
distro and exposes `docker` into yours when you flip the switch:
Settings > Resources > WSL integration > enable "Ubuntu-22.04" > Apply. Then
`docker run --rm hello-world` from your shell. Docker Desktop reads the Windows
certificate store, so the proxy CA is already trusted for pulls. For an explicit
proxy use Settings > Resources > Proxies.

No Docker Desktop? With `systemd=true`:

```bash
sudo apt-get install -y docker.io docker-compose-v2
sudo usermod -aG docker "$USER"   # then log out of WSL and back in
sudo cp ~/.config/corp-ca/corp-only.pem /usr/local/share/ca-certificates/corp/ 2>/dev/null; sudo update-ca-certificates
```

### VS Code from WSL

`code .` inside any WSL directory opens VS Code on Windows connected to WSL through the
Remote - WSL extension. The first run downloads the VS Code Server into
`~/.vscode-server` from `update.code.visualstudio.com` using the distro's trust store,
so run `install-corp-ca.sh` first. Extensions that run code (Python, Terraform,
Kubernetes) install "in WSL" and see Linux tools. Settings Sync keeps both sides equal.

### Time drift

After the laptop sleeps, the WSL clock can lag by hours, which breaks TLS, AWS signatures
and Kerberos. Fix:

```bash
sudo hwclock -s                         # one-off sync from the hardware clock
# or restart WSL from PowerShell:        wsl --shutdown
# with systemd on, this keeps it in sync: sudo systemctl enable --now systemd-timesyncd
```

The dotfiles define `wslfixtime` for the first line.

### DNS on VPN

Symptom: `curl: (6) Could not resolve host` inside WSL while Windows browses fine. The
VPN client rewrites the Windows DNS configuration and the WSL virtual network does not
follow. Try in this order:

1. Windows 11 with WSL 2.0+: set `networkingMode=mirrored` and `dnsTunneling=true` in
   `.wslconfig` (above), `wsl --shutdown`, reopen. This fixes most VPN cases.

2. Static `resolv.conf` with the Windows DNS servers. Find them while connected to VPN,
   in PowerShell:
   `Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object ServerAddresses`
   (`proxy-check.sh` also prints them). Then inside WSL:

   ```bash
   sudo tee -a /etc/wsl.conf >/dev/null <<'EOF'
   [network]
   generateResolvConf=false
   EOF
   ```
   Run `wsl --shutdown` from PowerShell, reopen, then:
   ```bash
   sudo rm -f /etc/resolv.conf              # it was a symlink to the generated file
   sudo tee /etc/resolv.conf >/dev/null <<'EOF'
   nameserver 10.x.x.x                      # first corporate DNS from the PowerShell output
   nameserver 10.x.x.y                      # second
   search corp.example.internal             # the search suffix from "ipconfig /all"
   EOF
   sudo chattr +i /etc/resolv.conf          # optional: stop anything rewriting it
   ```
   Off VPN those servers may be unreachable; add a public resolver as a third line if
   the proxy allows it, or keep two resolv.conf variants and `cp` the right one.

3. Adapter metrics (needs admin on Windows). Some VPN clients give their adapter a
   lower route metric than the WSL virtual switch, so WSL traffic never reaches the VPN
   DNS. In an elevated PowerShell, find the VPN adapter name with `Get-NetAdapter`, then:
   `Get-NetIPInterface -InterfaceAlias "<vpn adapter>" | Set-NetIPInterface -InterfaceMetric 6000`
   This resets at reconnect for some clients; a scheduled task on the VPN connect event fixes that.

4. MTU. VPN tunnels often carry a smaller MTU; TLS handshakes then hang after DNS works.
   `sudo ip link set dev eth0 mtu 1350` inside WSL (temporary) tells you if that is it.

## Files in this folder

| File | What it does |
|---|---|
| `install-corp-ca.sh` | trust the proxy CA in the distro, wire npm/pip/git and the CA env vars, verify |
| `proxy-check.sh` | reachability and TLS table for every host the toolchain uses, plus proxy env and DNS |
| `bootstrap.sh` | apt basics, gh, Node 22 + Copilot CLI, kubectl, helm, terraform, terragrunt, aws, k9s, kubectx, yq, zoxide, starship, uv (`--minimal`, `--extras`) |
| `install-dotfiles.sh` | copies `dotfiles/` into `$HOME` with backups; adds one sourcing block to `~/.bashrc` |
| `dotfiles/bashrc.d/` | `10-path`, `20-aliases`, `30-history`, `40-tools`, `50-wsl`, `60-git`, `85-proxy.sh.example` |
| `dotfiles/inputrc`, `starship.toml`, `tmux.conf`, `gitconfig.template` | readline, prompt, tmux, git |
| `tools-versions.md` | how to update each tool later |
