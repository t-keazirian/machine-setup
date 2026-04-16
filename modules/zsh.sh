#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

info() { echo -e "${BOLD}[zsh]${RESET} $*"; }
ok()   { echo -e "${GREEN}  ✔${RESET} $*"; }
warn() { echo -e "${YELLOW}  ⚠${RESET} $*"; }
skip() { echo -e "  · $* — already done, skipping."; }

# Oh My Zsh
info "Oh My Zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
  skip "Oh My Zsh"
else
  warn "Installing Oh My Zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ok "Oh My Zsh installed"
fi

OMZ_PLUGINS="$HOME/.oh-my-zsh/custom/plugins"
mkdir -p "$OMZ_PLUGINS"

# zsh-autosuggestions
info "zsh-autosuggestions"
if [ -d "$OMZ_PLUGINS/zsh-autosuggestions" ]; then
  skip "zsh-autosuggestions"
else
  warn "Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$OMZ_PLUGINS/zsh-autosuggestions"
  ok "zsh-autosuggestions installed"
fi

# zsh-syntax-highlighting
info "zsh-syntax-highlighting"
if [ -d "$OMZ_PLUGINS/zsh-syntax-highlighting" ]; then
  skip "zsh-syntax-highlighting"
else
  warn "Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$OMZ_PLUGINS/zsh-syntax-highlighting"
  ok "zsh-syntax-highlighting installed"
fi

echo ""
echo -e "${BOLD}Restart your terminal (or run: source ~/.zshrc)${RESET}"
