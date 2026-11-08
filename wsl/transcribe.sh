#!/usr/bin/env bash
# transcribe.sh: local speech-to-text for a recording (m4a, mp3, wav, mp4, ...), Hebrew by default.
# Creates a private venv on first run (uv, under ~/.local/share/devbox/transcribe) and installs
# faster-whisper into it, then runs transcribe.py. Output: a markdown file next to the input.
#
#   bash wsl/transcribe.sh memo.m4a                 # Hebrew, timestamps
#   bash wsl/transcribe.sh --lang en call.mp4        # English
#   bash wsl/transcribe.sh --lang auto --no-timestamps x.wav
#   bash wsl/transcribe.sh --setup                   # only create the venv and fetch the models
#
# Everything runs on this machine. The only network use is the first download of the model
# from huggingface.co (about 1.6 GB per model); behind the corporate proxy the CA from
# install-corp-ca.sh must already be installed (REQUESTS_CA_BUNDLE / SSL_CERT_FILE).
set -euo pipefail

HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
VENV="${XDG_DATA_HOME:-$HOME/.local/share}/devbox/transcribe"
PY="$VENV/bin/python"

say() { printf '\033[1;34m==>\033[0m %s\n' "$*" >&2; }

ensure_venv() {
  if [ -x "$PY" ] && "$PY" -c 'import faster_whisper' 2>/dev/null; then return; fi
  command -v uv >/dev/null 2>&1 || { echo "uv missing: run wsl/bootstrap.sh first" >&2; exit 1; }
  say "creating venv in $VENV and installing faster-whisper (one time)"
  uv venv --quiet "$VENV"
  uv pip install --quiet --python "$PY" faster-whisper
}

ensure_venv
if [ "${1:-}" = "--setup" ]; then
  say "fetching the default models (Hebrew and general)"
  "$PY" - <<'PYEOF'
from faster_whisper import WhisperModel
for m in ("ivrit-ai/whisper-large-v3-turbo-ct2", "deepdml/faster-whisper-large-v3-turbo-ct2"):
    WhisperModel(m, device="cpu", compute_type="int8")
    print("ready:", m)
PYEOF
  exit 0
fi
[ $# -ge 1 ] || { sed -n '2,12p' "$0" >&2; exit 2; }
exec "$PY" "$HERE/transcribe.py" "$@"
