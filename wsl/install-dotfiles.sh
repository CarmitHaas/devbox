#!/usr/bin/env bash
# install-dotfiles.sh: copy the dotfiles from ./dotfiles into $HOME.
#
# No sudo. Safe to re-run. Existing files that differ are backed up as
# <file>.bak.<timestamp> before being replaced, and every change is printed.
# A ~/.gitconfig that did not come from our template is never replaced without
# --replace-gitconfig (it is backed up first even then).
#
# Usage:
#   install-dotfiles.sh [--email ADDR] [--replace-gitconfig] [--dry-run] [--help]
#
#   --email ADDR          fill the <work-email> placeholder in gitconfig.template
#   --replace-gitconfig   replace a hand-written ~/.gitconfig with the template (backup kept)
#   --dry-run             print what would change, touch nothing
#
# What lands where:
#   dotfiles/bashrc.d/*.sh   -> ~/.bashrc.d/            (+ one sourcing block in ~/.bashrc)
#   dotfiles/inputrc         -> ~/.inputrc
#   dotfiles/starship.toml   -> ~/.config/starship.toml
#   dotfiles/tmux.conf       -> ~/.tmux.conf
#   dotfiles/vimrc           -> ~/.vimrc
#   dotfiles/gitconfig.template -> ~/.gitconfig          (see rules above)

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/dotfiles"
STAMP=$(date +%Y%m%d%H%M%S)
DRY=0
REPLACE_GITCONFIG=0
EMAIL=""
CHANGES=0

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    --email) EMAIL="${2:?--email needs an address}"; shift 2 ;;
    --replace-gitconfig) REPLACE_GITCONFIG=1; shift ;;
    --dry-run) DRY=1; shift ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done

[ -d "$SRC" ] || { echo "dotfiles directory not found: $SRC" >&2; exit 1; }

log()  { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
note() { printf '    %s\n' "$*"; }
act()  { CHANGES=$((CHANGES + 1)); if [ "$DRY" -eq 1 ]; then printf '    [dry-run] %s\n' "$*"; else printf '    %s\n' "$*"; fi; }

backup() { # FILE -> moves aside if it exists
  local f=$1
  [ -e "$f" ] || return 0
  act "backup   $f -> $f.bak.$STAMP"
  [ "$DRY" -eq 1 ] || mv "$f" "$f.bak.$STAMP"
}

install_file() { # SRC DEST
  local src=$1 dest=$2
  if [ -f "$dest" ] && cmp -s "$src" "$dest"; then
    note "unchanged $dest"
    return 0
  fi
  [ "$DRY" -eq 1 ] || mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ]; then
    backup "$dest"
    act "update   $dest"
  else
    act "create   $dest"
  fi
  [ "$DRY" -eq 1 ] || cp "$src" "$dest"
}

# --- bashrc.d ----------------------------------------------------------------

log "$HOME/.bashrc.d"
mkdir -p "$HOME/.bashrc.d"
for f in "$SRC"/bashrc.d/*.sh; do
  install_file "$f" "$HOME/.bashrc.d/$(basename "$f")"
done
note "(*.example files are left in the repo; copy one by hand when you need it)"

log "$HOME/.bashrc sourcing block"
BASHRC="$HOME/.bashrc"
BEGIN='# >>> devbox bashrc.d >>>'
END='# <<< devbox bashrc.d <<<'
BLOCK=$(cat <<'BLK'
# >>> devbox bashrc.d >>>
# Managed by devbox/wsl/install-dotfiles.sh. Edit the files in ~/.bashrc.d instead.
if [ -d "$HOME/.bashrc.d" ]; then
  for __devbox_f in "$HOME"/.bashrc.d/*.sh; do
    [ -r "$__devbox_f" ] && . "$__devbox_f"
  done
  unset __devbox_f
fi
# <<< devbox bashrc.d <<<
BLK
)
touch "$BASHRC"
if grep -qF "$BEGIN" "$BASHRC" && grep -qF "$END" "$BASHRC"; then
  current=$(awk -v b="$BEGIN" -v e="$END" '$0==b{p=1} p{print} $0==e{p=0}' "$BASHRC")
  if [ "$current" = "$BLOCK" ]; then
    note "unchanged $BASHRC"
  else
    act "update   sourcing block in $BASHRC"
    if [ "$DRY" -eq 0 ]; then
      tmp=$(mktemp)
      awk -v b="$BEGIN" -v e="$END" -v blk="$BLOCK" '
        $0==b {print blk; skip=1; next}
        $0==e {skip=0; next}
        !skip {print}
      ' "$BASHRC" > "$tmp"
      cp "$BASHRC" "$BASHRC.bak.$STAMP"
      mv "$tmp" "$BASHRC"
    fi
  fi
else
  act "append   sourcing block to $BASHRC"
  if [ "$DRY" -eq 0 ]; then
    printf '\n%s\n' "$BLOCK" >> "$BASHRC"
  fi
fi

# --- plain files -------------------------------------------------------------

log "readline, starship, tmux, vim"
install_file "$SRC/inputrc"       "$HOME/.inputrc"
install_file "$SRC/starship.toml" "${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
install_file "$SRC/tmux.conf"     "$HOME/.tmux.conf"
install_file "$SRC/vimrc"         "$HOME/.vimrc"

# --- gitconfig ---------------------------------------------------------------

log "$HOME/.gitconfig"
GITCONFIG="$HOME/.gitconfig"
MARKER='# devbox-template'
rendered=$(mktemp)
trap 'rm -f "$rendered"' EXIT
if [ -n "$EMAIL" ]; then
  sed "s|<work-email>|$EMAIL|" "$SRC/gitconfig.template" > "$rendered"
else
  cp "$SRC/gitconfig.template" "$rendered"
fi

if [ ! -e "$GITCONFIG" ]; then
  install_file "$rendered" "$GITCONFIG"
elif grep -qF "$MARKER" "$GITCONFIG"; then
  # ours from an earlier run: keep the email already set unless --email given
  if [ -z "$EMAIL" ]; then
    existing_email=$(git config -f "$GITCONFIG" user.email 2>/dev/null || true)
    if [ -n "$existing_email" ] && [ "$existing_email" != "<work-email>" ]; then
      sed -i "s|<work-email>|$existing_email|" "$rendered"
    fi
  fi
  install_file "$rendered" "$GITCONFIG"
elif [ "$REPLACE_GITCONFIG" -eq 1 ]; then
  install_file "$rendered" "$GITCONFIG"
else
  note "kept      $GITCONFIG (hand-written, not from the template)"
  note "          re-run with --replace-gitconfig to swap it (a backup is kept), or merge by hand:"
  note "          diff $GITCONFIG $SRC/gitconfig.template"
fi

if [ "$DRY" -eq 0 ] && [ -f "$GITCONFIG" ] && grep -qF '<work-email>' "$GITCONFIG"; then
  note "TODO: set your work email:  git config --global user.email you@company.tld"
fi

# --- folders -----------------------------------------------------------------

log "folders"
for d in "$HOME/src" "$HOME/.local/bin" "$HOME/.ssh"; do
  if [ ! -d "$d" ]; then
    act "mkdir    $d"
    [ "$DRY" -eq 1 ] || mkdir -p "$d"
  fi
done
[ "$DRY" -eq 1 ] || chmod 700 "$HOME/.ssh"

# --- done --------------------------------------------------------------------

echo
if [ "$CHANGES" -eq 0 ]; then
  log "Nothing to change."
else
  log "$CHANGES change(s). Open a new terminal or run:  exec bash"
fi
