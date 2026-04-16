#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

info() { echo -e "${BOLD}[java]${RESET} $*"; }
ok()   { echo -e "${GREEN}  ✔${RESET} $*"; }
warn() { echo -e "${YELLOW}  ⚠${RESET} $*"; }
skip() { echo -e "  · $* — already done, skipping."; }

ZSH_COMPLETIONS_DIR="$HOME/.zsh/completions"
MAVEN_COMPLETION_DIR="$ZSH_COMPLETIONS_DIR/maven-bash-completion"

mkdir -p "$ZSH_COMPLETIONS_DIR"

info "maven-bash-completion"
if [ -d "$MAVEN_COMPLETION_DIR" ]; then
  skip "maven-bash-completion"
else
  warn "Cloning maven-bash-completion..."
  if git clone https://github.com/juven/maven-bash-completion.git "$MAVEN_COMPLETION_DIR"; then
    ok "maven-bash-completion installed"
  else
    warn "Failed to clone maven-bash-completion."
    exit 1
  fi
fi

echo ""
echo -e "${BOLD}Restart your terminal (or run: source ~/.zshrc) to activate completions.${RESET}"
