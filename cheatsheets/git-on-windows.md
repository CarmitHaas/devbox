# Git on a Windows laptop (WSL first)

Generic notes for working from WSL (Ubuntu) on a corporate Windows machine, with Git for Windows also installed. Hostnames and org names are placeholders.

## The one rule

Work inside WSL on the Linux filesystem (`~/src`), not under `/mnt/c`. Everything below gets simpler when you do.

## Line endings

| Where | Setting | Why |
|---|---|---|
| WSL | `git config --global core.autocrlf input` | Convert CRLF to LF on commit, never touch files on checkout |
| Git for Windows | leave the installer default (`core.autocrlf true`) or set `false` | Only matters for repos cloned from Windows |
| Every repo | `.gitattributes` (below) | Repo rules beat personal config, so the whole team gets the same bytes |

Starter `.gitattributes`:

```
* text=auto eol=lf
*.sh        text eol=lf
Jenkinsfile text eol=lf
*.groovy    text eol=lf
Makefile    text eol=lf
*.ps1       text eol=crlf
*.bat       text eol=crlf
*.cmd       text eol=crlf
*.png *.jpg *.gif *.pdf *.zip *.jar binary
```

1. After adding or changing it: `git add --renormalize . && git commit -m "Normalize line endings"`.
2. Symptom of CRLF in a shell script: `$'\r': command not found` or `bad interpreter: /bin/bash^M`. Fix one file with `sed -i 's/\r$//' file` or `dos2unix file`.
3. Inspect: `git ls-files --eol | grep crlf` shows what is stored with CRLF. `file script.sh` says "with CRLF line terminators".
4. Jenkinsfile and anything executed by Linux agents must be LF. PowerShell and batch files must be CRLF or Windows mangles multi-line strings.
5. Editors: VS Code bottom bar shows `LF` or `CRLF`; set `"files.eol": "\n"` in settings for WSL work.

## File mode noise on /mnt/c

1. Files on `/mnt/c` show as `0777` or `0755`, so Git sees every file as `mode change 100644 -> 100755`.
2. Per repo: `git config core.fileMode false`. Global if you must: `git config --global core.fileMode false` (then `chmod +x` changes are also ignored, so set the bit with `git update-index --chmod=+x script.sh`).
3. Better: mount with metadata in `/etc/wsl.conf`, then `wsl --shutdown` from PowerShell:

```
[automount]
options = "metadata,umask=22,fmask=11"
```

## Credentials: why there are two logins

Windows and WSL are two operating systems with two Git installs and two credential stores. You authenticate once on each side you actually use.

| Side | Do once | What it does |
|---|---|---|
| WSL | `gh auth login` then `gh auth setup-git` | Browser login, then Git uses `gh` as credential helper for HTTPS |
| WSL alternative | `git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"` | Reuse the Windows Git Credential Manager store from WSL. Path is `ucrt64` on Git for Windows 2.56 and newer |
| Windows | Git for Windows installs Git Credential Manager (GCM) | Browser login on first push; stored in Windows Credential Manager |
| Either | WSL: `gh auth logout`. Windows: Control Panel > Credential Manager > remove `git:https://github.com` | Reset when a token is revoked or SSO expires |

Check what is configured: `git config --global --get-all credential.helper`.

## SSH keys: keep one, in WSL

1. Generate once: `ssh-keygen -t ed25519 -C "work-laptop"`. Upload the `.pub` to GitHub > Settings > SSH and GPG keys.
2. Agent per shell session: `eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519`. Add it to `~/.bashrc` guarded by a check, or install `keychain` (`eval $(keychain --eval id_ed25519)`).
3. Test: `ssh -T git@github.com`. Expect "Hi <user>! You've successfully authenticated".
4. If the org enforces SSO, authorize the key: GitHub > Settings > SSH and GPG keys > Configure SSO next to the key. Without that, pushes to org repos fail with "SAML SSO required".
5. 1Password or another agent (if allowed): Windows-side agent plus the WSL bridge the vendor documents. Only worth it if the company already uses the tool.
6. Do not copy private keys between Windows and WSL. One key, one place, one revocation.

## Case sensitivity

1. NTFS is case-insensitive; ext4 inside WSL is case-sensitive. A repo with `README.md` and `readme.md` checks out fine in WSL and breaks on Windows.
2. Git for Windows sets `core.ignorecase true`. A rename that only changes case needs two steps on Windows: `git mv Foo.tf tmp && git mv tmp foo.tf`. In WSL `git mv Foo.tf foo.tf` just works.
3. Terraform and Kubernetes manifests reference files by name; keep everything lowercase and avoid the problem.

## Long paths

1. Windows limits paths to 260 characters. Deep `node_modules`, Helm charts and Terraform `.terraform` folders hit it.
2. In Git for Windows: `git config --system core.longpaths true` (run as admin). Also enable the Windows setting: `Computer Configuration > Administrative Templates > System > Filesystem > Enable Win32 long paths` or the registry key `LongPathsEnabled=1` (may need IT).
3. WSL has no such limit on ext4. Another reason to clone there.

## Performance

1. `/mnt/c` goes through a 9P bridge. `git status` on a large repo takes seconds there and milliseconds on ext4.
2. Clone to `~/src/<repo>`. Open from Windows with VS Code Remote WSL, or browse `\\wsl.localhost\Ubuntu\home\<user>\src`.
3. Windows Defender scans every file Git touches on `/mnt/c`. Ask IT for an exclusion only if you truly must work there.
4. `git config --global core.fsmonitor true` and `core.untrackedCache true` help big repos on either side.

## Symlinks

1. Git for Windows defaults to `core.symlinks false`: symlinks become plain text files containing the target path. Scripts that follow them break.
2. Creating real symlinks on Windows needs Developer Mode or admin rights. In WSL on ext4 they are normal Linux symlinks.
3. Repos that rely on symlinks (Helm chart aliases, shared `.github` folders): work on them only in WSL.

## Global config sanity list

Run `git config --global --list` in WSL and expect roughly this:

```
user.name=First Last
user.email=first.last@example.com
core.autocrlf=input
core.editor=code --wait
init.defaultbranch=main
pull.rebase=true
push.autosetupremote=true
fetch.prune=true
rerere.enabled=true
credential.https://github.com.helper=!/usr/bin/gh auth git-credential
```

Missing `user.email` matching your GitHub verified address means commits show as unlinked and may be rejected by branch rules that require verified authors.

## GitHub Enterprise Cloud specifics

1. GitHub Enterprise Cloud lives on `github.com`. `gh auth login` with no flags is right. Use `gh auth login --hostname <host>` only for GitHub Enterprise Server or a data-residency enterprise on `ghe.com`.
2. SAML or OIDC SSO on the org: classic personal access tokens must be authorized per org (token > Configure SSO > Authorize). Until then API calls return 403 "Resource protected by organization SAML enforcement".
3. Fine-grained tokens: pick the org as resource owner, pick repos and permissions, set an expiry. The org may require approval of each token (if enabled). Prefer them for scripts; they expire and are scoped.
4. SSH keys need the same per-org SSO authorization as classic tokens (see SSH section).
5. Enterprise Managed Users (if the enterprise uses them): your login is `<handle>_<shortcode>`, created by the IdP. You cannot use a personal GitHub account, and public repos and gists are blocked.
6. Session expiry: SSO sessions last hours to days. "Permission denied" after a long weekend usually means re-authorize in the browser, not a broken key.
7. `gh` stores its token under `~/.config/gh/hosts.yml` in WSL. Never commit it. `gh auth status` shows which account and scopes are active.

## Commit signing (optional)

1. Only if the org requires verified commits or you want the badge. SSH signing is the least friction:

```
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
```

2. Add the same public key in GitHub as a "Signing key" (separate from the authentication key entry).
3. Test with one commit and `git log --show-signature -1`. If it complains about `gpg.ssh.allowedSignersFile`, create `~/.ssh/allowed_signers` with `<email> <public key>` and point `gpg.ssh.allowedSignersFile` at it.
