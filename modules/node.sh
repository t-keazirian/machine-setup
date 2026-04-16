#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

info() { echo -e "${BOLD}[node]${RESET} $*"; }
ok()   { echo -e "${GREEN}  ✔${RESET} $*"; }
warn() { echo -e "${YELLOW}  ⚠${RESET} $*"; }
skip() { echo -e "  · $* — already done, skipping."; }

info "NVM + Node LTS"

export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"

if [ "$(uname -m)" = "arm64" ]; then
  NVM_SH="/opt/homebrew/opt/nvm/nvm.sh"
  NVM_SH_FALLBACK="/opt/homebrew/opt/nvm/libexec/nvm.sh"
else
  NVM_SH="/usr/local/opt/nvm/nvm.sh"
  NVM_SH_FALLBACK="/usr/local/opt/nvm/libexec/nvm.sh"
fi

if [ ! -f "$NVM_SH" ] && [ -f "$NVM_SH_FALLBACK" ]; then
  NVM_SH="$NVM_SH_FALLBACK"
fi

if [ ! -f "$NVM_SH" ]; then
  echo -e "${YELLOW}  ⚠ NVM shell script not found at $NVM_SH.${RESET}"
  echo "  Is nvm installed? Run: brew install nvm"
  exit 1
fi

# shellcheck source=/dev/null
source "$NVM_SH"

if nvm ls 'lts/*' &>/dev/null; then
  skip "Node LTS"
else
  warn "Installing Node LTS via NVM..."
  nvm install --lts
  nvm alias default 'lts/*'
  ok "Node LTS installed and set as default"
fi
