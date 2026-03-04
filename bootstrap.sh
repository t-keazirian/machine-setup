#!/usr/bin/env bash

# if any command exits with a non-zero status, stop the script immediately
set -e

DOTFILES_DIR="$HOME/Code/machine-setup"
TIMESTAMP="$(date '+%Y-%m-%d_%H-%M-%S')"

echo "[$TIMESTAMP] Bootstrapping dotfiles from $DOTFILES_DIR"

# --- sanity check (fail first) ---
if [ ! -d "$DOTFILES_DIR/.git" ]; then
  echo "Error: dotfiles repo not found at $DOTFILES_DIR"
  echo "Clone it first, then re-run this script."
  exit 1
fi

# --- backup existing files ---
backup() {
  local file="$1"
  if [ -e "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
    echo "[$TIMESTAMP] Backing up $file"
    mv "$HOME/$file" "$HOME/$file.pre-bootstrap.$TIMESTAMP"
  fi
}

backup ".zshrc"
backup ".vimrc"
backup ".gitconfig"
backup ".gitignore-global"

# --- create symlinks ---
link() {
  local src="$1"
  local dest="$2"

  echo "Linking $dest -> $src"
  ln -sf "$src" "$dest"
}

if [ "$(uname -m)" = "arm64" ]; then
  link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
else
  link "$DOTFILES_DIR/.zshrc-intel" "$HOME/.zshrc"
fi
link "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"
link "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
link "$DOTFILES_DIR/.gitignore-global" "$HOME/.gitignore-global"

# --- configure git ---
echo "Configuring git global excludes file"
git config --global core.excludesfile "$HOME/.gitignore-global"

echo "[$TIMESTAMP] Bootstrap complete."
echo "[$TIMESTAMP] Restart your terminal or run: source ~/.zshrc"
