#!/usr/bin/env bash
# Link configs from this repo into their expected locations.
# Safe to re-run: existing real files are backed up as *.bak, existing links are replaced.
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

link zsh/.zshrc              "$HOME/.zshrc"
link ghostty/config          "$HOME/.config/ghostty/config"
link starship/starship.toml  "$HOME/.config/starship.toml"

if [ "${1:-}" = "--brew" ]; then
  command -v brew >/dev/null || { echo "Homebrew not installed: https://brew.sh"; exit 1; }
  brew bundle --file="$SETUP_DIR/Brewfile"
fi

echo "done. open a new terminal to load changes."
