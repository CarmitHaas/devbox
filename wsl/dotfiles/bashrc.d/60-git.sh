# shellcheck shell=bash
# 60-git.sh: git shell aliases and helpers. The git-side aliases (git st, git lg, ...)
# live in gitconfig.template.

alias gs='git status -sb'
alias ga='git add'
alias gaa='git add -A'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend --no-edit'
alias gco='git checkout'
alias gsw='git switch'
alias gswc='git switch -c'
alias gb='git branch -vv'
alias gba='git branch -a'
alias gd='git diff'
alias gds='git diff --staged'
alias gl="git log --graph --pretty=format:'%C(auto)%h%d %s %C(dim)%an %ar' --abbrev-commit -20"
alias gla="git log --graph --pretty=format:'%C(auto)%h%d %s %C(dim)%an %ar' --abbrev-commit --all"
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull'
alias gf='git fetch --all --prune'
alias gst='git stash'
alias gstp='git stash pop'
alias gwip='git add -A && git commit -m wip --no-verify'
alias gundo='git reset --soft HEAD~1'

# clone into ~/src/<name> and cd there
gcl() {
  local url=$1 name
  [ -n "$url" ] || { echo "usage: gcl <url> [name]"; return 1; }
  name=${2:-$(basename "${url%.git}")}
  mkdir -p "$HOME/src"
  git clone "$url" "$HOME/src/$name" && cd "$HOME/src/$name" || return
}

# cd to the repo root
groot() { cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || return; }

# delete local branches already merged into the current one (keeps main/master/develop)
gbclean() {
  git branch --merged | grep -vE '^\*|^\s*(main|master|develop)$' | xargs -r git branch -d
}

# make the g alias complete like git
if [ -r /usr/share/bash-completion/completions/git ]; then
  # shellcheck disable=SC1091
  . /usr/share/bash-completion/completions/git
  type __git_complete >/dev/null 2>&1 && __git_complete g __git_main
fi
