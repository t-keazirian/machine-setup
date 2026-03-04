# ========================
# Oh My Zsh + sane defaults
# =========================

# Path to oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Use zsh's path array with automatic de-dupe.
typeset -U path PATH

# Core paths (Apple Silicon Homebrew first)
path=(/opt/homebrew/sbin /opt/homebrew/bin $path)

# Extra tools
path=(/opt/homebrew/opt/vim/bin /opt/homebrew/opt/python@3.13/bin $path)

# Personal scripts
path=("$HOME/Code/machine-setup/scripts" $path)

# MySQL client
path=(/opt/homebrew/opt/mysql@8.0/bin $path)

# --- Completions BEFORE OMZ so compinit sees them ---
fpath=(~/.zsh/completions $fpath)

# =====
# NVM (lazy-load + auto-switch by searching upward for .nvmrc)
# =====
export NVM_DIR="$HOME/.nvm"
typeset -g __NVM_LOADED=0

__load_nvm() {
  # Use a flag — not typeset -f — so the stubs don't fool the check
  [[ $__NVM_LOADED -eq 1 ]] && return 0

  # Remove stubs first so nvm.sh's own `nvm` function definition sticks
  unfunction nvm node npm npx 2>/dev/null

  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
  __NVM_LOADED=1
}

# Lazy stubs — load nvm, then hand off to the real command
nvm()  { __load_nvm || return 1; nvm  "$@"; }
node() { __load_nvm || return 1; node "$@"; }
npm()  { __load_nvm || return 1; npm  "$@"; }
npx()  { __load_nvm || return 1; npx  "$@"; }

# Walk upward from $PWD looking for a .nvmrc (no external processes)
__find_up_nvmrc() {
  local dir="$PWD"
  while true; do
    if [ -f "$dir/.nvmrc" ]; then
      echo "$dir/.nvmrc"
      return 0
    fi
    [ "$dir" = "/" ] && return 1
    dir="${dir:h}"
  done
}

autoload -U add-zsh-hook
typeset -g __NVMRC_LAST_PATH=""

__nvm_auto_switch() {
  local nvmrc_path
  nvmrc_path="$(__find_up_nvmrc)" || nvmrc_path=""

  if [[ -z "$nvmrc_path" ]]; then
    __NVMRC_LAST_PATH=""
    return 0
  fi

  if [[ "$nvmrc_path" = "$__NVMRC_LAST_PATH" ]]; then
    return 0
  fi
  __NVMRC_LAST_PATH="$nvmrc_path"

  __load_nvm || return 0
  [[ $__NVM_LOADED -eq 1 ]] || return 0

  nvm use --silent >/dev/null 2>&1 || nvm install >/dev/null 2>&1
}

add-zsh-hook chpwd __nvm_auto_switch
__nvm_auto_switch

# Theme & OMZ plugins
ZSH_THEME="bira"
plugins=(
  git
  zsh-autosuggestions
  colorize python pylint vundle
  web-search history jsontools macos sdk
  zsh-kubectl-prompt mvn direnv
  zsh-syntax-highlighting
)

# OMZ niceties
zstyle ':omz:update' mode reminder
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

# Load Oh My Zsh (runs compinit + loads plugins)
source "$ZSH/oh-my-zsh.sh"

# =================
# SDKMAN
# =================
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
[[ -n "$SDKMAN_CANDIDATES_DIR" ]] && export JAVA_HOME="$SDKMAN_CANDIDATES_DIR/java/current"
export SDKMAN_AUTO_ENV=true

# ===================
# Aliases & utilities
# ===================
alias m='./mvnw'; compdef _mvn m
alias openz="vim ~/.zshrc"
alias openv="vim ~/.vimrc"
alias openg="vim ~/.gitconfig"
alias update="source ~/.zshrc"
alias ll="ls -aGl"
alias python='/opt/homebrew/opt/python@3.13/bin/python3'
alias brew-maint="$HOME/Code/machine-setup/scripts/brew-maintenance-simple.sh"
alias brew-maint-complex="$HOME/Code/machine-setup/scripts/brew-maintenance.sh"

kafkactx() {/Users/taylorkeazirian/Code/TicketMaster/kafkactx/kafkactx.sh "$@"; }

# kubectl alias + completion
alias k=kubectl
if [[ $commands[kubectl] ]]; then
  source <(kubectl completion zsh)
  compdef k=kubectl
fi

# Prompt (kubectl context on the right)
# RPROMPT='%{$fg_bold[magenta]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}'

# App/env
export ERL_AFLAGS="-kernel shell_history enabled"
export SPRING_MAIN_BANNER_MODE=off

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="$HOME/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
export PATH="$HOME/.local/bin:$PATH"

# Added by Antigravity
export PATH="/Users/taylorkeazirian/.antigravity/antigravity/bin:$PATH"
. "/Users/taylorkeazirian/.deno/env"
