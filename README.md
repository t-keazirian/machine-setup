# Dotfiles

This repo is the single source of truth for my shell, Vim, and Git configuration.

## What's in here

- `.zshrc` (symlinked to `~/.zshrc`)
- `.vimrc` (symlinked to `~/.vimrc`)
- `.gitconfig` (symlinked to `~/.gitconfig`)
- `.gitignore-global` (symlinked to `~/.gitignore-global`)
- `.gitignore` (repo-level ignore for editor artifacts)
- `Brewfile` (all Homebrew formulae, casks, and VS Code extensions)
- `scripts/` (utility scripts, on PATH via `~/.zshrc`)
- `setup.sh` (master setup script for a new machine)

## How it works

Instead of copying dotfiles around, this setup uses symlinks:

- `~/.zshrc` points to `~/Code/dotfiles/.zshrc`
- `~/.vimrc` points to `~/Code/dotfiles/.vimrc`
- `~/.gitconfig` points to `~/Code/dotfiles/.gitconfig`
- `~/.gitignore-global` points to `~/Code/dotfiles/.gitignore-global`
- `~/Code/dotfiles/scripts/` is added to `$PATH` directly in `.zshrc`

Edits to the dotfiles are automatically tracked by Git.

## New machine setup (single command)

SSH keys must exist and be registered with GitHub before running.

```bash
# If SSH keys are already on the machine:
bash <(curl -fsSL https://raw.githubusercontent.com/t-keazirian/dotfiles/main/setup.sh)

# Or clone first and review:
git clone git@github.com:t-keazirian/dotfiles.git ~/Code/dotfiles
bash ~/Code/dotfiles/setup.sh
```

### What setup.sh does

1. Installs Xcode Command Line Tools (triggers dialog if missing, then waits)
2. Installs Homebrew (Apple Silicon path: `/opt/homebrew`)
3. Clones this repo to `~/Code/dotfiles` (skips if already present)
4. Runs `brew bundle install --file=Brewfile --no-lock` — installs all formulae and casks; warns on VPN-only taps but does not exit
5. Installs Oh My Zsh (`RUNZSH=no KEEP_ZSHRC=yes` so it doesn't hijack the shell session or overwrite `.zshrc`), then clones `zsh-autosuggestions` and `zsh-syntax-highlighting` into `custom/plugins/`
6. Runs `bootstrap.sh` to create all dotfile symlinks
7. Sources NVM from Homebrew, installs Node 22.14.0, and sets it as the default
8. Installs SDKMAN
9. Clones Vundle, creates `~/.vim/undodir`, runs `:PluginInstall` in Vim
10. Ensures all scripts in `~/Code/dotfiles/scripts/` are executable (they are on PATH via `.zshrc`)
11. Creates `~/.zsh/completions/` and clones `maven-bash-completion`

Each step prints "already done, skipping" if it detects it has been run before. The script is safe to rerun on an existing machine.

### What cannot be automated

**SSH keys** — generate and register with GitHub before running setup:

```bash
ssh-keygen -t ed25519 -C "your@email.com"
# Then add ~/.ssh/id_ed25519.pub to https://github.com/settings/keys
```

**`~/.gitconfig-tm`** — work identity, never committed to this repo. The `.gitconfig` uses `includeIf` to pick it up automatically once the file exists on the machine:

```ini
[user]
  name = Your Work Name
  email = you@work.com
```

**SDKMAN Java version** — `setup.sh` installs SDKMAN but cannot install Java inside the same shell session. After setup completes, open a new terminal and run:

```bash
sdk install java
```

**`tm/homebrew` + `tech-pass`** — these require VPN. After connecting, rerun:

```bash
brew bundle install --file=~/Code/dotfiles/Brewfile --no-lock
```

**macOS System Preferences** — Dock position, keyboard repeat rate, trackpad settings, etc. `defaults write` commands are fragile across macOS versions and not automated here. Configure manually.

**JetBrains settings** — use JetBrains Toolbox's built-in settings sync.

**iTerm2 profile** — export your `.itermcolors` theme and JSON profile from iTerm2 > Preferences > Profiles > Export. Optionally add these to the repo later.

**Rancher Desktop PATH block** — added automatically by Rancher Desktop on first launch. No action needed.

**Deno** — install separately:

```bash
curl -fsSL https://deno.land/install.sh | sh
```

---

## Bootstrap existing dotfiles (symlinks only)

If the repo is already cloned and you only need to recreate symlinks:

```bash
cd ~/Code/dotfiles
chmod +x bootstrap.sh
./bootstrap.sh
```

### What bootstrap.sh does
- Verifies the repo exists at `~/Code/dotfiles`
- Backs up any existing dotfiles (only if they are not symlinks):
  - `~/.zshrc` → `~/.zshrc.pre-bootstrap`
  - `~/.vimrc` → `~/.vimrc.pre-bootstrap`
  - `~/.gitconfig` → `~/.gitconfig.pre-bootstrap`
  - `~/.gitignore-global` → `~/.gitignore-global.pre-bootstrap`
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
