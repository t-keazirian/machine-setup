# Machine Setup

This repo is the single source of truth for my shell, Vim, Git configuration, scripts, and new machine automation.

## What's in here

- `.zshrc` (symlinked to `~/.zshrc`)
- `CLAUDE.md` (symlinked to `~/.claude/CLAUDE.md`) — global Claude Code working agreement
- `~/.zshrc.local` — machine-local overrides and secrets; sourced by `.zshrc` at startup; **not tracked by this repo** (create manually on each machine)
- `.vimrc` (symlinked to `~/.vimrc`)
- `.gitconfig` (symlinked to `~/.gitconfig`) — ships with placeholder `[user]` values; `setup.sh` will prompt you to fill them in, or see below if running `bootstrap.sh` only
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

## Which script do I need?

| Situation | Script |
|---|---|
| Brand new machine — nothing installed yet | `setup.sh` |
| Repo already cloned, just need symlinks recreated | `bootstrap.sh` |

**`setup.sh`** is the full setup. It installs Homebrew, Oh My Zsh, NVM, SDKMAN, Vim plugins, and more — then calls `bootstrap.sh` as one of its steps.

**`bootstrap.sh`** only creates dotfile symlinks. It's a subset of `setup.sh`, useful when the repo is already in place and you just need to wire things up (e.g. after cloning on a machine you use occasionally, or after moving the repo).

If in doubt, run `setup.sh`. It skips anything already done.

---

## New machine setup

> **Requirements:** Apple Silicon or Intel Mac. SSH keys must exist and be registered with GitHub before running.
>
> **Convention:** Repos live in `~/Code/`. The setup script creates `~/Code/` if it doesn't exist and clones this repo to `~/Code/machine-setup`.

### Step 0 — Generate SSH keys (if needed)

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
7. Prompts for your Git name and email and writes them to `~/.gitconfig` (skips if already set)
8. Sources NVM from Homebrew, installs the current Node LTS, and sets it as the default
9. Installs SDKMAN
10. Clones Vundle, creates `~/.vim/undodir`, runs `:PluginInstall` in Vim
11. Ensures all scripts in `~/Code/machine-setup/scripts/` are executable (they are on PATH via `.zshrc`)
12. Creates `~/.zsh/completions/` and clones `maven-bash-completion`
13. Installs Claude Code (skips if already present)
14. Runs `scripts/install-claude-plugins.sh` to install and enable all plugins in both personal and work contexts (skips if Claude is not installed)

Each step prints "already done, skipping" if it detects it has been run before. The script is safe to rerun on an existing machine.

### What cannot be automated

**macOS System Preferences** — Dock position, keyboard repeat rate, trackpad settings, etc. `defaults write` commands are fragile across macOS versions and not automated here. Configure manually.

**JetBrains settings** — use JetBrains Toolbox's built-in settings sync.

**iTerm2 profile** — export your `.itermcolors` theme and JSON profile from iTerm2 > Preferences > Profiles > Export. Optionally add these to the repo later.

---

## Bootstrap existing dotfiles (symlinks only)

If the repo is already cloned and you only need to recreate symlinks:

```bash
cd ~/Code/machine-setup
chmod +x bootstrap.sh
./bootstrap.sh
```

> **Note:** `bootstrap.sh` does not set your Git identity. If you're running it standalone (not via `setup.sh`), update `.gitconfig` manually afterward:
> ```bash
> git config --global user.name  "Your Name"
> git config --global user.email "you@example.com"
> ```

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
- Creates `~/.claude/` if needed and symlinks `CLAUDE.md` into it

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

---

## Claude Code multi-account

Two aliases in `.zshrc` allow separate personal and work Claude Code sessions. Each points to its own config directory, giving independent auth, history, and usage limits:

```zsh
alias claude-personal="CLAUDE_CONFIG_DIR=~/.claude command claude"
alias claude-work="CLAUDE_CONFIG_DIR=~/.claude-work command claude"
```

`claude` (bare) continues to use `~/.claude` (personal). Run `claude-work` once on a new machine to trigger the auth flow for the work account — it's a one-time step per machine.

---

## Claude plugins

Plugins are installed declaratively via `scripts/install-claude-plugins.sh`. On a new machine, `setup.sh` runs this automatically as its final step.

The script installs plugins into both the personal (`~/.claude`) and work (`~/.claude-work`) contexts. The personal list is the hardcoded source of truth; the work list is derived automatically from whatever is installed in the personal context (minus anything in `PERSONAL_ONLY`).

### Adding a new plugin

1. Install it in your personal context as normal.
2. Sync it to work (use the full path — script is not on `$PATH`):
   ```bash
   bash ~/Code/machine-setup/scripts/install-claude-plugins.sh --context work
   ```
3. Update `PERSONAL_PLUGINS` in `scripts/install-claude-plugins.sh` so the plugin is included on fresh machine setups.
4. If the plugin comes from a **new marketplace** (not `claude-plugins-official` or `craft`), also add a `claude plugin marketplace add` line to the personal section — and, if it should sync to work, to the work section as well.

### Keeping a plugin personal-only

Add its plugin ID to the `PERSONAL_ONLY` array in `scripts/install-claude-plugins.sh`. The work sync will skip it automatically.

### Running the script manually

Run using the full path — the script is not on `$PATH`:

```bash
# Both contexts (default)
bash ~/Code/machine-setup/scripts/install-claude-plugins.sh

# One context only
bash ~/Code/machine-setup/scripts/install-claude-plugins.sh --context personal
bash ~/Code/machine-setup/scripts/install-claude-plugins.sh --context work
```

The script is idempotent — safe to re-run on an already-configured machine.

---

## Machine-local secrets and overrides

`.zshrc` sources `~/.zshrc.local` at startup if the file exists:

```zsh
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
```

This file is not in the repo. Create it manually on each machine and put any secrets or local-only config there:

```zsh
export GITHUB_PERSONAL_ACCESS_TOKEN=ghp_...
export SOME_OTHER_SECRET=...
```

**Never put tokens or credentials directly in `.zshrc`** — it is tracked by Git.
