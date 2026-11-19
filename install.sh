#!/usr/bin/env bash
# Set up configs from this repo.
#   zsh:              ~/.zshrc is a real file on this machine that sources zsh/.zshrc from the repo.
#                     Lines below the source line are machine-specific and never touch git.
#   git:              ~/.gitconfig stays local and gets an include of git/config from the repo.
#   ghostty/starship: symlinked into place.
# Safe to re-run: nothing is overwritten without a *.bak backup.
set -euo pipefail

SETUP_DIR="$(cd "$(dirname "$0")" && pwd)"

link() {
  local src="$SETUP_DIR/$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.bak"
    echo "backed up $dest -> $dest.bak"
  fi
  ln -sfn "$src" "$dest"
  echo "linked $dest -> $src"
}

# ~/.zshrc: a local file whose first lines load the shared config from this repo.
setup_zshrc() {
  local rc="$HOME/.zshrc" local_old="$HOME/.zshrc.local"
  local src_line="source \"${SETUP_DIR/#$HOME/\$HOME}/zsh/.zshrc\""
  local stub="# Shared config from the setup repo (edit it there, then commit and push).
$src_line

# Machine-specific settings go below this line. They are not in git."

  # Already set up: leave it alone.
  if [ -f "$rc" ] && [ ! -L "$rc" ] && grep -qF "$src_line" "$rc"; then
    echo "ok     $rc already sources the repo"
    return
  fi

  local existing=""
  if [ -L "$rc" ]; then
    rm "$rc"                                   # old setup: symlink into the repo
  elif [ -f "$rc" ]; then
    cp "$rc" "$rc.bak"
    echo "backed up $rc -> $rc.bak"
    existing="$(cat "$rc")"                    # keep what was there, below the stub
  fi

  {
    printf '%s\n' "$stub"
    [ -n "$existing" ] && printf '\n%s\n' "$existing"
    # Old setup kept machine-specific lines in ~/.zshrc.local; fold them in.
    if [ -f "$local_old" ]; then
      printf '\n# Moved from ~/.zshrc.local\n'
      cat "$local_old"
    fi
  } > "$rc"

  if [ -f "$local_old" ]; then
    mv "$local_old" "$local_old.bak"
    echo "moved  $local_old into $rc (old file kept as $local_old.bak)"
  fi
  echo "wrote  $rc (sources $SETUP_DIR/zsh/.zshrc)"
}

# ~/.gitconfig: keep it local (name, email, work settings) and include the shared git/config.
setup_gitconfig() {
  local inc="${SETUP_DIR/#$HOME/~}/git/config"
  if git config --global --get-all include.path 2>/dev/null | grep -qxF "$inc"; then
    echo "ok     ~/.gitconfig already includes the repo"
    return
  fi
  git config --global --add include.path "$inc"
  echo "added  include of $inc to ~/.gitconfig"
}

setup_zshrc
setup_gitconfig
link ghostty/config         "$HOME/.config/ghostty/config"
link starship/starship.toml  "$HOME/.config/starship.toml"

if [ "${1:-}" = "--brew" ]; then
  command -v brew >/dev/null || { echo "Homebrew not installed: https://brew.sh"; exit 1; }
  brew bundle --file="$SETUP_DIR/Brewfile"
fi

echo "done. open a new terminal to load changes."
