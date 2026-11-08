#!/usr/bin/env bash
# install-corp-ca.sh: trust the corporate TLS-inspection CA inside WSL.
#
# Needs sudo (for /usr/local/share/ca-certificates and update-ca-certificates).
# Everything else is done as your user. Safe to re-run; only changed files are rewritten.
#
# Usage:
#   install-corp-ca.sh [CA_DIR] [--yes] [--help]
#
#   CA_DIR   directory with .pem/.crt/.cer/.der files exported from Windows
#            (default: /mnt/c/Users/<WINUSER>/corp-ca, WINUSER detected via cmd.exe,
#             override with WINUSER=<name> in the environment)
#   --yes    do not ask for confirmation before trusting the certificates
#
# What it does:
#   1. converts DER files to PEM, splits multi-cert bundles, keeps only CA certificates
#   2. copies them to /usr/local/share/ca-certificates/corp/*.crt and runs update-ca-certificates
#   3. links ~/.config/corp-ca/bundle.pem to the system bundle (now including the corp CA)
#      and writes ~/.config/corp-ca/corp-only.pem with just the corporate certs
#   4. writes ~/.bashrc.d/90-corp-ca.sh exporting NODE_EXTRA_CA_CERTS, REQUESTS_CA_BUNDLE,
#      SSL_CERT_FILE, AWS_CA_BUNDLE, CURL_CA_BUNDLE, GIT_SSL_CAINFO, PIP_CERT
#   5. points npm, pip and git at the bundle
#   6. verifies with curl, node and python

set -euo pipefail

CORP_DIR_SYS="/usr/local/share/ca-certificates/corp"
CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/corp-ca"
BUNDLE="$CONF_DIR/bundle.pem"
CORP_ONLY="$CONF_DIR/corp-only.pem"
SYSTEM_BUNDLE="/etc/ssl/certs/ca-certificates.crt"
BASHRC_D="$HOME/.bashrc.d"
ENV_FILE="$BASHRC_D/90-corp-ca.sh"

ASSUME_YES=0
CA_DIR=""

log()  { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
info() { printf '    %s\n' "$*"; }
warn() { printf '\033[1;33mWARN\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mERROR\033[0m %s\n' "$*" >&2; exit 1; }

usage() { sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'; }

for arg in "$@"; do
  case "$arg" in
    -h|--help) usage; exit 0 ;;
    -y|--yes) ASSUME_YES=1 ;;
    -*) die "unknown option: $arg" ;;
    *) CA_DIR="$arg" ;;
  esac
done

for tool in openssl sudo; do
  command -v "$tool" >/dev/null 2>&1 || die "$tool is required (sudo apt-get install -y openssl)"
done

# --- locate the certificate directory --------------------------------------

detect_winuser() {
  local cmd="/mnt/c/Windows/System32/cmd.exe" u=""
  if [ -n "${WINUSER:-}" ]; then
    printf '%s' "$WINUSER"
    return 0
  fi
  if [ -x "$cmd" ]; then
    # run from /mnt/c so cmd.exe does not complain about a UNC working directory
    u=$(cd /mnt/c 2>/dev/null && "$cmd" /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r\n') || true
  fi
  printf '%s' "$u"
}

if [ -z "$CA_DIR" ]; then
  WINUSER_DETECTED=$(detect_winuser)
  if [ -n "$WINUSER_DETECTED" ]; then
    CA_DIR="/mnt/c/Users/$WINUSER_DETECTED/corp-ca"
  else
    die "could not detect the Windows user. Pass the directory: $0 /mnt/c/Users/<you>/corp-ca"
  fi
fi

[ -d "$CA_DIR" ] || die "directory not found: $CA_DIR (run windows/export-corp-ca.ps1 first)"
log "Reading certificates from $CA_DIR"

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

# --- normalise: DER -> PEM, split bundles, keep CA certs only ---------------

mapfile -t SRC_FILES < <(find "$CA_DIR" -maxdepth 1 -type f \
  \( -iname '*.pem' -o -iname '*.crt' -o -iname '*.cer' -o -iname '*.der' \) | sort)
[ "${#SRC_FILES[@]}" -gt 0 ] || die "no .pem/.crt/.cer/.der files in $CA_DIR"

n=0
for f in "${SRC_FILES[@]}"; do
  base=$(basename "$f")
  base="${base%.*}"
  if grep -q 'BEGIN CERTIFICATE' "$f"; then
    # PEM, possibly with several certificates: split into one file each
    awk -v out="$WORK" -v base="$base" '
      /-----BEGIN CERTIFICATE-----/ { n++; file = sprintf("%s/%s-%02d.pem", out, base, n) }
      file { print > file }
      /-----END CERTIFICATE-----/ { close(file); file = "" }
    ' "$f"
  else
    # DER
    if ! openssl x509 -inform der -in "$f" -out "$WORK/$base-01.pem" 2>/dev/null; then
      warn "skipping $base: not PEM and not DER"
      continue
    fi
  fi
  n=$((n + 1))
done

declare -a CERTS=()
while IFS= read -r pem; do
  subject=$(openssl x509 -in "$pem" -noout -subject 2>/dev/null | sed 's/^subject=//') || { warn "unreadable: $pem"; continue; }
  if ! openssl x509 -in "$pem" -noout -text 2>/dev/null | grep -A1 'Basic Constraints' | grep -q 'CA:TRUE'; then
    warn "not a CA certificate, skipping: $subject"
    continue
  fi
  CERTS+=("$pem")
done < <(find "$WORK" -name '*.pem' | sort)

[ "${#CERTS[@]}" -gt 0 ] || die "no CA certificates found in $CA_DIR"

log "Certificates to trust (${#CERTS[@]}):"
for pem in "${CERTS[@]}"; do
  subject=$(openssl x509 -in "$pem" -noout -subject | sed 's/^subject=//')
  issuer=$(openssl x509 -in "$pem" -noout -issuer | sed 's/^issuer=//')
  expiry=$(openssl x509 -in "$pem" -noout -enddate | sed 's/^notAfter=//')
  fp=$(openssl x509 -in "$pem" -noout -fingerprint -sha256 | sed 's/^.*=//')
  info "subject : $subject"
  info "issuer  : $issuer"
  info "expires : $expiry"
  info "sha256  : $fp"
  info ""
done

if [ "$ASSUME_YES" -ne 1 ]; then
  read -r -p "Trust these as root CAs on this WSL distro? [y/N] " answer
  case "$answer" in
    y|Y|yes|YES) ;;
    *) die "aborted" ;;
  esac
fi

# --- system store ----------------------------------------------------------

log "Installing into $CORP_DIR_SYS"
sudo install -d -m 755 "$CORP_DIR_SYS"
changed=0
for pem in "${CERTS[@]}"; do
  # name by sanitised CN plus short fingerprint; stable across re-runs
  cn=$(openssl x509 -in "$pem" -noout -subject -nameopt RFC2253 | sed -n 's/.*CN=\([^,]*\).*/\1/p')
  [ -n "$cn" ] || cn="corp-ca"
  safe=$(printf '%s' "$cn" | tr -c 'A-Za-z0-9._-' '-' | sed 's/^-*//; s/-*$//')
  short=$(openssl x509 -in "$pem" -noout -fingerprint -sha256 | sed 's/^.*=//; s/://g' | cut -c1-8 | tr 'A-F' 'a-f')
  dest="$CORP_DIR_SYS/$safe-$short.crt"
  if [ -f "$dest" ] && cmp -s "$pem" "$dest"; then
    info "unchanged: $dest"
  else
    sudo install -m 644 "$pem" "$dest"
    info "installed: $dest"
    changed=1
  fi
done

if [ "$changed" -eq 1 ] || ! grep -q . "$SYSTEM_BUNDLE" 2>/dev/null; then
  log "Running update-ca-certificates"
  sudo update-ca-certificates
else
  log "System bundle already up to date, skipping update-ca-certificates"
fi

# --- user-level bundles ----------------------------------------------------

log "Building bundles in $CONF_DIR"
mkdir -p "$CONF_DIR"
# bundle.pem follows the system bundle, so future update-ca-certificates runs are picked up
ln -sfn "$SYSTEM_BUNDLE" "$BUNDLE"
info "$BUNDLE -> $SYSTEM_BUNDLE"
# corp-only.pem is handy for tools that only want the extra certs (Java keytool, Docker daemons)
cat "${CERTS[@]}" > "$CORP_ONLY.tmp"
if [ -f "$CORP_ONLY" ] && cmp -s "$CORP_ONLY.tmp" "$CORP_ONLY"; then
  rm -f "$CORP_ONLY.tmp"
  info "unchanged: $CORP_ONLY"
else
  mv "$CORP_ONLY.tmp" "$CORP_ONLY"
  info "written:   $CORP_ONLY"
fi

# --- environment file ------------------------------------------------------

log "Writing $ENV_FILE"
mkdir -p "$BASHRC_D"
cat > "$ENV_FILE.tmp" <<'ENVEOF'
# shellcheck shell=bash
# Managed by devbox/wsl/install-corp-ca.sh. Re-run that script instead of editing.
# Points every CLI at the system CA bundle, which includes the corporate proxy CA.
__corp_ca="${XDG_CONFIG_HOME:-$HOME/.config}/corp-ca/bundle.pem"
if [ -r "$__corp_ca" ]; then
  export NODE_EXTRA_CA_CERTS="$__corp_ca"   # node, npm, Copilot CLI
  export REQUESTS_CA_BUNDLE="$__corp_ca"    # python requests
  export SSL_CERT_FILE="$__corp_ca"         # openssl, python ssl, Go binaries (gh, kubectl, terraform)
  export AWS_CA_BUNDLE="$__corp_ca"         # aws cli
  export CURL_CA_BUNDLE="$__corp_ca"        # curl
  export GIT_SSL_CAINFO="$__corp_ca"        # git over https
  export PIP_CERT="$__corp_ca"              # pip
  # Others, if you use them: DENO_CERT, CARGO_HTTP_CAINFO, GOPROXY is unaffected.
fi
unset __corp_ca
ENVEOF
if [ -f "$ENV_FILE" ] && cmp -s "$ENV_FILE.tmp" "$ENV_FILE"; then
  rm -f "$ENV_FILE.tmp"
  info "unchanged"
else
  mv "$ENV_FILE.tmp" "$ENV_FILE"
  info "written (sourced by ~/.bashrc via ~/.bashrc.d, see install-dotfiles.sh)"
fi
if ! grep -qs 'bashrc.d' "$HOME/.bashrc"; then
  warn "$HOME/.bashrc does not source $HOME/.bashrc.d yet. Run install-dotfiles.sh, or add:"
  # shellcheck disable=SC2016
  warn '  for f in "$HOME"/.bashrc.d/*.sh; do [ -r "$f" ] && . "$f"; done'
fi

# --- tool configs ----------------------------------------------------------

log "Tool configuration"
if command -v npm >/dev/null 2>&1; then
  npm config set cafile "$BUNDLE" >/dev/null && info "npm  cafile = $BUNDLE"
else
  info "npm not installed yet; NODE_EXTRA_CA_CERTS covers it once it is"
fi
if python3 -m pip --version >/dev/null 2>&1; then
  python3 -m pip config --user set global.cert "$BUNDLE" >/dev/null && info "pip  global.cert = $BUNDLE"
else
  info "pip not installed yet; PIP_CERT covers it once it is"
fi
if command -v git >/dev/null 2>&1; then
  git config --global http.sslCAInfo "$BUNDLE" && info "git  http.sslCAInfo = $BUNDLE"
fi

# --- verification ----------------------------------------------------------

log "Verification"
export NODE_EXTRA_CA_CERTS="$BUNDLE" SSL_CERT_FILE="$BUNDLE" CURL_CA_BUNDLE="$BUNDLE"

if out=$(curl -sI --max-time 10 https://github.com 2>&1 | head -1) && [ -n "$out" ]; then
  info "curl   https://github.com -> $out"
else
  rc=$(curl -sI --max-time 10 -o /dev/null -w '%{exitcode}' https://github.com 2>/dev/null || true)
  warn "curl to https://github.com failed (curl exit $rc). 60 = CA still not trusted, 6/7/28 = network or proxy. Run proxy-check.sh"
fi

if command -v node >/dev/null 2>&1; then
  node -e "require('https').get('https://registry.npmjs.org/', r => { console.log('node   https://registry.npmjs.org -> HTTP ' + r.statusCode); process.exit(0) }).on('error', e => { console.error('node TLS failed: ' + e.message); process.exit(1) })" 2>&1 | sed 's/^/    /' || true
else
  info "node not installed yet; skip node TLS test"
fi

if command -v python3 >/dev/null 2>&1; then
  if ! python3 -c "import urllib.request; urllib.request.urlopen('https://pypi.org/simple/', timeout=10); print('    python https://pypi.org -> ok')" 2>/dev/null; then
    warn "python TLS test failed (python uses SSL_CERT_FILE / the system bundle)"
  fi
fi

log "Done. Open a new shell (or: source $ENV_FILE) so the variables apply."
