#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

info() { echo -e "${BOLD}[vim]${RESET} $*"; }
ok()   { echo -e "${GREEN}  ✔${RESET} $*"; }
warn() { echo -e "${YELLOW}  ⚠${RESET} $*"; }
skip() { echo -e "  · $* — already done, skipping."; }

PLUG_FILE="$HOME/.vim/autoload/plug.vim"

mkdir -p "$HOME/.vim/undodir"
mkdir -p "$HOME/.vim/autoload"

# Pre-flight: vim must be installed
if ! command -v vim &>/dev/null; then
  warn "vim not found. Install it first: brew install vim"
  exit 1
fi

# vim-plug
info "vim-plug"
if [ -f "$PLUG_FILE" ]; then
  skip "vim-plug"
else
  warn "Installing vim-plug..."
  if curl -fLo "$PLUG_FILE" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim; then
    ok "vim-plug installed"
  else
    warn "Failed to install vim-plug."
    exit 1
  fi
fi

# Vim plugins
info "Vim plugins"
warn "Running :PlugInstall in Vim (this may take a moment)..."
if vim +PlugInstall +qall 2>/dev/null; then
  ok "Vim plugins installed"
else
  warn "Vim plugin install had errors (may be fine — check manually with :PlugInstall)"
fi
