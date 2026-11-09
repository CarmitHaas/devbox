# devbox

My workstation kit for a corporate Windows laptop with WSL, written for the day I move from an
Ubuntu + Claude Code setup to Windows + GitHub Copilot. Generic by design: no client content,
no secrets. Fork it, replace the name in `wsl/dotfiles/gitconfig.template`, and it is yours.

## Get it onto a new machine

No git yet? In the browser: **Code → Download ZIP**, extract to `Documents\devbox`.
With git: `git clone https://github.com/CarmitHaas/devbox.git`

## Order of operations

| Step | Where | Why |
|---|---|---|
| 1 | `windows/README.md` | Windows-side tools (user scope where possible), Terminal, PowerToys, the admin asks in one message |
| 2 | `windows/export-corp-ca.ps1` | Export the corporate TLS-inspection root CA so WSL tools can trust it |
| 3 | `wsl/README.md` | Inside Ubuntu: `install-corp-ca.sh` → `proxy-check.sh` → `bootstrap.sh` → `install-dotfiles.sh` |
| 4 | `copilot/README.md` | Personal Copilot instructions + skills; `first-session.md` is a 15-minute test drive |
| 5 | `cheatsheets/` | Windows muscle memory, Jira + JQL, Confluence, Teams/Outlook, git on Windows |

## Layout

```
windows/    install.ps1, install-vscode-extensions.ps1, vscode-extensions.txt, vscode-settings.json, winget-packages*.json, wsl-enable.ps1, export-corp-ca.ps1, terminal-settings.md, windows-cheatsheet.md
wsl/        bootstrap.sh, install-corp-ca.sh, proxy-check.sh, install-dotfiles.sh, transcribe.sh, dotfiles/, tools-versions.md
copilot/    copilot-instructions.md, skills/<name>/SKILL.md (18), install.sh, claude-code-to-copilot.md, first-session.md
cheatsheets/ jira.md, confluence.md, teams-outlook.md, git-on-windows.md
```

## Rules for this repo

- Nothing client-specific, ever: no hostnames, people, project keys, tickets, incidents.
- No secrets, not even placeholders that look like values. Templates use `<work-email>` style markers.
- Scripts are idempotent, print what they do, and pass `shellcheck`.
- Plain English, short sentences.

Licensed MIT.
