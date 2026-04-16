# ========================
# Oh My Zsh + sane defaults
# =========================

export ZSH="$HOME/.oh-my-zsh"

typeset -U path PATH

# Homebrew prefix — /opt/homebrew on Apple Silicon, /usr/local on Intel
if [[ $(uname -m) == "arm64" ]]; then
  BREW_PREFIX=/opt/homebrew
else
  BREW_PREFIX=/usr/local
fi

path=("$BREW_PREFIX/sbin" "$BREW_PREFIX/bin" $path)

# --- Completions BEFORE OMZ so compinit sees them ---
fpath=(~/.zsh/completions $fpath)

# =====
# NVM
# =====
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# Theme & plugins — change ZSH_THEME to your preference
ZSH_THEME="robbyrussell"
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  web-search
  history
  macos
)

zstyle ':omz:update' mode reminder
COMPLETION_WAITING_DOTS="true"

source "$ZSH/oh-my-zsh.sh"

# ===================
# Aliases
# ===================
alias openz="vim ~/.zshrc"
alias openv="vim ~/.vimrc"
alias openg="vim ~/.gitconfig"
alias update="source ~/.zshrc"
alias ll="ls -aGl"

export PATH="$HOME/.local/bin:$PATH"

# Machine-local overrides (secrets, paths, machine-specific config — not tracked by git)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
