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
info "1/11  Xcode Command Line Tools"
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
info "2/11  Homebrew"
if command -v brew &>/dev/null; then
  skip "Homebrew"
else
  warn "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add Homebrew to PATH for Apple Silicon
  eval "$(/opt/homebrew/bin/brew shellenv)"
  ok "Homebrew installed"
  done_item "Homebrew"
fi

# ── 3. Clone dotfiles ──────────────────────────────────────────────────────────
info "3/11  Dotfiles repo"
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
info "4/11  Homebrew bundle"
if brew bundle check --file="$DOTFILES_DIR/Brewfile" &>/dev/null; then
  skip "All Brewfile packages"
else
  warn "Installing packages from Brewfile..."
  if brew bundle install --file="$DOTFILES_DIR/Brewfile" --no-lock; then
    ok "Brew bundle complete"
    done_item "Homebrew packages installed"
  else
    warn "brew bundle had failures. Continuing."
    manual_item "Rerun 'brew bundle install --file=$DOTFILES_DIR/Brewfile --no-lock' to retry"
  fi
fi

# ── 5. Oh My Zsh ──────────────────────────────────────────────────────────────
info "5/11  Oh My Zsh"
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
info "6/11  Dotfile symlinks"
bash "$DOTFILES_DIR/bootstrap.sh"
done_item "Dotfile symlinks created"

# ── 7. NVM + Node (LTS) ───────────────────────────────────────────────────────
info "7/11  NVM + Node LTS"
export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"

NVM_SH="/opt/homebrew/opt/nvm/nvm.sh"
if [ ! -f "$NVM_SH" ]; then
  NVM_SH="/opt/homebrew/opt/nvm/libexec/nvm.sh"
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
  manual_item "Install Node: source /opt/homebrew/opt/nvm/nvm.sh && nvm install --lts && nvm alias default 'lts/*'"
fi

# ── 8. SDKMAN ─────────────────────────────────────────────────────────────────
info "8/11  SDKMAN"
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
info "9/11  Vundle + Vim plugins"
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
info "10/11 scripts/ permissions"
SCRIPTS_SRC="$DOTFILES_DIR/scripts"

chmod +x "$SCRIPTS_SRC"/brew-maintenance.sh \
         "$SCRIPTS_SRC"/brew-maintenance-simple.sh \
         "$SCRIPTS_SRC"/git-pull-all \
         "$SCRIPTS_SRC"/who-is-listening
ok "scripts/ is executable (on PATH via .zshrc)"

# ── 11. ~/.zsh/completions (maven-bash-completion) ────────────────────────────
info "11/11 zsh completions"
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
