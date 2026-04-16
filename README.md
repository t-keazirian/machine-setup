# machine-setup

A minimal Mac developer setup. Installs core tools via Homebrew and gives you a clean starting point for dotfiles and shell config.

---

## SSH key setup

`setup.sh` clones this repo via SSH. Set up SSH keys with GitHub before running it:

```bash
ssh-keygen -t ed25519 -C "your@email.com"
cat ~/.ssh/id_ed25519.pub
# Copy the output and add it to https://github.com/settings/keys
```

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

All modules are idempotent — safe to re-run.

---

## Dotfiles

The repo includes reference configs you can use as a starting point:

| File | Purpose |
|------|---------|
| `.zshrc` | Zsh config (auto-detects Apple Silicon or Intel) |

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

---

## Git aliases

Add any of these to the `[alias]` section of your `~/.gitconfig`.

> **Warning:** `clean-branches` and `done` permanently delete local branches. Review them before adding.

```ini
[alias]
    st = status -sb
    lg = log --oneline --graph --decorate --all
    co = checkout
    sw = switch
    wc  = log --pretty=format:"%C(yellow)%h%Creset %s %Cgreen(%cr) %Cblue[%an]" --name-status
    wcd = log -p --pretty=format:"%C(yellow)%h%Creset %s %Cgreen(%cr) %Cblue[%an]"
    aa  = add -A
    c   = commit -v
    cm  = commit -m
    clean-branches-dry = "!f() { \
        base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##'); \
        base=${base:-main}; \
        echo \"[base=$base] would delete:\"; \
        git for-each-ref --format='%(refname:short)' --merged origin/$base refs/heads \
        | grep -vE \"\\b$base$|\\bmain$|\\bmaster$|\\bdevelop$\"; \
        }; f"
    clean-branches = "!f() { \
        base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##'); \
        base=${base:-main}; \
        git for-each-ref --format='%(refname:short)' --merged origin/$base refs/heads \
        | grep -vE \"\\b$base$|\\bmain$|\\bmaster$|\\bdevelop$\" \
        | while IFS= read -r b; do \
        [ -n \"$b\" ] && echo \"Deleting $b\" && git branch -D \"$b\"; \
        done; \
        }; f"
    clean-remote = "!git fetch --prune origin"
    done = "!git checkout main && git pull && git clean-branches"
```

`git done` requires `clean-branches`. `clean-branches` uses `-D` (force delete) to handle squash-merged branches that `--merged` doesn't catch.

---

Once setup is complete and you've copied the dotfiles you want, you can delete `~/Code/machine-setup` — nothing depends on it after setup.
