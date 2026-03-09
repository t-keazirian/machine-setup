#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/Code/machine-setup"
DOTFILES_REPO="git@github.com:t-keazirian/machine-setup.git"

# ── Color helpers ──────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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
info "1/12  Xcode Command Line Tools"
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
info "2/12  Homebrew"
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
info "3/12  Dotfiles repo"
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
info "4/12  Homebrew bundle"
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

# ── 5. Oh My Zsh ──────────────────────────────────────────────────────────────
info "5/12  Oh My Zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
  skip "Oh My Zsh"
else
  warn "Installing Oh My Zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ok "Oh My Zsh installed"
  done_item "Oh My Zsh"
fi

OMZ_PLUGINS="$HOME/.oh-my-zsh/custom/plugins"

if [ -d "$OMZ_PLUGINS/zsh-autosuggestions" ]; then
  skip "zsh-autosuggestions plugin"
else
  git clone https://github.com/zsh-users/zsh-autosuggestions "$OMZ_PLUGINS/zsh-autosuggestions"
  ok "zsh-autosuggestions installed"
  done_item "zsh-autosuggestions plugin"
fi

if [ -d "$OMZ_PLUGINS/zsh-syntax-highlighting" ]; then
  skip "zsh-syntax-highlighting plugin"
else
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$OMZ_PLUGINS/zsh-syntax-highlighting"
  ok "zsh-syntax-highlighting installed"
  done_item "zsh-syntax-highlighting plugin"
fi

# ── 6. Dotfile symlinks (bootstrap.sh) ────────────────────────────────────────
info "6/12  Dotfile symlinks"
bash "$DOTFILES_DIR/bootstrap.sh"
done_item "Dotfile symlinks created"

# ── 7. Git identity ───────────────────────────────────────────────────────────
info "7/12  Git identity"
GIT_NAME="$(git config --global user.name 2>/dev/null || true)"
GIT_EMAIL="$(git config --global user.email 2>/dev/null || true)"

if [[ "$GIT_NAME" == "Your Name" || -z "$GIT_NAME" || "$GIT_EMAIL" == "you@example.com" || -z "$GIT_EMAIL" ]]; then
  warn "Git identity is not set. Enter your details (written to ~/.gitconfig via symlink)."
  read -rp "  Full name:  " input_name
  read -rp "  Email:      " input_email
  git config --global user.name  "$input_name"
  git config --global user.email "$input_email"
  ok "Git identity set: $input_name <$input_email>"
  warn "Note: ~/.gitconfig is symlinked to this repo. If you commit, your name/email will be in the diff — review before pushing."
  done_item "Git identity configured"
else
  skip "Git identity ($GIT_NAME <$GIT_EMAIL>)"
fi

# ── 8. NVM + Node (LTS) ───────────────────────────────────────────────────────
info "8/12  NVM + Node LTS"
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

if [ -f "$NVM_SH" ]; then
  # shellcheck source=/dev/null
  source "$NVM_SH"
  if nvm ls 'lts/*' &>/dev/null; then
    skip "Node LTS"
  else
    warn "Installing Node LTS via NVM..."
    nvm install --lts
    nvm alias default 'lts/*'
    ok "Node LTS installed and set as default"
    done_item "Node LTS (NVM)"
  fi
else
  warn "NVM shell script not found at $NVM_SH. Is nvm installed via Homebrew?"
  manual_item "Install Node: source $NVM_SH && nvm install --lts && nvm alias default 'lts/*'"
fi

# ── 8. SDKMAN ─────────────────────────────────────────────────────────────────
info "9/12  SDKMAN"
if [ -d "$HOME/.sdkman" ]; then
  skip "SDKMAN"
else
  warn "Installing SDKMAN..."
  curl -s "https://get.sdkman.io" | bash
  ok "SDKMAN installed"
  done_item "SDKMAN"
fi
manual_item "Open a new terminal and run: sdk install java"

# ── 9. Vundle + Vim plugins ────────────────────────────────────────────────────
info "10/12 Vundle + Vim plugins"
VUNDLE_DIR="$HOME/.vim/bundle/Vundle.vim"
if [ -d "$VUNDLE_DIR" ]; then
  skip "Vundle"
else
  warn "Cloning Vundle..."
  mkdir -p "$HOME/.vim/bundle"
  if git clone https://github.com/VundleVim/Vundle.vim.git "$VUNDLE_DIR"; then
    ok "Vundle cloned"
    done_item "Vundle"
  else
    warn "Failed to clone Vundle (SSH keys may not be configured yet)."
    manual_item "Clone Vundle: git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim"
  fi
fi

mkdir -p "$HOME/.vim/undodir"

if [ -d "$VUNDLE_DIR" ]; then
  warn "Running :PluginInstall in Vim (this may take a moment)..."
  if vim -u "$HOME/.vimrc" +PluginInstall +qall 2>/dev/null; then
    ok "Vim plugins installed"
    done_item "Vim plugins (Vundle)"
  else
    warn "Vim plugin install failed or had errors (may be fine; check manually)."
    manual_item "Open vim and run :PluginInstall after SSH keys are configured"
  fi
else
  manual_item "Open vim and run :PluginInstall after SSH keys are configured"
fi

# ── 10. scripts/ permissions ──────────────────────────────────────────────────
info "11/12 scripts/ permissions"
SCRIPTS_SRC="$DOTFILES_DIR/scripts"

chmod +x "$SCRIPTS_SRC"/brew-maintenance.sh \
         "$SCRIPTS_SRC"/brew-maintenance-simple.sh \
         "$SCRIPTS_SRC"/git-pull-all \
         "$SCRIPTS_SRC"/who-is-listening
ok "scripts/ is executable (on PATH via .zshrc)"

# ── 11. ~/.zsh/completions (maven-bash-completion) ────────────────────────────
info "12/12 zsh completions"
ZSH_COMPLETIONS_DIR="$HOME/.zsh/completions"
mkdir -p "$ZSH_COMPLETIONS_DIR"

MAVEN_COMPLETION_DIR="$ZSH_COMPLETIONS_DIR/maven-bash-completion"
if [ -d "$MAVEN_COMPLETION_DIR" ]; then
  skip "maven-bash-completion"
else
  warn "Cloning maven-bash-completion..."
  if git clone https://github.com/juven/maven-bash-completion.git "$MAVEN_COMPLETION_DIR"; then
    ok "maven-bash-completion installed"
    done_item "maven-bash-completion"
  else
    warn "Failed to clone maven-bash-completion."
    manual_item "Clone maven completion: git clone https://github.com/juven/maven-bash-completion.git ~/.zsh/completions/maven-bash-completion"
  fi
fi

# ── 12. Claude Code ───────────────────────────────────────────────────────────
info "13/13 Claude Code"
if command -v claude &>/dev/null; then
  skip "Claude Code"
else
  warn "Installing Claude Code..."
  if curl -fsSL https://claude.ai/install.sh | bash; then
    ok "Claude Code installed"
    done_item "Claude Code"
  else
    warn "Claude Code install failed."
    manual_item "Install Claude Code: curl -fsSL https://claude.ai/install.sh | bash"
  fi
fi
manual_item "Authenticate Claude Code: run 'claude' and log in"

# ── Summary ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}══════════════════════════════════════════${RESET}"
echo -e "${BOLD}  Setup Summary${RESET}"
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
echo -e "${BOLD}Restart your terminal (or run: source ~/.zshrc)${RESET}"
