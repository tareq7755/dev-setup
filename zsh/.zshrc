# Shared zsh config, loaded by ~/.zshrc on every machine.
# Machine-specific settings go in ~/.zshrc itself, below its `source` line.

eval "$(/opt/homebrew/bin/brew shellenv)"

# PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/Development/flutter/bin"

### GIT auto complete ###
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select   # arrow-key menu on tab

# History
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# Tools
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"   # adds `z` and `zi`; `cd` untouched
source <(fzf --zsh)         # ctrl+r fuzzy history, ctrl+t file picker, alt+c fuzzy cd

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

# Plugins (syntax-highlighting must be last)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
