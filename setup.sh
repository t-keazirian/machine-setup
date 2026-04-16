#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/Code/machine-setup"
DOTFILES_REPO="git@github.com:t-keazirian/machine-setup.git"

# ── Color helpers ──────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

info()   { echo -e "${BOLD}[setup]${RESET} $*"; }
ok()     { echo -e "${GREEN}  ✔${RESET} $*"; }
warn()   { echo -e "${YELLOW}  ⚠${RESET} $*"; }
skip()   { echo -e "  · $* — already done, skipping."; }

DONE=()
MANUAL=()

done_item()   { DONE+=("$*"); }
manual_item() { MANUAL+=("$*"); }

# ── 1. Xcode Command Line Tools ────────────────────────────────────────────────
# Note: this is Xcode CLT (~500MB), not the full Xcode IDE (~10GB).
# Required by Homebrew. Provides git, make, clang.
info "1/5  Xcode Command Line Tools"
if xcode-select -p &>/dev/null; then
  skip "Xcode CLT"
else
  warn "Xcode CLT not found. Triggering install dialog..."
  xcode-select --install
  echo "Waiting for Xcode CLT installation to complete..."
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
  ok "Xcode CLT installed"
  done_item "Xcode Command Line Tools"
fi

# ── 2. Homebrew ────────────────────────────────────────────────────────────────
info "2/5  Homebrew"
if command -v brew &>/dev/null; then
  skip "Homebrew"
else
  warn "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add Homebrew to PATH (path differs by architecture)
  if [ "$(uname -m)" = "arm64" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  ok "Homebrew installed"
  done_item "Homebrew"
fi

# ── 3. Clone dotfiles ──────────────────────────────────────────────────────────
info "3/5  Dotfiles repo"
if [ -d "$DOTFILES_DIR/.git" ]; then
  skip "Dotfiles repo at $DOTFILES_DIR"
else
  warn "Cloning dotfiles..."
  mkdir -p "$(dirname "$DOTFILES_DIR")"
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  ok "Dotfiles cloned to $DOTFILES_DIR"
  done_item "Dotfiles cloned"
fi

# ── 4. Homebrew bundle ─────────────────────────────────────────────────────────
info "4/5  Homebrew bundle"
if brew bundle check --file="$DOTFILES_DIR/Brewfile" &>/dev/null; then
  skip "All Brewfile packages"
else
  warn "Installing packages from Brewfile..."
  if brew bundle install --file="$DOTFILES_DIR/Brewfile"; then
    ok "Brew bundle complete"
    done_item "Homebrew packages installed"
  else
    warn "brew bundle had failures. Continuing."
    manual_item "Rerun 'brew bundle install --file=$DOTFILES_DIR/Brewfile' to retry"
  fi
fi

# ── 5. Git identity ───────────────────────────────────────────────────────────
info "5/5  Git identity"
GIT_NAME="$(git config --global user.name 2>/dev/null || true)"
GIT_EMAIL="$(git config --global user.email 2>/dev/null || true)"

if [[ "$GIT_NAME" == "Your Name" || -z "$GIT_NAME" || "$GIT_EMAIL" == "you@example.com" || -z "$GIT_EMAIL" ]]; then
  warn "Git identity is not set. Enter your details."
  read -rp "  Full name:  " input_name
  read -rp "  Email:      " input_email
  git config --global user.name  "$input_name"
  git config --global user.email "$input_email"
  ok "Git identity set: $input_name <$input_email>"
  done_item "Git identity configured"
else
  skip "Git identity ($GIT_NAME <$GIT_EMAIL>)"
fi

# ── Summary ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}══════════════════════════════════════════${RESET}"
echo -e "${BOLD}  Setup complete${RESET}"
echo -e "${BOLD}══════════════════════════════════════════${RESET}"

if [ ${#DONE[@]} -gt 0 ]; then
  echo -e "\n${GREEN}Completed:${RESET}"
  for item in "${DONE[@]}"; do
    echo -e "  ${GREEN}✔${RESET} $item"
  done
fi

if [ ${#MANUAL[@]} -gt 0 ]; then
  echo -e "\n${YELLOW}Manual steps required:${RESET}"
  for item in "${MANUAL[@]}"; do
    echo -e "  ${YELLOW}▶${RESET} $item"
  done
fi

echo ""
echo -e "${BOLD}Next — pick the modules you want:${RESET}"
echo ""
echo "  bash $DOTFILES_DIR/modules/zsh.sh    # Oh My Zsh + plugins"
echo "  bash $DOTFILES_DIR/modules/node.sh   # NVM + Node LTS"
echo ""
echo "See README.md for dotfile setup."
echo ""
echo -e "${BOLD}Restart your terminal (or run: source ~/.zshrc)${RESET}"
