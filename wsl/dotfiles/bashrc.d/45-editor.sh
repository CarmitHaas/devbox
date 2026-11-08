# shellcheck shell=bash
# 45-editor.sh: EDITOR and VISUAL. git, kubectl edit, crontab and the rest use these.
# VS Code when its `code` shim is on the PATH (WSL integration), vim otherwise.
# git's own core.editor (gitconfig.template) takes precedence for git.
if command -v code >/dev/null 2>&1; then
  export VISUAL='code --wait'
else
  export VISUAL='vim'
fi
export EDITOR='vim'
