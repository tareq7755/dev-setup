# Shared zsh config, loaded by ~/.zshrc on every machine.
# Machine-specific settings go in ~/.zshrc itself, below its `source` line.

eval "$(/opt/homebrew/bin/brew shellenv)"

# PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/Development/flutter/bin"

### GIT auto complete ###
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select   # arrow-key menu on tab
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'   # case-insensitive: doc<Tab> -> Documents

# History
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS   # running a command again drops its older copy
setopt HIST_REDUCE_BLANKS     # trim extra spaces before saving
setopt EXTENDED_HISTORY       # save a timestamp with each command

# Tools
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"   # adds `z` and `zi`; `cd` untouched
source <(fzf --zsh)         # ctrl+r fuzzy history, ctrl+t file picker, opt+c fuzzy cd

export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers {} | head -200'"

# New commands only (existing ones like ls/cat/cd untouched)
alias ll='eza -lah --icons --git --group-directories-first'
alias lt='eza --tree --level=2 --icons --git-ignore'

# yazi file manager: cd into last dir on quit
function y() {
  local tmp="$(mktemp -t yazi-cwd.XXXXXX)" cwd
  yazi "$@" --cwd-file="$tmp"
  cwd="$(cat -- "$tmp")"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

# Plugins (syntax-highlighting before history-substring-search, per its docs)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# Up/Down: only cycle through past commands that start with what's typed
HISTORY_SUBSTRING_SEARCH_PREFIXED=1
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OA' history-substring-search-up     # same keys in application mode
bindkey '^[OB' history-substring-search-down

# Shortcut reminders, from zsh/keys.txt next to this file
KEYS_FILE="${${(%):-%x}:A:h}/keys.txt"

# `keys`: print the cheat sheet (section names in bold)
keys() {
  awk '/^$/ { next } /^[^ ]/ { printf "\n\033[1m%s\033[0m\n", $0; next } { print }' "$KEYS_FILE"
  echo
}

# One random tip per new tab. To turn it off, delete this line.
[[ -o interactive && -t 1 && -r $KEYS_FILE ]] && awk 'BEGIN { srand() }
  /^   / { a[++n] = $0 }
  END { if (n) { l = a[int(rand() * n) + 1]; sub(/^ +/, "", l); sub(/  +/, " — ", l)
        printf "\033[2mtip: %s  (all: keys)\033[0m\n", l } }' "$KEYS_FILE"
