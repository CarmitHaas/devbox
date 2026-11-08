# shellcheck shell=bash
# 40-tools.sh: completions, fzf, zoxide, fnm, direnv, starship. Each block is skipped
# when the tool is missing, so this file is safe on a bare system.

# bash-completion (Ubuntu's default .bashrc loads it too; this is a no-op then)
if ! shopt -oq posix && ! type _init_completion >/dev/null 2>&1; then
  # shellcheck disable=SC1091
  [ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion
fi

# Ubuntu package names differ from the upstream binaries
command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1 && alias bat='batcat'
command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1 && alias fd='fdfind'

# Completion scripts are generated once per binary version and cached; evaluating
# kubectl/helm/gh completions on every shell start costs several hundred milliseconds.
__devbox_completion() {
  # usage: __devbox_completion <binary> <command that prints a bash completion script...>
  local name=$1 bin dir cache; shift
  bin=$(command -v "$name" 2>/dev/null) || return 0
  dir="${XDG_CACHE_HOME:-$HOME/.cache}/devbox/completions"
  cache="$dir/$name.bash"
  if [ ! -s "$cache" ] || [ "$bin" -nt "$cache" ]; then
    mkdir -p "$dir"
    if "$@" > "$cache.tmp" 2>/dev/null; then
      mv -f "$cache.tmp" "$cache"
    else
      rm -f "$cache.tmp"
      return 0
    fi
  fi
  # shellcheck disable=SC1090
  . "$cache"
}

__devbox_completion kubectl kubectl completion bash
type __start_kubectl >/dev/null 2>&1 && complete -o default -F __start_kubectl k
__devbox_completion helm helm completion bash
__devbox_completion gh gh completion -s bash
__devbox_completion yq yq shell-completion bash
__devbox_completion k9s k9s completion bash
__devbox_completion stern stern --completion bash
__devbox_completion uv uv generate-shell-completion bash

if command -v terraform >/dev/null 2>&1; then
  complete -C "$(command -v terraform)" terraform
  complete -C "$(command -v terraform)" tf
fi
if command -v terragrunt >/dev/null 2>&1; then
  complete -C "$(command -v terragrunt)" terragrunt
  complete -C "$(command -v terragrunt)" tg
fi
if command -v aws_completer >/dev/null 2>&1; then
  complete -C "$(command -v aws_completer)" aws
fi

# fzf: Ctrl+R history, Ctrl+T files, Alt+C cd
if command -v fzf >/dev/null 2>&1; then
  if command -v fdfind >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fdfind --type d --hidden --follow --exclude .git'
  fi
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --info=inline'
  if fzf --bash >/dev/null 2>&1; then
    eval "$(fzf --bash)"                                    # fzf 0.48+
  else
    # shellcheck disable=SC1091
    [ -r /usr/share/doc/fzf/examples/key-bindings.bash ] && . /usr/share/doc/fzf/examples/key-bindings.bash
    # shellcheck disable=SC1091
    [ -r /usr/share/doc/fzf/examples/completion.bash ] && . /usr/share/doc/fzf/examples/completion.bash
  fi
fi

# zoxide: z <partial-dir>, zi for interactive
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"

# Node: fnm (preferred) or nvm, whichever is installed
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell bash)"
elif [ -s "$HOME/.nvm/nvm.sh" ]; then
  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1091
  . "$NVM_DIR/nvm.sh"
fi

# direnv: per-directory env (.envrc), opt-in with `direnv allow`
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook bash)"

# uv-managed Python tools land here
[ -d "$HOME/.local/share/uv/tools" ] && export UV_TOOL_BIN_DIR="$HOME/.local/bin"

# starship prompt: last, so it owns PROMPT_COMMAND
if command -v starship >/dev/null 2>&1; then
  export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
  eval "$(starship init bash)"
fi
