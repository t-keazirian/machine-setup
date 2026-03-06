# Machine Setup

This repo is the single source of truth for my shell, Vim, Git configuration, scripts, and new machine automation.

## What's in here

- `.zshrc` (symlinked to `~/.zshrc`)
- `.vimrc` (symlinked to `~/.vimrc`)
- `.gitconfig` (symlinked to `~/.gitconfig`) — **update `[user]` with your own name and email before use**
- `.gitignore-global` (symlinked to `~/.gitignore-global`)
- `.gitignore` (repo-level ignore for editor artifacts)
- `Brewfile` (all Homebrew formulae, casks, and VS Code extensions)
- `scripts/` (utility scripts, on PATH via `~/.zshrc`)
- `setup.sh` (master setup script for a new machine)

## How it works

Instead of copying dotfiles around, this setup uses symlinks:

- `~/.zshrc` points to `~/Code/machine-setup/.zshrc`
- `~/.vimrc` points to `~/Code/machine-setup/.vimrc`
- `~/.gitconfig` points to `~/Code/machine-setup/.gitconfig`
- `~/.gitignore-global` points to `~/Code/machine-setup/.gitignore-global`
- `~/Code/machine-setup/scripts/` is added to `$PATH` directly in `.zshrc`

Edits to the dotfiles are automatically tracked by Git.

---

## New machine setup

> **Requirements:** Apple Silicon or Intel Mac. SSH keys must exist and be registered with GitHub before running.
>
> **Convention:** Repos live in `~/Code/`. The setup script creates `~/Code/` if it doesn't exist and clones this repo to `~/Code/machine-setup`.

### Step 0 — Update `.gitconfig` with your identity

Open `.gitconfig` and replace the placeholder `[user]` block with your own details:

```gitconfig
[user]
  name  = Your Name
  email = you@example.com
```

### Step 1 — Generate SSH keys (if needed)

```bash
ssh-keygen -t ed25519 -C "your@email.com"
cat ~/.ssh/id_ed25519.pub
# Copy the output and add it to https://github.com/settings/keys
```

### Step 1 — Run setup

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/t-keazirian/machine-setup/main/setup.sh)
```

To review the script before running it:

```bash
# Clone via HTTPS (no SSH keys required to review)
git clone https://github.com/t-keazirian/machine-setup.git ~/Code/machine-setup
cat ~/Code/machine-setup/setup.sh

# Then run it
bash ~/Code/machine-setup/setup.sh
```

### Step 2 — After setup completes

Restart your terminal, or run:

```bash
source ~/.zshrc
```

Then open a new terminal and install a Java version via SDKMAN:

```bash
sdk install java
```

### What setup.sh does

1. Installs Xcode Command Line Tools (triggers dialog if missing, then waits)
2. Installs Homebrew (Apple Silicon path: `/opt/homebrew`)
3. Creates `~/Code/` if it doesn't exist, then clones this repo to `~/Code/machine-setup` (skips if already present)
4. Runs `brew bundle install --file=Brewfile` — installs all formulae and casks; warns on failures but does not exit
5. Installs Oh My Zsh (`RUNZSH=no KEEP_ZSHRC=yes` so it doesn't hijack the shell session or overwrite `.zshrc`), then clones `zsh-autosuggestions` and `zsh-syntax-highlighting` into `custom/plugins/`
6. Runs `bootstrap.sh` to create all dotfile symlinks
7. Sources NVM from Homebrew, installs the current Node LTS, and sets it as the default
8. Installs SDKMAN
9. Clones Vundle, creates `~/.vim/undodir`, runs `:PluginInstall` in Vim
10. Ensures all scripts in `~/Code/machine-setup/scripts/` are executable (they are on PATH via `.zshrc`)
11. Creates `~/.zsh/completions/` and clones `maven-bash-completion`

Each step prints "already done, skipping" if it detects it has been run before. The script is safe to rerun on an existing machine.

### What cannot be automated

**macOS System Preferences** — Dock position, keyboard repeat rate, trackpad settings, etc. `defaults write` commands are fragile across macOS versions and not automated here. Configure manually.

**JetBrains settings** — use JetBrains Toolbox's built-in settings sync.

**iTerm2 profile** — export your `.itermcolors` theme and JSON profile from iTerm2 > Preferences > Profiles > Export. Optionally add these to the repo later.

**Deno** — install separately:

```bash
curl -fsSL https://deno.land/install.sh | sh
```

---

## Bootstrap existing dotfiles (symlinks only)

If the repo is already cloned and you only need to recreate symlinks:

```bash
cd ~/Code/machine-setup
chmod +x bootstrap.sh
./bootstrap.sh
```

### What bootstrap.sh does
- Verifies the repo exists at `~/Code/machine-setup`
- Backs up any existing dotfiles (only if they are not symlinks):
  - `~/.zshrc` → `~/.zshrc.pre-bootstrap`
  - `~/.vimrc` → `~/.vimrc.pre-bootstrap`
  - `~/.gitconfig` → `~/.gitconfig.pre-bootstrap`
  - `~/.gitignore-global` → `~/.gitignore-global.pre-bootstrap`
- Detects architecture (Apple Silicon vs Intel) and symlinks the appropriate `.zshrc` to `~/.zshrc`
- Creates symlinks in the home directory pointing to this repo's files
- Configures Git to use `~/.gitignore-global` via `core.excludesfile`

### Rollback

If something goes wrong:

1. Remove the symlink(s):

```bash
rm ~/.zshrc ~/.vimrc ~/.gitconfig ~/.gitignore-global
```

2. Restore the backups:

```bash
mv ~/.zshrc.pre-bootstrap ~/.zshrc
mv ~/.vimrc.pre-bootstrap ~/.vimrc
mv ~/.gitconfig.pre-bootstrap ~/.gitconfig
mv ~/.gitignore-global.pre-bootstrap ~/.gitignore-global
```

3. Reload terminal

#### Notes
- Symlinks are machine-specific and must be created on each machine.
- Moving the repo requires recreating symlinks (they store the path).

---

## Keeping the Brewfile up to date

The Brewfile is a snapshot of every Homebrew package, cask, and VS Code extension to install on a new machine. It does not update itself automatically when you install something new.

Use `brewi` instead of `brew install` to install a package and update the Brewfile in one step:

```bash
brewi <package>
brewi git gh tree   # multiple packages at once
```

**What `brewi` does, precisely:**
1. Runs `brew install` with every argument you pass (multiple packages work correctly)
2. If and only if the install succeeds, runs `brew bundle dump --file=~/Code/machine-setup/Brewfile --force`
3. `brew bundle dump --force` **rewrites the entire Brewfile** from scratch based on everything currently installed — not just the package you just added

**Important:** because the dump is a full snapshot, packages you installed casually in the past may appear in the diff. Review `git diff Brewfile` before committing and remove anything you don't want permanently tracked.

**After running `brewi`, commit the updated Brewfile:**

```bash
cd ~/Code/machine-setup
git add Brewfile
git commit -m "chore: add <package> to Brewfile"
git push
```

---

## Git aliases

Notable aliases defined in `.gitconfig`:

- `git done` — after merging a PR, switches to main, pulls, and deletes all merged local branches in one command
- `git clean-branches` — deletes local branches already merged into the default branch (safe: protects main/master/develop)
- `git clean-branches-dry` — preview of what `clean-branches` would delete
- `git clean-remote` — prunes stale remote-tracking branches (`git fetch --prune`)
- `git lg` — compact graph log
- `git st` — short status
- `git wc` / `git wcd` — "what changed" log (summary / detailed)
