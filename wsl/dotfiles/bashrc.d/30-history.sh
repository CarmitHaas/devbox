# shellcheck shell=bash
# 30-history.sh: big, timestamped history shared across Terminal tabs.

HISTSIZE=100000
HISTFILESIZE=200000
HISTCONTROL=ignoreboth:erasedups           # skip duplicates and lines starting with a space
HISTTIMEFORMAT='%F %T  '
HISTIGNORE='ls:ll:la:cd:pwd:exit:clear:history:bg:fg:jobs'
shopt -s histappend                        # append, never overwrite
shopt -s cmdhist                           # multi-line commands as one entry
shopt -s lithist                           # keep the newlines in them
shopt -s checkwinsize                      # LINES/COLUMNS after resizes
shopt -s globstar 2>/dev/null              # ** matches recursively
shopt -s autocd 2>/dev/null                # typing a dir name cd's into it
shopt -s dirspell cdspell 2>/dev/null      # fix small typos in paths

# After every command: append this shell's new lines, then read new lines from other tabs.
__devbox_hist_sync() { history -a; history -n; }
case ";${PROMPT_COMMAND:-};" in
  *";__devbox_hist_sync;"*) ;;
  *) PROMPT_COMMAND="__devbox_hist_sync${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
esac
