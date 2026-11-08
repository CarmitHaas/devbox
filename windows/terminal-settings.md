# Windows Terminal settings

Windows Terminal is the one window you live in. Make it open straight into Ubuntu,
in your WSL home, with a font that has real glyphs.

Open settings with `Ctrl+,`. The raw JSON is one click away: "Open JSON file" at the
bottom left (or `Ctrl+Shift+,`). The file lives at
`%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`.

## What to set

| Setting | Value | Where |
|---|---|---|
| Default profile | Ubuntu-22.04 | Startup > Default profile |
| Default terminal application | Windows Terminal | Startup > Default terminal application (so `cmd` and PowerShell windows also open in Terminal) |
| Launch mode | Maximized | Startup > Launch mode |
| Font | JetBrains Mono, 11 (fallback: Cascadia Mono, ships with Terminal) | Profiles > Defaults > Appearance > Font face |
| Copy on select | On | Interaction > Automatically copy selection to clipboard |
| Copy formatting | Off (plain text only) | Interaction > Copy formatting |
| Starting directory (Ubuntu profile) | `//wsl$/Ubuntu-22.04/home/<user>` or simply `~` | Profiles > Ubuntu-22.04 > General > Starting directory |
| Bell | None | Profiles > Defaults > Advanced > Bell notification style |
| Scrollback | 50000 lines | Profiles > Defaults > Advanced > History size |
| Color scheme | One Half Dark (or Campbell) | Profiles > Defaults > Appearance |
| Cursor | Filled box | Profiles > Defaults > Appearance |
| Quake mode | ``Win+` `` drops a terminal from the top of the screen | Default action "Toggle quake window", already bound |

Font install without admin: download the JetBrains Mono zip from
`https://github.com/JetBrains/JetBrainsMono/releases`, select all `.ttf` files,
right-click, Install. That installs for the current user only and needs no admin.
Restart Terminal afterwards.

## Keybindings worth knowing

`Ctrl+Shift+C` (copy) and `Ctrl+Shift+V` (paste) are already the defaults. `Ctrl+C`
also copies when there is a selection and sends SIGINT otherwise. Right-click pastes.

| Keys | Action |
|---|---|
| `Ctrl+Shift+T` | New tab (default profile) |
| `Ctrl+Shift+1..9` | New tab with profile N |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Next / previous tab |
| `Ctrl+Alt+1..9` | Jump to tab N |
| `Ctrl+Shift+W` | Close pane or tab |
| `Alt+Shift+D` | Split pane (auto direction), same profile |
| `Alt+Shift+Minus` / `Alt+Shift+Plus` | Split horizontal / vertical |
| `Alt+Arrow` | Move focus between panes |
| `Alt+Shift+Arrow` | Resize pane |
| `Ctrl+Shift+F` | Find in scrollback |
| `Ctrl+Shift+P` | Command palette (every action is searchable) |
| `Ctrl+=` / `Ctrl+-` / `Ctrl+0` | Font zoom in / out / reset |
| `Alt+Enter` or `F11` | Fullscreen |
| `Ctrl+Shift+Space` | Profile dropdown |
| `Ctrl+Shift+D` | Duplicate tab |
| `Shift+Arrow` in a `Ctrl+Shift+F` search | Jump between matches |
| `Ctrl+Shift+M` | Mark mode (keyboard selection) |
| ``Win+` `` | Quake window (drop-down terminal) |

## `settings.json` fragment to paste

Merge these keys into the existing file. Do not replace the whole file: the generated
`profiles.list` entries carry per-machine GUIDs. The `defaultProfile` value must be the
`guid` of the Ubuntu-22.04 entry already present under `profiles.list`; copy it from
there. Terminal migrates the `actions` block to its newer `keybindings` format on save.

```json
{
    "defaultProfile": "{PASTE-THE-UBUNTU-22.04-GUID-FROM-profiles.list}",
    "launchMode": "maximized",
    "copyOnSelect": true,
    "copyFormatting": "none",
    "trimBlockSelection": true,
    "profiles": {
        "defaults": {
            "font": { "face": "JetBrains Mono", "size": 11 },
            "colorScheme": "One Half Dark",
            "cursorShape": "filledBox",
            "historySize": 50000,
            "bellStyle": "none",
            "intenseTextStyle": "bright",
            "scrollbarState": "visible",
            "padding": "6"
        },
        "list": [
            {
                "name": "Ubuntu-22.04",
                "source": "Windows.Terminal.Wsl",
                "commandline": "wsl.exe -d Ubuntu-22.04",
                "startingDirectory": "//wsl$/Ubuntu-22.04/home/<user>",
                "icon": "https://assets.ubuntu.com/v1/49a1a858-favicon-32x32.png",
                "tabTitle": "ubuntu"
            }
        ]
    },
    "actions": [
        { "command": { "action": "copy", "singleLine": false }, "keys": "ctrl+shift+c" },
        { "command": "paste", "keys": "ctrl+shift+v" },
        { "command": "find", "keys": "ctrl+shift+f" },
        { "command": { "action": "splitPane", "split": "auto", "splitMode": "duplicate" }, "keys": "alt+shift+d" },
        { "command": { "action": "newTab", "profile": "Ubuntu-22.04" }, "keys": "ctrl+shift+t" },
        { "command": "toggleFocusMode", "keys": "ctrl+shift+z" }
    ]
}
```

Notes:

- `//wsl$/Ubuntu-22.04/home/<user>` is the UNC path to your WSL home. Newer builds also
  accept `~`. On Windows 11 the share is also reachable as `\\wsl.localhost\Ubuntu-22.04`.
- The `list` entry above matches the auto-generated Ubuntu profile by `name` and
  `source`. If a second Ubuntu entry appears, delete the one without a `guid`.
- If a font is missing Terminal silently falls back to Cascadia Mono; check
  Appearance > Font face for the warning triangle.
- Keep `copyFormatting` off. HTML/RTF on the clipboard makes pasting into Teams and
  Outlook ugly.
- `wt` from Run (`Win+R`) or PowerShell opens a new Terminal window. `wt -d .` opens
  in the current folder. `wt -p Ubuntu-22.04` picks a profile.
