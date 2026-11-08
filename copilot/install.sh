#!/usr/bin/env bash
# install.sh: install the personal Copilot layer (instructions + skills) into ~/.copilot.
# Usage: ./install.sh [--dry-run]
# Paths verified against the Copilot CLI configuration directory reference on 2026-11-08:
#   https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-config-dir-reference
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="${COPILOT_HOME:-$HOME/.copilot}"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$DEST_DIR/backup-$STAMP"
DRY_RUN=0

usage() {
  cat <<USAGE
Usage: $(basename "$0") [--dry-run]

Copies copilot-instructions.md to $DEST_DIR/copilot-instructions.md
and each skills/<name>/ to $DEST_DIR/skills/<name>/.
Anything replaced is backed up first to $DEST_DIR/backup-<timestamp>/.
Set COPILOT_HOME to install somewhere other than ~/.copilot.

  --dry-run, -n   print what would happen, write nothing
  -h, --help      this text
USAGE
}

for arg in "$@"; do
  case "$arg" in
    --dry-run|-n) DRY_RUN=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $arg" >&2; usage >&2; exit 2 ;;
  esac
done

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf 'would run: %s\n' "$*"
  else
    "$@"
  fi
}

status() {
  # $1: verb, rest: message. In dry-run mode the verb is prefixed with "would".
  local verb="$1"; shift
  if [ "$DRY_RUN" -eq 1 ]; then
    printf 'would %-10s %s\n' "$verb" "$*"
  else
    printf '%-11s %s\n' "$verb:" "$*"
  fi
}

backup() {
  # $1: file or directory under DEST_DIR to preserve before replacing
  local src="$1" rel
  rel="${src#"$DEST_DIR"/}"
  run mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
  run cp -R "$src" "$BACKUP_DIR/$rel"
  status "back up" "$src -> $BACKUP_DIR/$rel"
}

if [ ! -f "$SRC_DIR/copilot-instructions.md" ]; then
  echo "missing: $SRC_DIR/copilot-instructions.md" >&2
  exit 1
fi
if [ ! -d "$SRC_DIR/skills" ]; then
  echo "missing: $SRC_DIR/skills/" >&2
  exit 1
fi

echo "source:      $SRC_DIR"
echo "destination: $DEST_DIR"
if [ "$DRY_RUN" -eq 1 ]; then
  echo "mode:        dry run, nothing is written"
fi

# 1. Personal instructions file
target="$DEST_DIR/copilot-instructions.md"
if [ -f "$target" ]; then
  if cmp -s "$SRC_DIR/copilot-instructions.md" "$target"; then
    status "unchanged" "$target"
  else
    backup "$target"
    run cp "$SRC_DIR/copilot-instructions.md" "$target"
    status "update" "$target"
  fi
else
  run mkdir -p "$DEST_DIR"
  run cp "$SRC_DIR/copilot-instructions.md" "$target"
  status "install" "$target"
fi

# 2. Skills: one folder each, SKILL.md inside, name equals folder
installed=0
skipped=0
for skill_dir in "$SRC_DIR"/skills/*/; do
  [ -d "$skill_dir" ] || continue
  name="$(basename "$skill_dir")"
  skill_file="$skill_dir/SKILL.md"
  if [ ! -f "$skill_file" ]; then
    status "skip" "$name (no SKILL.md)" >&2
    skipped=$((skipped + 1))
    continue
  fi
  declared="$(sed -n 's/^name:[[:space:]]*//p' "$skill_file" | head -n 1)"
  if [ "$declared" != "$name" ]; then
    status "skip" "$name (name: '$declared' does not equal the folder name)" >&2
    skipped=$((skipped + 1))
    continue
  fi
  dest="$DEST_DIR/skills/$name"
  if [ -d "$dest" ]; then
    if diff -rq "$skill_dir" "$dest" >/dev/null 2>&1; then
      status "unchanged" "$dest"
      installed=$((installed + 1))
      continue
    fi
    backup "$dest"
    run rm -rf "$dest"
  fi
  run mkdir -p "$dest"
  run cp -R "${skill_dir}." "$dest/"
  status "install" "$dest"
  installed=$((installed + 1))
done
echo "skills:     $installed installed or unchanged, $skipped skipped"

cat <<NOTE

Where Copilot reads these (verified 2026-11-08):
  Copilot CLI:
    $DEST_DIR/copilot-instructions.md
    $DEST_DIR/skills/<name>/SKILL.md
  VS Code, Session Target "Copilot": the same two paths, on the machine where the agent runs.
    VS Code on Windows reads %USERPROFILE%\\.copilot\\ which is a separate copy from the WSL home.
    Run this script on that side too, or copy the two paths by hand.
    VS Code connected to WSL reads the WSL home, the same files as the CLI.
  VS Code, Session Target "Local": reads ~/.copilot/skills/ (setting chat.agentSkillsLocations)
    but not copilot-instructions.md. Paste its content into User instructions via
    "Chat: Open Customizations", or use Session Target "Copilot". Verify on your machine.

A running session does not pick up changes: start a new one (/new) or restart the CLI.
Check: run copilot, then /skills list and /instructions.
NOTE
