# Windows cheatsheet for a Linux person

Muscle memory map for someone who has run Ubuntu for years and now has to be productive
on a corporate Windows laptop. `Win` is the Super key. Everything below works on
Windows 11; most of it on Windows 10. Shortcuts that policy may block are marked.

## Reflexes that need rewiring

| Linux habit | Windows equivalent |
|---|---|
| `Ctrl+Alt+T` for a terminal | Pin Windows Terminal to the taskbar, then `Win+<its number>`, or ``Win+` `` (quake mode) |
| `Alt+F2` run dialog | `Win+R` (plain run) or `Alt+Space` (PowerToys Run) |
| Middle-click paste | Does not exist. Right-click pastes in Terminal |
| `Super` drag to move windows | Not available. Use `Win+Arrow` snapping or FancyZones |
| Workspaces | Virtual desktops: `Win+Ctrl+D` new, `Win+Ctrl+Left/Right` switch |
| Focus follows mouse | Not available |
| `xdg-open file` | `start file` (cmd) or `explorer.exe file` from WSL |
| `Ctrl+Alt+Del` | `Ctrl+Shift+Esc` goes straight to Task Manager |
| `/etc/environment` | User env vars UI: `rundll32 sysdm.cpl,EditEnvironmentVariables` |
| `~` | `%USERPROFILE%` (`C:\Users\<you>`), from WSL `/mnt/c/Users/<you>` |

## Windows and desktop management

| Keys | Action |
|---|---|
| `Win+Left` / `Win+Right` | Snap window to half; press again to cycle; `Win+Up` after a snap makes a quarter |
| `Win+Up` / `Win+Down` | Maximize / restore then minimize |
| `Win+Z` | Snap layouts picker (Win 11) |
| `Win+Shift+Left` / `Right` | Move window to the other monitor |
| `Alt+Tab` | Switch windows (hold Alt, use arrows) |
| `Alt+Esc` | Cycle windows in order without the overlay |
| `Win+Tab` | Task view: all windows plus virtual desktops |
| `Win+Ctrl+D` | New virtual desktop |
| `Win+Ctrl+Left` / `Right` | Switch virtual desktop |
| `Win+Ctrl+F4` | Close current virtual desktop |
| `Win+1..9` | Launch or focus the Nth pinned taskbar app; `Win+Shift+N` opens a new instance |
| `Win+T` | Cycle through taskbar apps |
| `Win+D` | Show desktop (toggle) |
| `Win+M` / `Win+Shift+M` | Minimize all / restore |
| `Win+Home` | Minimize everything except the active window |
| `Win+,` | Peek at the desktop while held |
| `Win+L` | Lock. Do this every time you stand up |
| `Alt+F4` | Close window; on the desktop it opens the shutdown dialog |
| `Alt+Space` | Window menu (move, size, minimize). PowerToys Run takes this key when enabled |
| `Win+E` | File Explorer |
| `Win+I` | Settings |
| `Win+X` | Power user menu: Terminal (Admin), Device Manager, Settings |
| `Win+A` / `Win+N` | Quick settings (wifi, volume) / notifications |
| `Win+P` | Display projection mode (duplicate, extend) |
| `Win+K` | Cast to a wireless display |
| `Win+Pause` | System info (About) |
| `Win+Ctrl+Shift+B` | Restart the graphics driver (black screen rescue) |

## Clipboard history

| Keys | Action |
|---|---|
| `Win+V` | Clipboard history (enable on first use). Click an item to paste it, pin items to keep them |
| `Win+V` then `...` on an item | Pin / delete |
| Settings > System > Clipboard | Turn history on; sync across devices is usually blocked by policy |
| `Win+Ctrl+Alt+V` | PowerToys: paste as plain text |

## Screenshots and recording

| Keys | Action |
|---|---|
| `Win+Shift+S` | Snip toolbar: rectangle, window, full screen, freeform. Result goes to the clipboard and (Win 11) is auto-saved to `%USERPROFILE%\Pictures\Screenshots` |
| `PrtScn` | Copies the full screen. Settings > Accessibility > Keyboard can make it open the snip toolbar instead |
| `Alt+PrtScn` | Active window to clipboard |
| `Win+PrtScn` | Full screen saved to `Pictures\Screenshots` |
| Snipping Tool (`Win+Shift+S` then the notification, or search "Snipping Tool") | Delay: the timer icon offers 3, 5, 10 seconds. Recording: the video camera icon, select an area, Start. Recordings land in `Videos\Screen Recordings` |
| `Win+G` then `Win+Alt+R` | Xbox Game Bar screen recording, often blocked by policy |
| ShareX | Installed by `install.ps1`. Configure its hotkeys to avoid clashing with `Win+Shift+S` |
| `Win+Shift+T` | PowerToys Text Extractor: OCR any region on screen straight to the clipboard |

## Emoji, dictation, accents

| Keys | Action |
|---|---|
| `Win+.` or `Win+;` | Emoji, GIF, symbols and the clipboard panel |
| `Win+H` | Voice typing (dictation). Needs a microphone and may be blocked by policy |
| PowerToys Quick Accent | Hold a letter, press space, pick the accented form |

## Keyboard layouts (Hebrew and English)

| Keys / setting | Action |
|---|---|
| `Win+Space` | Cycle input languages, shows a list while held. Order is the list order in Settings |
| `Alt+Shift` (left side) | Classic toggle between input languages |
| `Ctrl+Shift` | Toggle keyboard layouts within one language (e.g. Hebrew Standard vs Hebrew legacy) |
| `Win+Ctrl+Space` | Switch back to the previously used input |
| Current layout | The `ENG` / `HEB` badge in the system tray; click it for the list |
| Fixed order | Settings > Time & language > Language & region: the language list order is the cycle order. Move the one you want first to the top |
| Per-app layout | Settings > Time & language > Typing > Advanced keyboard settings > "Let me use a different input method for each app window". With this on, each window remembers its own language |
| Change the hotkey | Same page > "Input language hot keys" (the old Control Panel dialog) |
| Hebrew Standard layout | Language & region > Hebrew > Language options > Add a keyboard > Hebrew (Standard). Removes the legacy layout confusion |
| Paragraph direction in Office | `Ctrl+Right Shift` makes the paragraph RTL, `Ctrl+Left Shift` makes it LTR (Word, Outlook, Teams) |
| Terminal and Hebrew | Terminals do not render RTL. Keep the Ubuntu profile in English and let Teams/Outlook hold the Hebrew |

## PowerToys

| Keys | Action |
|---|---|
| `Alt+Space` | PowerToys Run: type an app name, a path, a calculation (`=2^10`), a shell command (`>wsl --shutdown`), a file search (`?filename`) |
| ``Win+Shift+` `` | FancyZones editor: define zone layouts per monitor |
| `Shift` while dragging a window | Drop it into a FancyZone |
| `Win+Left` / `Win+Right` with "Override Windows Snap" on | Move the active window between zones instead of plain halves |
| Right-click files > PowerRename | Regex rename, with live preview and undo |
| Right-click file > Unlock with File Locksmith | Shows which process holds the file open and lets you kill it |
| `Win+Ctrl+T` | Always on Top: pin a window above everything |
| `Win+Shift+C` | Color Picker |
| `Win+Shift+T` | Text Extractor (OCR) |
| `Ctrl+Space` | Peek: preview the selected file in Explorer |
| Environment Variables | A real editor for user and system env vars (system part needs admin) |
| Awake | Keep the laptop awake through a long job without touching power policy |

## File Explorer

| Keys / action | Result |
|---|---|
| `Alt+D` or `Ctrl+L` | Focus the address bar. Type a path, `%APPDATA%`, `%LOCALAPPDATA%`, or `\\wsl$\Ubuntu-22.04\home\<user>` |
| Type `cmd`, `powershell` or `wt` in the address bar | Opens that shell in the current folder |
| `Ctrl+Shift+C` | Copy as path (quoted). Win 11 |
| `Shift+Right-click` | Full classic context menu (Win 11 hides it behind "Show more options") |
| Right-click > Open in Terminal | Windows Terminal in this folder (Win 11) |
| `Alt+Enter` | Properties |
| `Alt+Up` / `Alt+Left` / `Alt+Right` | Parent folder / back / forward |
| `F2` | Rename. `Tab` moves to the next file while renaming |
| `Ctrl+Shift+N` | New folder |
| `Shift+Delete` | Delete without the Recycle Bin |
| `Ctrl+Shift+E` | Expand the tree to the current folder |
| `Ctrl+Shift+6` | Details view; `Ctrl+Shift+1..8` for the other views |
| View > Show > File name extensions, Hidden items | Turn both on first thing |
| Drag a file onto a Terminal window | Pastes its Windows path (quoted) |
| Pin `\\wsl$\Ubuntu-22.04\home\<user>\src` to Quick Access | One click into your WSL repos from any Windows app |

### Mapping a network share

| Step | Detail |
|---|---|
| UI | This PC > three dots (or right-click This PC) > Map network drive > pick a letter > `\\server\share` > Reconnect at sign-in |
| Command | `net use Z: \\server\share /persistent:yes` |
| The credential prompt pitfall | The prompt defaults to your current Windows identity. If the share needs another one, click "More choices" > "Use a different account" and type the identity exactly: `DOMAIN\user` or `user@company.tld` for a domain account, `.\user` or `SERVER\user` for a local account on that server. Tick "Remember my credentials" |
| Wrong password saved | Control Panel > Credential Manager > Windows Credentials: edit or remove the entry for the server. Also `cmdkey /list` and `cmdkey /delete:server` |
| Drop a mapping | `net use Z: /delete`, or `net use * /delete` for all |
| From WSL | `sudo mkdir -p /mnt/z && sudo mount -t drvfs Z: /mnt/z` (after mapping in Windows) |
| Password changed | Delete the stale Credential Manager entry before you retry, or the account gets locked out |

## Windows Terminal

See `terminal-settings.md` for the setup. Daily keys:

| Keys | Action |
|---|---|
| `Ctrl+Shift+T` / `Ctrl+Shift+W` | New tab / close |
| `Ctrl+Tab` | Next tab |
| `Alt+Shift+D` | Split pane |
| `Alt+Arrow` | Move between panes |
| `Ctrl+Shift+F` | Search scrollback |
| `Ctrl+Shift+P` | Command palette |
| `Ctrl+Shift+C` / `Ctrl+Shift+V` | Copy / paste (plus right-click to paste) |
| ``Win+` `` | Quake-style drop-down terminal |

## Paths between Windows and WSL

| From | To | How |
|---|---|---|
| WSL | Windows drive | `/mnt/c/Users/<you>/Downloads` |
| Windows | WSL files | `\\wsl$\Ubuntu-22.04\home\<you>` (also `\\wsl.localhost\Ubuntu-22.04\...` on Win 11) |
| WSL shell | Convert a path | `wslpath -w /home/me/file` prints `\\wsl.localhost\...`; `wslpath -u 'C:\Users\me'` prints `/mnt/c/Users/me` |
| WSL shell | Open Explorer here | `explorer.exe .` (returns exit code 1 even on success; ignore it) |
| WSL shell | Open VS Code here | `code .` (the WSL extension connects remotely) |
| WSL shell | Copy to Windows clipboard | `echo hi \| clip.exe` (dotfiles alias: `clip`, `pbcopy`) |
| WSL shell | Paste from Windows clipboard | `powershell.exe -NoProfile -Command Get-Clipboard` (dotfiles alias: `pbpaste`) |
| WSL shell | Run PowerShell | `powershell.exe -NoProfile -c "Get-Date"` |
| WSL shell | Open a URL in the Windows browser | `wslview https://...` (package `wslu`) or `cmd.exe /c start https://...` |
| WSL shell | Open any file with its Windows app | `wslview file.pdf` or `explorer.exe "$(wslpath -w file.pdf)"` |
| Windows shell | Run a Linux command | `wsl ls -la`, `wsl -d Ubuntu-22.04 -u root bash` |
| Windows shell | Restart WSL entirely | `wsl --shutdown` (fixes clock drift, stuck mounts, memory bloat) |
| Windows shell | List / stop one distro | `wsl -l -v`, `wsl --terminate Ubuntu-22.04` |
| Windows shell | Back up / restore a distro | `wsl --export Ubuntu-22.04 D:\wsl-backup.tar`, `wsl --import Name C:\WSL\Name file.tar` |
| Both | Rule of thumb | Code lives in WSL (`~/src`). Downloads and Office files live in Windows. Never clone into `/mnt/c` |

Windows executables are callable from WSL by their `.exe` name when
`appendWindowsPath` is on. With it off (the dotfiles do this for a faster PATH),
`10-path.sh` adds back `System32` and VS Code only.

## Where things are

| Need | Go to |
|---|---|
| Modern settings | `Win+I`. Deep links: `ms-settings:display`, `ms-settings:network-proxy`, `ms-settings:regionlanguage` |
| Classic Control Panel | `Win+R`, `control`. Still the home of Credential Manager, Programs and Features (`appwiz.cpl`), Network adapters (`ncpa.cpl`) |
| Task Manager | `Ctrl+Shift+Esc`. Startup apps tab, Performance, Details for PIDs |
| Resource Monitor | `resmon` (who holds which file, network per process) |
| Event Viewer | `eventvwr`. Windows Logs > System and Application |
| Environment variables (user) | `rundll32 sysdm.cpl,EditEnvironmentVariables` (no admin). Restart Terminal to pick them up |
| System properties | `sysdm.cpl` |
| Windows features (WSL, Hyper-V) | `optionalfeatures` (admin) |
| Services | `services.msc` |
| Device Manager | `devmgmt.msc` |
| Disk Management | `diskmgmt.msc` |
| Certificates: current user / machine | `certmgr.msc` / `certlm.msc`. Trusted Root Certification Authorities is where the proxy CA lives |
| Installed apps | Settings > Apps > Installed apps, or `winget list` |
| Startup folder | `Win+R`, `shell:startup` |
| App shortcuts folder | `Win+R`, `shell:AppsFolder` |
| Version and build | `winver` |
| System info dump | `msinfo32` |
| Temp folder | `%TEMP%` |
| Proxy settings | Settings > Network & internet > Proxy. Shows the PAC URL if there is one |
| Reliability history | `perfmon /rel` (why did it crash this week) |

## Browser profiles (Edge and Chrome)

| Task | How |
|---|---|
| Separate work profile | Profile icon (top right) > Add. Sign in with the work account. Give it a distinct color and name |
| Pin it | Chrome creates a desktop shortcut per profile; pin that one to the taskbar. Edge: profile menu > pin |
| Switch profiles | Click the profile icon. Chrome: `Ctrl+Shift+M` opens the profile menu |
| See the policies IT pushed | `edge://policy`, `chrome://policy` |
| Which profile am I in | `chrome://version` shows the Profile Path |
| Private window | `Ctrl+Shift+N` (both) |
| Reopen closed tab | `Ctrl+Shift+T` |
| Address bar | `Ctrl+L` or `Alt+D` |
| Tabs | `Ctrl+1..8` jump, `Ctrl+9` last, `Ctrl+Tab` next, `Ctrl+W` close |
| Bookmarks bar | `Ctrl+Shift+B` toggle, `Ctrl+D` add |
| History / downloads | `Ctrl+H` / `Ctrl+J` |
| Clear data | `Ctrl+Shift+Delete` |
| DevTools | `F12` or `Ctrl+Shift+I` |
| Rule | Personal Google account never goes into the corporate profile, and vice versa |

## Teams and Outlook

Teams:

| Keys | Action |
|---|---|
| `Ctrl+E` | Search (people, messages, files). Also jumps to the command box |
| `Ctrl+Shift+M` | Mute / unmute in a call |
| `Ctrl+Shift+O` | Camera on / off |
| `Ctrl+Shift+K` | Raise / lower hand |
| `Ctrl+Shift+E` | Share screen |
| `Ctrl+Shift+H` | Hang up |
| `Ctrl+N` | New chat |
| `Ctrl+1..5` | App bar items in order (Activity, Chat, Teams, Calendar, ...) |
| `Shift+Enter` | New line in a message (Enter sends) |
| `Ctrl+Shift+X` | Expand the compose box (formatting toolbar) |
| `Ctrl+.` | Show all shortcuts |
| `Ctrl+=` / `Ctrl+-` | Zoom |

Outlook:

| Keys | Action |
|---|---|
| `Ctrl+N` | New item in the current view (mail in Mail, event in Calendar) |
| `Ctrl+Shift+M` | New mail from anywhere |
| `Ctrl+Shift+K` | New task |
| `Ctrl+Shift+A` | New appointment |
| `Ctrl+Shift+Q` | New meeting request |
| `Ctrl+E` or `F3` | Search mail |
| `Ctrl+R` / `Ctrl+Shift+R` / `Ctrl+F` | Reply / reply all / forward |
| `Ctrl+Enter` or `Alt+S` | Send |
| `Ctrl+1` / `Ctrl+2` / `Ctrl+3` / `Ctrl+4` | Mail / Calendar / People / Tasks |
| `Ctrl+Q` / `Ctrl+U` | Mark read / unread |
| `Ctrl+Shift+V` | Move to folder |
| `Ctrl+Shift+G` | Flag for follow-up |
| `Ctrl+K` | Check names (recipients) or insert a link in the body |
| `Esc` | Close the open item |

## The OneDrive trap

| Fact | Consequence |
|---|---|
| Desktop, Documents and Pictures are redirected into OneDrive ("Known Folder Move") | Their real path is `C:\Users\<you>\OneDrive - <Company>\Documents\...`: long, with spaces, and under constant sync |
| Files can be "online-only" placeholders (cloud icon) | A build or a `git status` touches them and triggers downloads, or fails on half-hydrated files |
| Sync watches every write | `node_modules`, `.git`, `.terraform` directories generate thousands of sync events and conflicts |
| Windows path limit is 260 characters unless admin flips `LongPathsEnabled` | Deep repos under the OneDrive path break tools |
| `/mnt/c` in WSL is slow (9P) and scanned by the antivirus | `git status` on a large repo takes seconds instead of milliseconds |

Rules:

1. Clones live in WSL at `~/src`. Reach them from Windows via `\\wsl$\Ubuntu-22.04\home\<you>\src`.
2. If something has to be on the Windows side, use `%USERPROFILE%\src` (not synced) or `C:\src`. Never Desktop or Documents.
3. For a folder you really need offline: right-click > "Always keep on this device".
4. Put the OneDrive folder in the antivirus exclusions only if IT agrees; otherwise just keep code out of it.
