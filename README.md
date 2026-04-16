# Machine Setup

A minimal Mac developer setup for Apple Silicon and Intel. Gets your machine running with core tools and a clean shell config.

---

## Quick start

**Step 0 — fresh Mac only:** If you don't have git yet, install Xcode Command Line Tools first:

```bash
xcode-select --install
```

Not sure? Run `git --version`. If it returns a version number, skip this.

**Step 1 — clone and run:**

```bash
git clone https://github.com/t-keazirian/machine-setup.git ~/Code/machine-setup
bash ~/Code/machine-setup/setup.sh
```

> **Xcode CLT vs Xcode:** `setup.sh` installs Xcode Command Line Tools (~500MB), not the full Xcode IDE (~10GB). CLT gives you `git`, `make`, and `clang` — enough to run Homebrew.

---

## What setup.sh does

Four steps, all idempotent (safe to re-run):

1. Xcode Command Line Tools
2. Homebrew
3. Install packages from `Brewfile`
4. Prompt for your git identity (name and email)

After these complete, `setup.sh` prints the commands for any optional modules you want to run. Once you're done, you can delete the repo — nothing depends on it after setup.

---

## Optional modules

Run any of these after `setup.sh`. The exact commands for your install location are printed when `setup.sh` finishes.

| Module | What it installs |
|--------|-----------------|
| `modules/zsh.sh` | Oh My Zsh, zsh-autosuggestions, zsh-syntax-highlighting |
| `modules/node.sh` | NVM + Node LTS (set as default) |

All modules are idempotent — safe to re-run.

---

## Dotfiles

The repo includes a starter `.zshrc` — Homebrew paths, NVM, Oh My Zsh wired up, and a few common aliases. Copy it and adapt it to your setup:

```bash
cp ~/Code/machine-setup/.zshrc ~/.zshrc
```

---

## SSH keys

You'll want SSH keys set up for GitHub — for pushing code and accessing private repos. Check if you already have one:

```bash
ssh -T git@github.com
# "Hi username! You've successfully authenticated..." means you're good.
```

If not, generate one:

```bash
ssh-keygen -t ed25519 -C "your@email.com"
cat ~/.ssh/id_ed25519.pub
# Copy the output and add it to https://github.com/settings/keys
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
