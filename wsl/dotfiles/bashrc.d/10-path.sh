# shellcheck shell=bash
# 10-path.sh: PATH hygiene plus the few Windows tools worth reaching from WSL.
# Sourced by ~/.bashrc through ~/.bashrc.d (see install-dotfiles.sh).

__pathadd_front() { case ":$PATH:" in *":$1:"*) ;; *) [ -d "$1" ] && PATH="$1:$PATH" ;; esac; }
__pathadd_back()  { case ":$PATH:" in *":$1:"*) ;; *) [ -d "$1" ] && PATH="$PATH:$1" ;; esac; }

__pathadd_front "$HOME/.local/bin"
__pathadd_front "$HOME/bin"
__pathadd_front "$HOME/.local/share/fnm"
__pathadd_front "$HOME/.cargo/bin"
__pathadd_front "$HOME/go/bin"

# WSL: remember the Windows user name once (cmd.exe is slow, so cache it).
if [ -d /mnt/c/Users ] && [ -z "${WINUSER:-}" ]; then
  __winuser_cache="${XDG_CONFIG_HOME:-$HOME/.config}/devbox/winuser"
  if [ -r "$__winuser_cache" ]; then
    read -r WINUSER < "$__winuser_cache"
  elif [ -x /mnt/c/Windows/System32/cmd.exe ]; then
    WINUSER=$(cd /mnt/c 2>/dev/null && /mnt/c/Windows/System32/cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r\n')
    if [ -n "$WINUSER" ]; then
      mkdir -p "$(dirname "$__winuser_cache")" && printf '%s\n' "$WINUSER" > "$__winuser_cache"
    fi
  fi
  [ -n "${WINUSER:-}" ] && export WINUSER
  unset __winuser_cache
fi

# With appendWindowsPath=false in /etc/wsl.conf the Windows PATH is gone. Add back only
# System32 (clip.exe, explorer.exe, cmd.exe, wsl.exe), PowerShell and VS Code, at the end.
if [ -d /mnt/c/Windows/System32 ]; then
  __pathadd_back /mnt/c/Windows/System32
  __pathadd_back /mnt/c/Windows/System32/WindowsPowerShell/v1.0
  [ -n "${WINUSER:-}" ] && __pathadd_back "/mnt/c/Users/$WINUSER/AppData/Local/Programs/Microsoft VS Code/bin"
  __pathadd_back "/mnt/c/Program Files/Microsoft VS Code/bin"
fi

export PATH
