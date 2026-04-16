# machine-setup Public Repo Cleanup — Design Spec

**Date:** 2026-04-15
**Scope:** `machine-setup` (public repo) only. `machine-setup-private` is a separate effort.

---

## Problem

The repo was built with two conflicting goals: (1) restore Taylor's exact machine setup, and (2) serve as a shareable starter template for others. These goals have conflicting requirements. The result is a repo that is too opinionated for others (auto-symlinks that clobber configs, personal tools baked in) and too incomplete for a personal restore (private tooling shouldn't live in a public repo).

The root cause of concrete issues (broken setup on Brian's machine) is that `bootstrap.sh` auto-symlinks files including `.gitconfig`, which overwrites another user's git identity.

---

## Decision

Split the two concerns across two repos:

- **`machine-setup` (this repo, public)** — generic Mac dev setup starter. Safe for anyone to clone and run. No auto-symlinks. No personal tooling.
- **`machine-setup-private` (existing, private)** — Taylor's exact setup. Personal configs, symlinks, Claude tooling. Out of scope for this spec.

---

## Design

### Guiding principle

> "Automation is nice but too much causes problems."

The public repo documents workflows rather than automating them unconditionally. `setup.sh` covers only the steps that are universally safe. Everything else is opt-in via modules, with the symlink approach documented rather than run automatically.

---

### Repository structure (after)

```
machine-setup/
├── .gitignore-global       ← reference dotfile (stays)
├── .vimrc                  ← reference dotfile (stays)
├── .zshrc                  ← reference dotfile (brewi function removed)
├── .zshrc-intel            ← reference dotfile (brewi function removed)
├── Brewfile                ← unchanged, already trimmed to core tools
├── README.md               ← updated (see below)
├── docs/
│   └── setup.md            ← setup guidance, stays
├── modules/
│   ├── zsh.sh              ← Oh My Zsh + zsh-autosuggestions + zsh-syntax-highlighting
│   ├── node.sh             ← NVM + Node LTS
│   ├── vim.sh              ← vim-plug + Vim plugins
│   └── java.sh             ← maven-bash-completion
└── setup.sh                ← 5 core steps only (see below)
```

---

### What is removed from the public repo

These are either stale, personal, or software-specific and belong in `machine-setup-private`:

| Item | Reason |
|------|--------|
| `bootstrap.sh` | Auto-symlinks personal configs; causes issues on others' machines |
| `scripts/` (entire directory) | All scripts are personal utilities, not generic setup tools |
| `iterm2/` | Personal preference file |
| `CURRENT.md` | Stale session-state tracker, not documentation |
| `.gitconfig` | Contains personal git identity; dangerous to symlink on others' machines |
| `.ideavimrc` | IntelliJ-specific, niche |
| `vscode-settings.json` | IDE-specific, personal |
| `docs/ideavim.md` | IDE-specific |
| `docs/vscode.md` | IDE-specific |
| `docs/vscode-extensions.md` | IDE-specific |
| `docs/optional-installs.md` | Work-stack specific (SDKMAN, Maven, Kafka, k8s) |
| `docs/superpowers/` | Claude Code planning docs, personal |

All of the above are removed from this repo (`git rm`). Adding them to `machine-setup-private` is a separate future session and not part of this implementation.

---

### `setup.sh` — thin core (5 steps)

Only steps that are universally safe and expected on any Mac dev machine:

1. Xcode Command Line Tools
2. Homebrew
3. Clone dotfiles repo (`git@github.com:t-keazirian/machine-setup.git`)
4. `brew bundle` from Brewfile
5. Git identity (`git config --global` prompts for name + email)

Ends with a "what's next" summary listing available modules and pointing to the dotfile documentation.

Steps removed from `setup.sh`: Oh My Zsh (→ `modules/zsh.sh`), NVM + Node (→ `modules/node.sh`), vim-plug (→ `modules/vim.sh`), script permissions (removed with `scripts/`), maven-bash-completion (→ `modules/java.sh`), iTerm2 prefs (→ private), Claude Code (→ private), Claude plugins (→ private).

---

### `modules/` — opt-in setup scripts

Each module is standalone and idempotent. Users run only what they want after `setup.sh` completes.

**`modules/zsh.sh`**
Installs Oh My Zsh (non-interactive, `RUNZSH=no KEEP_ZSHRC=yes`), then clones `zsh-autosuggestions` and `zsh-syntax-highlighting` into `~/.oh-my-zsh/custom/plugins`.

**`modules/node.sh`**
Sources the NVM shell script (supports both arm64 and x86 Homebrew paths), installs Node LTS, sets it as default.

**`modules/vim.sh`**
Downloads `vim-plug` to `~/.vim/autoload/plug.vim`, creates `~/.vim/undodir`, runs `vim +PlugInstall +qall`.

**`modules/java.sh`**
Clones `maven-bash-completion` into `~/.zsh/completions/maven-bash-completion`.

All modules are idempotent: skip if already installed, same skip/ok output style as `setup.sh`.

---

### Dotfiles — Model B (document, don't auto-link)

The reference dotfiles (`.zshrc`, `.zshrc-intel`, `.vimrc`, `.gitignore-global`) stay in the repo as starting points. No auto-symlink runs during `setup.sh`.

The README documents the manual symlink commands for users who want them:

```bash
ln -sf ~/Code/machine-setup/.zshrc ~/.zshrc
ln -sf ~/Code/machine-setup/.vimrc ~/.vimrc
ln -sf ~/Code/machine-setup/.gitignore-global ~/.gitignore-global
```

Users are explicitly told: review the files first and customize before symlinking, especially `.zshrc`.

**`brewi` function removed** from both `.zshrc` and `.zshrc-intel`. It dumps the entire installed package list into the Brewfile (`brew bundle dump --force`), which can silently pollute the curated Brewfile. The safer workflow is `brew install <pkg>`, then manually add to Brewfile and commit.

---

### README updates

The README is updated to reflect the new structure:

- Clear "Quick start" section: run `setup.sh`, then pick modules
- Module reference table: what each module does, how to run it
- Dotfile section: what's in the repo, how to symlink manually if desired
- Removes references to `bootstrap.sh`, `scripts/`, and any personal tooling

---

## Out of scope

- `machine-setup-private` changes (separate session)
- Consolidating or rewriting the two brew-maintenance scripts (moving to private as-is)
- Any changes to Brewfile contents
- Any new dotfile content or shell config changes beyond removing `brewi`
