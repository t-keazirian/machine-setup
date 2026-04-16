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
| `modules/zsh.sh` | Oh My Zsh, zsh-autosuggestions, zsh-syntax-highlighting | `bash ~/Code/machine-setup/modules/zsh.sh` |
| `modules/node.sh` | NVM + Node LTS (set as default) | `bash ~/Code/machine-setup/modules/node.sh` |
| `modules/vim.sh` | vim-plug + Vim plugins from .vimrc | `bash ~/Code/machine-setup/modules/vim.sh` |
| `modules/java.sh` | maven-bash-completion for zsh | `bash ~/Code/machine-setup/modules/java.sh` |

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

**Review these files before using them** — they reflect a specific personal setup. Remove or adapt anything that doesn't apply to you.

To symlink them into your home directory:

```bash
ln -sf ~/Code/machine-setup/.zshrc ~/.zshrc
ln -sf ~/Code/machine-setup/.vimrc ~/.vimrc
ln -sf ~/Code/machine-setup/.gitignore-global ~/.gitignore-global
```

Symlinking means edits in this repo take effect immediately. If you'd rather copy and customize independently:

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

Notable aliases in `.gitconfig` (if you use it as a reference):

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
