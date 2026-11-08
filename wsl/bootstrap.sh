#!/usr/bin/env bash
# bootstrap.sh: install the DevOps toolchain inside WSL Ubuntu 22.04.
#
# NEEDS SUDO. Run as your normal user; it calls sudo where required (apt, /usr/local/bin).
# Run install-corp-ca.sh first if the laptop sits behind a TLS-inspecting proxy, or every
# download below fails with "certificate verify failed".
#
# Usage:
#   bootstrap.sh [--minimal] [--extras] [--help]
#
#   --minimal   apt basics + gh + Node 22 (+ Copilot CLI) only
#   --extras    also stern and direnv
#
# Each tool has its own function and is skipped when already on PATH, so re-runs are
# cheap. Proxy env vars (HTTPS_PROXY etc.) are honoured by curl and copied into apt.
#
# Version pins (environment variables, empty = latest):
#   KUBECTL_MINOR=v1.34  HELM_VERSION=v3.16.2  NODE_VERSION=22  AWSCLI_VERSION=2.17.0
#   YQ_VERSION=v4.44.3   TERRAGRUNT_VERSION=v0.67.0  K9S_VERSION=v0.32.5
#   KUBECTX_VERSION=v0.9.5  STERN_VERSION=v1.30.0

set -euo pipefail

MODE="full"
EXTRAS=0
for arg in "$@"; do
  case "$arg" in
    -h|--help) sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    --minimal) MODE="minimal" ;;
    --extras) EXTRAS=1 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

KUBECTL_MINOR="${KUBECTL_MINOR:-}"
HELM_VERSION="${HELM_VERSION:-}"
NODE_VERSION="${NODE_VERSION:-22}"
AWSCLI_VERSION="${AWSCLI_VERSION:-}"
YQ_VERSION="${YQ_VERSION:-}"
TERRAGRUNT_VERSION="${TERRAGRUNT_VERSION:-}"
K9S_VERSION="${K9S_VERSION:-}"
KUBECTX_VERSION="${KUBECTX_VERSION:-}"
STERN_VERSION="${STERN_VERSION:-}"

DEB_ARCH=$(dpkg --print-architecture)            # amd64 | arm64
case "$DEB_ARCH" in
  amd64) UNAME_ARCH="x86_64"; KUBECTX_ARCH="x86_64" ;;
  arm64) UNAME_ARCH="aarch64"; KUBECTX_ARCH="arm64" ;;
  *) echo "unsupported architecture: $DEB_ARCH" >&2; exit 1 ;;
esac

LOCAL_BIN="$HOME/.local/bin"
FNM_DIR="$HOME/.local/share/fnm"
mkdir -p "$LOCAL_BIN"
export PATH="$LOCAL_BIN:$FNM_DIR:$PATH"

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

APT_UPDATED=0

log()  { printf '\n\033[1;36m==>\033[0m %s\n' "$*"; }
info() { printf '    %s\n' "$*"; }
warn() { printf '\033[1;33mWARN\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mERROR\033[0m %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

fetch() {
  # fetch URL DEST: curl honours HTTPS_PROXY/NO_PROXY and the CA env from 90-corp-ca.sh
  local url=$1 dest=$2 rc=0
  curl -fsSL --retry 3 --connect-timeout 15 -o "$dest" "$url" || rc=$?
  if [ "$rc" -eq 60 ]; then
    die "TLS verification failed for $url. The proxy CA is not trusted: run install-corp-ca.sh first."
  elif [ "$rc" -ne 0 ]; then
    die "download failed ($rc): $url"
  fi
}

fetch_text() { # URL -> stdout
  curl -fsSL --retry 3 --connect-timeout 15 "$1"
}

gh_latest_tag() {
  # gh_latest_tag owner/repo -> tag, by following the /releases/latest redirect (no API rate limit)
  local final
  final=$(curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/$1/releases/latest") || return 1
  printf '%s\n' "${final##*/}"
}

gh_asset_url() { # owner/repo tag asset
  printf 'https://github.com/%s/releases/download/%s/%s\n' "$1" "$2" "$3"
}

install_bin() { # SRC NAME -> /usr/local/bin/NAME
  sudo install -m 755 "$1" "/usr/local/bin/$2"
  info "installed /usr/local/bin/$2"
}

apt_update() {
  if [ "$APT_UPDATED" -eq 0 ] || [ "${1:-}" = "force" ]; then
    sudo apt-get update -qq
    APT_UPDATED=1
  fi
}

apt_install() {
  apt_update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends "$@"
}

add_keyring() { # URL DEST (dearmors ASCII input, passes binary through)
  local url=$1 dest=$2
  fetch "$url" "$WORK/key"
  if grep -q 'BEGIN PGP' "$WORK/key"; then
    gpg --dearmor < "$WORK/key" > "$WORK/key.gpg"
  else
    cp "$WORK/key" "$WORK/key.gpg"
  fi
  sudo install -d -m 755 /etc/apt/keyrings
  sudo install -m 644 "$WORK/key.gpg" "$dest"
}

add_apt_source() { # NAME LINE
  local file="/etc/apt/sources.list.d/$1.list"
  if [ -f "$file" ] && grep -qxF "$2" "$file"; then
    return 0
  fi
  printf '%s\n' "$2" | sudo tee "$file" >/dev/null
  apt_update force
}

# --- preflight -------------------------------------------------------------

preflight() {
  log "Preflight"
  have sudo || die "sudo is required"
  sudo -v || die "sudo failed"
  info "arch: $DEB_ARCH, mode: $MODE, extras: $EXTRAS"
  if grep -qi microsoft /proc/version 2>/dev/null; then
    info "running inside WSL"
  else
    warn "not running inside WSL; continuing anyway"
  fi

  # Mirror proxy env into apt, which ignores HTTPS_PROXY on its own
  local hp="${HTTP_PROXY:-${http_proxy:-}}" sp="${HTTPS_PROXY:-${https_proxy:-}}"
  if [ -n "$hp$sp" ]; then
    local conf="/etc/apt/apt.conf.d/95-devbox-proxy" tmp="$WORK/apt-proxy"
    {
      [ -n "$hp" ] && printf 'Acquire::http::Proxy "%s";\n' "$hp"
      [ -n "$sp" ] && printf 'Acquire::https::Proxy "%s";\n' "$sp"
    } > "$tmp"
    if ! sudo cmp -s "$tmp" "$conf" 2>/dev/null; then
      sudo install -m 644 "$tmp" "$conf"
      info "wrote $conf from the proxy environment"
    fi
  fi
}

# --- apt basics ------------------------------------------------------------

install_apt_basics() {
  log "apt basics"
  apt_install \
    build-essential curl wget unzip zip jq git tmux tree htop ripgrep fd-find bat fzf \
    python3-venv python3-pip openssl ca-certificates gnupg software-properties-common \
    bash-completion apt-transport-https lsb-release wslu
  # Ubuntu names these differently; the dotfiles alias them (bat -> batcat, fd -> fdfind)
}

# --- individual tools ------------------------------------------------------

install_gh() {
  have gh && { info "gh present"; return; }
  log "gh (GitHub CLI) from cli.github.com apt repo"
  add_keyring https://cli.github.com/packages/githubcli-archive-keyring.gpg /etc/apt/keyrings/githubcli-archive-keyring.gpg
  add_apt_source github-cli "deb [arch=$DEB_ARCH signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main"
  apt_install gh
}

install_yq() {
  have yq && { info "yq present"; return; }
  log "yq (mikefarah) from GitHub releases"
  local tag="${YQ_VERSION:-$(gh_latest_tag mikefarah/yq)}"
  fetch "$(gh_asset_url mikefarah/yq "$tag" "yq_linux_${DEB_ARCH}")" "$WORK/yq"
  install_bin "$WORK/yq" yq
}

install_kubectl() {
  have kubectl && { info "kubectl present"; return; }
  log "kubectl from pkgs.k8s.io"
  local minor="$KUBECTL_MINOR"
  if [ -z "$minor" ]; then
    minor=$(fetch_text https://dl.k8s.io/release/stable.txt | sed -E 's/^(v[0-9]+\.[0-9]+).*/\1/')
  fi
  info "channel: $minor (pin with KUBECTL_MINOR=v1.xx; stay within one minor of your clusters)"
  add_keyring "https://pkgs.k8s.io/core:/stable:/${minor}/deb/Release.key" /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  add_apt_source kubernetes "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${minor}/deb/ /"
  apt_install kubectl
}

install_helm() {
  have helm && { info "helm present"; return; }
  log "helm from get.helm.sh"
  local ver="${HELM_VERSION:-$(fetch_text https://get.helm.sh/helm-latest-version)}"
  local name="helm-${ver}-linux-${DEB_ARCH}.tar.gz"
  fetch "https://get.helm.sh/$name" "$WORK/$name"
  fetch "https://get.helm.sh/$name.sha256sum" "$WORK/$name.sha256sum"
  local want got
  want=$(awk '{print $1}' "$WORK/$name.sha256sum")
  got=$(sha256sum "$WORK/$name" | awk '{print $1}')
  [ "$want" = "$got" ] || die "helm checksum mismatch"
  tar -xzf "$WORK/$name" -C "$WORK"
  install_bin "$WORK/linux-${DEB_ARCH}/helm" helm
}

install_terraform() {
  have terraform && { info "terraform present"; return; }
  log "terraform from the HashiCorp apt repo"
  add_keyring https://apt.releases.hashicorp.com/gpg /etc/apt/keyrings/hashicorp-archive-keyring.gpg
  add_apt_source hashicorp "deb [arch=$DEB_ARCH signed-by=/etc/apt/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  apt_install terraform
}

install_terragrunt() {
  have terragrunt && { info "terragrunt present"; return; }
  log "terragrunt from GitHub releases"
  local tag="${TERRAGRUNT_VERSION:-$(gh_latest_tag gruntwork-io/terragrunt)}"
  fetch "$(gh_asset_url gruntwork-io/terragrunt "$tag" "terragrunt_linux_${DEB_ARCH}")" "$WORK/terragrunt"
  install_bin "$WORK/terragrunt" terragrunt
}

install_awscli() {
  have aws && { info "aws present"; return; }
  log "AWS CLI v2 (official zip installer)"
  local name="awscli-exe-linux-${UNAME_ARCH}.zip"
  [ -n "$AWSCLI_VERSION" ] && name="awscli-exe-linux-${UNAME_ARCH}-${AWSCLI_VERSION}.zip"
  fetch "https://awscli.amazonaws.com/$name" "$WORK/awscli.zip"
  unzip -q "$WORK/awscli.zip" -d "$WORK/awscli"
  sudo "$WORK/awscli/aws/install" --update >/dev/null
  info "installed $(aws --version 2>&1 | head -1)"
}

install_k9s() {
  have k9s && { info "k9s present"; return; }
  log "k9s from GitHub releases (.deb)"
  local tag="${K9S_VERSION:-$(gh_latest_tag derailed/k9s)}"
  fetch "$(gh_asset_url derailed/k9s "$tag" "k9s_linux_${DEB_ARCH}.deb")" "$WORK/k9s.deb"
  sudo dpkg -i "$WORK/k9s.deb" >/dev/null
  info "installed k9s $tag"
}

install_kubectx() {
  have kubectx && have kubens && { info "kubectx/kubens present"; return; }
  log "kubectx + kubens from GitHub releases"
  local tag="${KUBECTX_VERSION:-$(gh_latest_tag ahmetb/kubectx)}"
  local tool
  for tool in kubectx kubens; do
    fetch "$(gh_asset_url ahmetb/kubectx "$tag" "${tool}_${tag}_linux_${KUBECTX_ARCH}.tar.gz")" "$WORK/$tool.tgz"
    tar -xzf "$WORK/$tool.tgz" -C "$WORK" "$tool"
    install_bin "$WORK/$tool" "$tool"
  done
}

install_stern() {
  have stern && { info "stern present"; return; }
  log "stern from GitHub releases"
  local tag="${STERN_VERSION:-$(gh_latest_tag stern/stern)}"
  fetch "$(gh_asset_url stern/stern "$tag" "stern_${tag#v}_linux_${DEB_ARCH}.tar.gz")" "$WORK/stern.tgz"
  tar -xzf "$WORK/stern.tgz" -C "$WORK" stern
  install_bin "$WORK/stern" stern
}

install_zoxide() {
  have zoxide && { info "zoxide present"; return; }
  log "zoxide (official install script, into ~/.local/bin)"
  fetch https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh "$WORK/zoxide-install.sh"
  sh "$WORK/zoxide-install.sh" --bin-dir "$LOCAL_BIN" --man-dir "$HOME/.local/share/man" >/dev/null
  info "installed $LOCAL_BIN/zoxide"
}

install_starship() {
  have starship && { info "starship present"; return; }
  log "starship (official install script, into ~/.local/bin)"
  fetch https://starship.rs/install.sh "$WORK/starship-install.sh"
  sh "$WORK/starship-install.sh" --yes --bin-dir "$LOCAL_BIN" >/dev/null
  info "installed $LOCAL_BIN/starship"
}

install_uv() {
  have uv && { info "uv present"; return; }
  log "uv (astral installer, into ~/.local/bin)"
  fetch https://astral.sh/uv/install.sh "$WORK/uv-install.sh"
  UV_NO_MODIFY_PATH=1 UV_INSTALL_DIR="$LOCAL_BIN" sh "$WORK/uv-install.sh" >/dev/null
  info "installed $LOCAL_BIN/uv"
}

install_direnv() {
  have direnv && { info "direnv present"; return; }
  log "direnv (apt)"
  apt_install direnv
}

install_node() {
  if ! have fnm; then
    log "fnm (Node version manager, into $FNM_DIR)"
    fetch https://fnm.vercel.app/install "$WORK/fnm-install.sh"
    bash "$WORK/fnm-install.sh" --install-dir "$FNM_DIR" --skip-shell >/dev/null
    info "installed $FNM_DIR/fnm"
  else
    info "fnm present"
  fi
  export PATH="$FNM_DIR:$PATH"
  eval "$(fnm env --shell bash)"
  if ! fnm list 2>/dev/null | grep -q "v${NODE_VERSION}\."; then
    log "Node ${NODE_VERSION} LTS via fnm"
    fnm install "$NODE_VERSION"
  fi
  fnm default "$NODE_VERSION" >/dev/null
  fnm use "$NODE_VERSION" >/dev/null
  info "node $(node --version), npm $(npm --version)"
}

install_copilot_cli() {
  have copilot && { info "copilot CLI present"; return; }
  log "GitHub Copilot CLI (npm). Package name per docs.github.com: @github/copilot."
  info "Verify against ../copilot/ before relying on it; that folder owns the Copilot setup."
  if ! npm install -g @github/copilot >/dev/null 2>"$WORK/npm.err"; then
    warn "npm install -g @github/copilot failed: $(tail -1 "$WORK/npm.err")"
    warn "If npm complains about ignore-scripts, retry with: npm_config_ignore_scripts=false npm install -g @github/copilot"
    return 0
  fi
  info "installed copilot $(copilot --version 2>/dev/null | head -1)"
}

# --- summary ---------------------------------------------------------------

ver() { # NAME [CMD...] -> one line (no CMD: print the path)
  local name=$1; shift
  local out
  if have "$name"; then
    if [ $# -eq 0 ]; then
      out=$(command -v "$name")
    else
      out=$("$@" 2>&1 | head -1 | cut -c1-70) || out="?"
    fi
    printf '  %-12s %s\n' "$name" "$out"
  else
    printf '  %-12s %s\n' "$name" "(not installed)"
  fi
}

summary() {
  log "Versions"
  ver git git --version
  ver gh gh --version
  ver jq jq --version
  ver yq yq --version
  ver node node --version
  ver npm npm --version
  ver copilot copilot --version
  ver uv uv --version
  ver python3 python3 --version
  if [ "$MODE" = "full" ]; then
    ver kubectl kubectl version --client
    ver helm helm version --short
    ver k9s k9s version -s
    ver kubectx
  ver kubens
    ver terraform terraform version
    ver terragrunt terragrunt --version
    ver aws aws --version
    ver zoxide zoxide --version
    ver starship starship --version
    ver stern stern --version
    ver direnv direnv version
  fi
  echo
  info "Next: bash $(dirname "$0")/install-dotfiles.sh, then open a new terminal."
}

# --- main ------------------------------------------------------------------

preflight
install_apt_basics
install_gh
install_node
install_copilot_cli

if [ "$MODE" = "full" ]; then
  install_yq
  install_kubectl
  install_helm
  install_terraform
  install_terragrunt
  install_awscli
  install_k9s
  install_kubectx
  install_zoxide
  install_starship
  install_uv
  if [ "$EXTRAS" -eq 1 ]; then
    install_stern
    install_direnv
  fi
fi

summary
