# shellcheck shell=bash
# 50-wsl.sh: WSL-only fixes. Does nothing on a plain Linux box.

if grep -qi microsoft /proc/version 2>/dev/null || [ -n "${WSL_DISTRO_NAME:-}" ]; then

  # Some WSL sessions start with umask 0000 (files created world-writable). Fix it.
  [ "$(umask)" = "0000" ] && umask 022

  # Open URLs in the Windows browser (wslu package provides wslview)
  command -v wslview >/dev/null 2>&1 && export BROWSER=wslview

  # gpg needs to know the tty for pinentry
  GPG_TTY=$(tty) && export GPG_TTY

  # One ssh-agent per distro, shared by every tab. State lives in ~/.ssh/agent.env.
  __devbox_ssh_agent() {
    local env_file="$HOME/.ssh/agent.env"
    [ -d "$HOME/.ssh" ] || { mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"; }
    # shellcheck disable=SC1090
    [ -r "$env_file" ] && . "$env_file" >/dev/null
    ssh-add -l >/dev/null 2>&1
    local rc=$?
    if [ "$rc" -eq 2 ]; then
      # 2 = no agent reachable (1 = agent running, no keys loaded, which is fine)
      (umask 077; ssh-agent -s > "$env_file")
      # shellcheck disable=SC1090
      . "$env_file" >/dev/null
    fi
  }
  __devbox_ssh_agent

  # Windows drives are slow for git; tell git not to worry about file modes there
  # (metadata mount option handles the rest, see README.md).

  # Quick restart hint when the clock drifts after sleep: sudo hwclock -s
  wslfixtime() { sudo hwclock -s && date; }
fi
