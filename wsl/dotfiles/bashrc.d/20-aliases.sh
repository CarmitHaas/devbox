# shellcheck shell=bash
# 20-aliases.sh: short names for the things typed a hundred times a day.

# listing and moving around
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ports='ss -tulpn'
alias path='tr ":" "\n" <<< "$PATH"'

mkcd() { mkdir -p -- "$1" && cd -- "$1" || return; }

# kubernetes (completion for k is wired in 40-tools.sh)
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods -A'
alias kgs='kubectl get svc'
alias kgn='kubectl get nodes -o wide'
alias kga='kubectl get all'
alias kd='kubectl describe'
alias kl='kubectl logs -f'
alias kx='kubectl exec -it'
alias kaf='kubectl apply -f'
alias kdel='kubectl delete'
alias kctx='kubectx'
alias kns='kubens'
alias kcur='kubectl config current-context'

# infra
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfv='terraform validate'
alias tg='terragrunt'
alias tgp='terragrunt plan'
alias tga='terragrunt apply'
alias awsid='aws sts get-caller-identity'

# git (more in 60-git.sh)
alias g='git'

# python
alias venv='python3 -m venv .venv && . .venv/bin/activate'
alias act='. .venv/bin/activate'

# Windows interop (only useful inside WSL; harmless elsewhere)
if [ -d /mnt/c/Windows ]; then
  alias clip='clip.exe'
  alias pbcopy='clip.exe'
  pbpaste() { powershell.exe -NoProfile -Command Get-Clipboard | tr -d '\r'; }
  open() { explorer.exe "$(wslpath -w "${1:-.}")" 2>/dev/null || true; }
  winhome() { cd "/mnt/c/Users/${WINUSER:?WINUSER is not set}" || return; }
  alias wdl='cd "/mnt/c/Users/${WINUSER:?}/Downloads"'
  alias winpath='wslpath -w'
  alias pwsh-win='powershell.exe -NoProfile'
fi
