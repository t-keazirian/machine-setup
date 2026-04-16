# machine-setup Public Repo Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Strip `machine-setup` down to a generic, shareable Mac dev setup starter by removing personal tooling, eliminating auto-symlinks, and introducing opt-in modules.

**Architecture:** `setup.sh` becomes a 5-step universal core. Personal/opinionated steps move to standalone `modules/` scripts. Files that don't belong in a public starter are deleted. Dotfiles stay as reference material with symlink instructions in the README.

**Tech Stack:** Bash, Homebrew, git

---

## File Map

**Created:**
- `modules/zsh.sh` — Oh My Zsh + zsh-autosuggestions + zsh-syntax-highlighting
- `modules/node.sh` — NVM + Node LTS
- `modules/vim.sh` — vim-plug + Vim plugins
- `modules/java.sh` — maven-bash-completion

**Modified:**
- `setup.sh` — stripped to 5 core steps
- `.zshrc` — remove `brewi` function, `brew-maint` aliases
- `.zshrc-intel` — same removals
- `README.md` — full rewrite for public audience

**Deleted:**
- `bootstrap.sh`
- `scripts/brew-maintenance.sh`
- `scripts/brew-maintenance-simple.sh`
- `scripts/git-pull-all`
- `scripts/install-claude-plugins.sh`
- `scripts/who-is-listening`
- `iterm2/com.googlecode.iterm2.plist`
- `CURRENT.md`
- `.gitconfig`
- `.ideavimrc`
- `vscode-settings.json`
- `docs/ideavim.md`
- `docs/vscode.md`
- `docs/vscode-extensions.md`
- `docs/optional-installs.md`
- `docs/superpowers/` (entire directory, including this plan — last task)

**Branch:** `chore/public-repo-cleanup` (already created)

---

## Task 1: Remove personal and stale files

**Files:** All items in the "Deleted" list above

- [ ] **Step 1: git rm all files being removed**

```bash
git rm bootstrap.sh CURRENT.md .gitconfig .ideavimrc vscode-settings.json
git rm scripts/brew-maintenance.sh scripts/brew-maintenance-simple.sh
git rm scripts/git-pull-all scripts/install-claude-plugins.sh scripts/who-is-listening
git rm iterm2/com.googlecode.iterm2.plist
git rm docs/ideavim.md docs/vscode.md docs/vscode-extensions.md docs/optional-installs.md
```

- [ ] **Step 2: Verify nothing unexpected was removed**

```bash
git status
```

Expected: all listed files shown as `deleted`, no surprises. `setup.sh`, `.zshrc`, `.vimrc`, `.zshrc-intel`, `.gitignore-global`, `Brewfile`, `README.md`, `docs/setup.md` still present.

- [ ] **Step 3: Commit**

```bash
git commit -m "chore: remove personal and stale files from public repo"
```

---

## Task 2: Strip setup.sh to 5 core steps

**Files:**
- Modify: `setup.sh`

- [ ] **Step 1: Verify syntax check on current file passes**

```bash
bash -n setup.sh
```

Expected: no output (no errors).

- [ ] **Step 2: Replace setup.sh with the stripped version**

Replace the entire contents of `setup.sh` with:

```bash
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
echo "  bash modules/zsh.sh    # Oh My Zsh + plugins"
echo "  bash modules/node.sh   # NVM + Node LTS"
echo "  bash modules/vim.sh    # vim-plug + Vim plugins"
echo "  bash modules/java.sh   # maven-bash-completion"
echo ""
echo "See README.md for dotfile setup."
echo ""
echo -e "${BOLD}Restart your terminal (or run: source ~/.zshrc)${RESET}"
```

- [ ] **Step 3: Verify syntax**

```bash
bash -n setup.sh
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
git add setup.sh
git commit -m "chore: strip setup.sh to 5 core steps"
```

---

## Task 3: Create modules/zsh.sh

**Files:**
- Create: `modules/zsh.sh`

- [ ] **Step 1: Create modules/ directory and write zsh.sh**

```bash
mkdir -p modules
```

Write `modules/zsh.sh`:

```bash
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

# zsh-autosuggestions
info "zsh-autosuggestions"
if [ -d "$OMZ_PLUGINS/zsh-autosuggestions" ]; then
  skip "zsh-autosuggestions"
else
  git clone https://github.com/zsh-users/zsh-autosuggestions "$OMZ_PLUGINS/zsh-autosuggestions"
  ok "zsh-autosuggestions installed"
fi

# zsh-syntax-highlighting
info "zsh-syntax-highlighting"
if [ -d "$OMZ_PLUGINS/zsh-syntax-highlighting" ]; then
  skip "zsh-syntax-highlighting"
else
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$OMZ_PLUGINS/zsh-syntax-highlighting"
  ok "zsh-syntax-highlighting installed"
fi

echo ""
echo -e "${BOLD}Restart your terminal (or run: source ~/.zshrc)${RESET}"
```

- [ ] **Step 2: Make executable and verify syntax**

```bash
chmod +x modules/zsh.sh
bash -n modules/zsh.sh
```

Expected: no output from `bash -n`.

- [ ] **Step 3: Commit**

```bash
git add modules/zsh.sh
git commit -m "feat: add modules/zsh.sh"
```

---

## Task 4: Create modules/node.sh

**Files:**
- Create: `modules/node.sh`

- [ ] **Step 1: Write modules/node.sh**

```bash
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
```

- [ ] **Step 2: Make executable and verify syntax**

```bash
chmod +x modules/node.sh
bash -n modules/node.sh
```

Expected: no output from `bash -n`.

- [ ] **Step 3: Commit**

```bash
git add modules/node.sh
git commit -m "feat: add modules/node.sh"
```

---

## Task 5: Create modules/vim.sh

**Files:**
- Create: `modules/vim.sh`

- [ ] **Step 1: Write modules/vim.sh**

```bash
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
    echo -e "${YELLOW}  ⚠ Failed to install vim-plug.${RESET}"
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
```

- [ ] **Step 2: Make executable and verify syntax**

```bash
chmod +x modules/vim.sh
bash -n modules/vim.sh
```

Expected: no output from `bash -n`.

- [ ] **Step 3: Commit**

```bash
git add modules/vim.sh
git commit -m "feat: add modules/vim.sh"
```

---

## Task 6: Create modules/java.sh

**Files:**
- Create: `modules/java.sh`

- [ ] **Step 1: Write modules/java.sh**

```bash
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
    echo -e "${YELLOW}  ⚠ Failed to clone maven-bash-completion.${RESET}"
    exit 1
  fi
fi
```

- [ ] **Step 2: Make executable and verify syntax**

```bash
chmod +x modules/java.sh
bash -n modules/java.sh
```

Expected: no output from `bash -n`.

- [ ] **Step 3: Commit**

```bash
git add modules/java.sh
git commit -m "feat: add modules/java.sh"
```

---

## Task 7: Clean up .zshrc and .zshrc-intel

**Files:**
- Modify: `.zshrc`
- Modify: `.zshrc-intel`

Remove the `brewi` function, its comment block, and the two `brew-maint` aliases that point to deleted scripts.

- [ ] **Step 1: Remove from .zshrc**

In `.zshrc`, remove these lines (around line 129–145):

```zsh
alias brew-maint="$HOME/Code/machine-setup/scripts/brew-maintenance-simple.sh"
alias brew-maint-complex="$HOME/Code/machine-setup/scripts/brew-maintenance.sh"
```

And remove the `brewi` function and its comment block:

```zsh
# brewi: install a Homebrew package and immediately regenerate the Brewfile.
# Usage: brewi <package> [package2 ...]
# - Passes all arguments to `brew install` (handles multiple packages at once)
# - Only regenerates the Brewfile if the install succeeds
# - `brew bundle dump --force` rewrites the entire Brewfile from all currently
#   installed packages — not just what you installed now. Review the diff before
#   committing to avoid permanently tracking packages you installed by accident.
brewi() {
  brew install "$@" && brew bundle dump --file="$HOME/Code/machine-setup/Brewfile" --force
}
```

- [ ] **Step 2: Make the same removals in .zshrc-intel**

Search for the same `brew-maint` aliases and `brewi` function block in `.zshrc-intel` (around lines 124–131) and remove them.

- [ ] **Step 3: Verify syntax on both files**

```bash
bash -n .zshrc
bash -n .zshrc-intel
```

Expected: no output from either.

- [ ] **Step 4: Commit**

```bash
git add .zshrc .zshrc-intel
git commit -m "chore: remove brewi function and brew-maint aliases from zshrc"
```

---

## Task 8: Rewrite README.md

**Files:**
- Modify: `README.md`

Replace the entire contents of `README.md` with the following:

- [ ] **Step 1: Write new README.md**

```markdown
# machine-setup

A minimal Mac developer setup. Installs core tools via Homebrew and gives you a clean starting point for dotfiles and shell config.

---

## Quick start

Run from anywhere — `~` is fine:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/t-keazirian/machine-setup/main/setup.sh)
```

Or clone first and run locally:

```bash
git clone git@github.com:t-keazirian/machine-setup.git ~/Code/machine-setup
bash ~/Code/machine-setup/setup.sh
```

> **SSH keys required:** `setup.sh` clones this repo via SSH in step 3. Make sure your SSH key is registered with GitHub before running. See [SSH key setup](#ssh-key-setup) below if needed.

> **Xcode CLT vs Xcode:** Step 1 installs Xcode Command Line Tools (~500MB) — not the full Xcode IDE (~10GB). CLT provides `git`, `make`, and `clang`, and is required by Homebrew.

---

## What setup.sh does

Five steps, all idempotent (safe to re-run):

1. Xcode Command Line Tools
2. Homebrew
3. Clone this repo to `~/Code/machine-setup`
4. Install packages from `Brewfile`
5. Prompt for your git identity (name and email)

After these complete, pick the optional modules you want.

---

## Optional modules

Run any of these after `setup.sh`:

| Module | What it installs | Command |
|--------|-----------------|---------|
| `modules/zsh.sh` | Oh My Zsh, zsh-autosuggestions, zsh-syntax-highlighting | `bash modules/zsh.sh` |
| `modules/node.sh` | NVM + Node LTS (set as default) | `bash modules/node.sh` |
| `modules/vim.sh` | vim-plug + Vim plugins from .vimrc | `bash modules/vim.sh` |
| `modules/java.sh` | maven-bash-completion for zsh | `bash modules/java.sh` |

All modules are idempotent — safe to re-run.

---

## Dotfiles

The repo includes reference configs you can use as a starting point:

| File | Purpose |
|------|---------|
| `.zshrc` | Zsh config (Apple Silicon) |
| `.zshrc-intel` | Zsh config (Intel Mac) |
| `.vimrc` | Vim config with vim-plug |
| `.gitignore-global` | Global git ignores |

**Review these files before using them** — they're Taylor's personal configs. Remove anything that doesn't apply to you (aliases, paths, tool-specific settings).

To symlink them into your home directory:

```bash
ln -sf ~/Code/machine-setup/.zshrc ~/.zshrc
ln -sf ~/Code/machine-setup/.vimrc ~/.vimrc
ln -sf ~/Code/machine-setup/.gitignore-global ~/.gitignore-global
```

Symlinking means edits to files in this repo automatically take effect. If you'd rather copy and customize independently, just copy the files instead:

```bash
cp ~/Code/machine-setup/.zshrc ~/.zshrc
```

---

## Keeping Homebrew up to date

```bash
brew update && brew upgrade && brew cleanup
```

To add a package and track it:

```bash
brew install <package>
# Then add it to Brewfile manually and commit
```

---

## Git aliases

Notable aliases in `.gitconfig` (if you use it):

- `git done` — switches to main, pulls, and deletes all merged local branches
- `git clean-branches` — deletes local branches already merged into the default branch
- `git clean-branches-dry` — preview of what `clean-branches` would delete
- `git clean-remote` — prunes stale remote-tracking branches
- `git lg` — compact graph log
- `git st` — short status
- `git wc` / `git wcd` — "what changed" log (summary / detailed)

---

## Machine-local overrides

`.zshrc` sources `~/.zshrc.local` at startup if it exists. Create it manually on each machine for secrets and machine-specific config:

```zsh
export GITHUB_TOKEN=ghp_...
export SOME_OTHER_SECRET=...
```

**Never put tokens or credentials in `.zshrc`** — it is tracked by Git.

---

## SSH key setup

If you need to generate SSH keys before running `setup.sh`:

```bash
ssh-keygen -t ed25519 -C "your@email.com"
cat ~/.ssh/id_ed25519.pub
# Copy the output and add it to https://github.com/settings/keys
```
```

- [ ] **Step 2: Verify the file looks correct**

```bash
wc -l README.md
```

Expected: roughly 100–120 lines (significantly shorter than the previous 204).

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: rewrite README for public audience"
```

---

## Task 9: Remove docs/superpowers/ (self-cleanup)

This directory contains Claude Code planning docs (including this plan). It belongs in `machine-setup-private`, not the public repo.

**Files:**
- Delete: `docs/superpowers/` (entire directory)

- [ ] **Step 1: git rm the directory**

```bash
git rm -r docs/superpowers/
```

- [ ] **Step 2: Verify docs/ only contains setup.md**

```bash
ls docs/
```

Expected: `setup.md` only.

- [ ] **Step 3: Commit**

```bash
git commit -m "chore: remove docs/superpowers from public repo"
```

---

## Final verification

- [ ] **Check repo structure matches spec**

```bash
ls -la
ls modules/
ls docs/
```

Expected root: `.gitignore`, `.gitignore-global`, `.vimrc`, `.zshrc`, `.zshrc-intel`, `Brewfile`, `README.md`, `docs/`, `modules/`

Expected `modules/`: `java.sh`, `node.sh`, `vim.sh`, `zsh.sh`

Expected `docs/`: `setup.md`

- [ ] **Verify all module scripts are executable**

```bash
ls -l modules/
```

Expected: all four scripts show `-rwxr-xr-x` permissions.

- [ ] **Syntax check all scripts**

```bash
bash -n setup.sh && bash -n modules/zsh.sh && bash -n modules/node.sh && bash -n modules/vim.sh && bash -n modules/java.sh
```

Expected: no output.

- [ ] **Push branch and open PR**

```bash
git push -u origin chore/public-repo-cleanup
gh pr create --title "chore: clean up public repo — thin core, modules, remove personal files" --body "$(cat <<'EOF'
## Summary

- Strips `setup.sh` to 5 universal core steps (removes Oh My Zsh, NVM, vim, maven, Claude)
- Introduces `modules/` directory with opt-in setup scripts (zsh, node, vim, java)
- Removes all personal/IDE-specific files: `bootstrap.sh`, `scripts/`, `iterm2/`, `.gitconfig`, `.ideavimrc`, `vscode-settings.json`, related docs
- Removes `brewi` function and `brew-maint` aliases from both zshrc files (scripts deleted)
- Rewrites README for a public audience — no personal tooling references

## Why

The repo was doing two things: restoring Taylor's exact machine setup AND serving as a shareable starter. These goals conflict. This PR makes the public repo a clean starter template. Personal tooling moves to `machine-setup-private` in a future session.

Fixes: bootstrap.sh auto-symlinking `.gitconfig` on others' machines (root cause of Brian's setup issues).

## Test plan

- [ ] `bash -n setup.sh` passes
- [ ] `bash -n modules/*.sh` passes for all four modules
- [ ] Repo structure matches spec: `ls -la`, `ls modules/`, `ls docs/`
- [ ] No references to deleted files in README or remaining scripts

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

---

## Self-review

**Spec coverage:**
- ✅ Remove all files in removal table → Task 1
- ✅ setup.sh stripped to 5 steps → Task 2
- ✅ modules/ with zsh, node, vim, java → Tasks 3–6
- ✅ brewi removed from .zshrc and .zshrc-intel → Task 7
- ✅ README rewritten → Task 8
- ✅ docs/superpowers/ removed → Task 9
- ✅ Xcode CLT note in setup.sh and README → Task 2 (comment), Task 8 (callout)
- ✅ Model B dotfiles (reference + symlink docs) → Task 8

**Placeholder scan:** None found.

**Consistency check:** Color helpers (`info`/`ok`/`warn`/`skip`) are defined identically in all four module scripts and in `setup.sh`. No cross-task type inconsistencies.
