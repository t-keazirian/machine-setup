# Machine Setup

This repo is the single source of truth for my shell, Vim, Git configuration, scripts, and new machine automation.

> **Private companion:** [`machine-setup-private`](https://github.com/t-keazirian/machine-setup-private) holds personal Claude Code skills and other config that shouldn't be public. Clone and run its `bootstrap.sh` after this setup completes.

## What's in here

- `.zshrc` — symlinked to `~/.zshrc`
- `~/.zshrc.local` — machine-local overrides and secrets; sourced by `.zshrc` at startup; **not tracked** (create manually on each machine)
- `.vimrc` — symlinked to `~/.vimrc`; uses [vim-plug](https://github.com/junegunn/vim-plug) for plugin management
- `.ideavimrc` — symlinked to `~/.ideavimrc`; IdeaVim config for WebStorm; see [docs/ideavim.md](docs/ideavim.md)
- `vscode-settings.json` — symlinked to `~/Library/Application Support/Code/User/settings.json`; see [docs/vscode.md](docs/vscode.md)
- `.gitconfig` — symlinked to `~/.gitconfig`; Git identity (name and email) goes in `~/.gitconfig.local` (not tracked); `setup.sh` prompts for these on first run
- `.gitignore-global` — symlinked to `~/.gitignore-global`
- `Brewfile` — all Homebrew formulae, casks, and VS Code extensions
- `scripts/` — utility scripts, on PATH via `.zshrc`
- `setup.sh` — full setup for a new machine
- `bootstrap.sh` — symlinks only; useful when repo is already cloned

Because each file is symlinked (not copied), edits made directly to files in this repo are automatically tracked by Git.

---

## Which script do I need?

| Situation | Script |
|---|---|
| Brand new machine — nothing installed yet | `setup.sh` |
| Repo already cloned, just need symlinks recreated | `bootstrap.sh` |

`setup.sh` calls `bootstrap.sh` as one of its steps. If in doubt, run `setup.sh` — it skips anything already done and prints its progress as it goes. See [docs/setup.md](docs/setup.md) for a full breakdown of what each script does and how to roll back.

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

To review before running:

```bash
git clone https://github.com/t-keazirian/machine-setup.git ~/Code/machine-setup
cat ~/Code/machine-setup/setup.sh
bash ~/Code/machine-setup/setup.sh
```

### Step 2 — After setup completes

Restart your terminal, or run `source ~/.zshrc`. Then complete these manual steps in order:

**1. Install a Java version via SDKMAN** (open a new terminal first):

```bash
sdk install java
```

**2. Authenticate Claude Code:**

```bash
claude        # personal account
claude-work   # work account (if applicable)
```

**3. Install Claude plugins** (requires both accounts authenticated):

```bash
bash ~/Code/machine-setup/scripts/install-claude-plugins.sh
```

**4. Set up private config:**

```bash
git clone git@github.com:t-keazirian/machine-setup-private.git ~/Code/machine-setup-private
cd ~/Code/machine-setup-private && chmod +x bootstrap.sh && ./bootstrap.sh
```

> **Not automated:** JetBrains settings — use JetBrains Toolbox's built-in settings sync. macOS System Preferences (Dock, keyboard, trackpad) must be configured manually. iTerm2 — export your profile from Preferences > Profiles > Export.

---

## Bootstrap existing dotfiles (symlinks only)

If the repo is already cloned and you only need to recreate symlinks:

```bash
cd ~/Code/machine-setup
chmod +x bootstrap.sh
./bootstrap.sh
```

> **Note:** `bootstrap.sh` does not set your Git identity. If running standalone, update `.gitconfig` manually:
> ```bash
> git config --global user.name  "Your Name"
> git config --global user.email "you@example.com"
> ```

`bootstrap.sh` backs up any existing dotfiles before creating symlinks. Symlinks store the absolute path — moving the repo requires recreating them. See [docs/setup.md](docs/setup.md) for what the script does and how to roll back.

---

## Keeping the Brewfile up to date

Use `brewi` instead of `brew install` — it installs the package and regenerates the Brewfile in one step:

```bash
brewi <package>
brewi git gh tree   # multiple packages at once
```

The dump rewrites the entire Brewfile from scratch, so review `git diff Brewfile` before committing. Then:

```bash
git add Brewfile
git commit -m "chore: add <package> to Brewfile"
git push
```

---

## Git aliases

Notable aliases defined in `.gitconfig`:

- `git done` — switches to main, pulls, removes agent worktrees, and deletes all merged local branches in one command
- `git clean-branches` — deletes local branches already merged into the default branch (safe: protects main/master/develop)
- `git clean-branches-dry` — preview of what `clean-branches` would delete
- `git clean-remote` — prunes stale remote-tracking branches (`git fetch --prune`)
- `git lg` — compact graph log
- `git st` — short status
- `git wc` / `git wcd` — "what changed" log (summary / detailed)

---

## Claude Code multi-account

Two aliases in `.zshrc` give separate personal and work sessions with independent auth, history, and usage limits:

```zsh
alias claude-personal="CLAUDE_CONFIG_DIR=~/.claude command claude"
alias claude-work="CLAUDE_CONFIG_DIR=~/.claude-work command claude"
```

`claude` (bare) uses `~/.claude` (personal). Run `claude-work` once on a new machine to trigger the work account auth flow.

---

## Claude plugins

Plugins are installed via `scripts/install-claude-plugins.sh` into both personal and work contexts. Run it manually after authenticating both accounts (see Step 2 above).

```bash
bash ~/Code/machine-setup/scripts/install-claude-plugins.sh            # both contexts
bash ~/Code/machine-setup/scripts/install-claude-plugins.sh --context personal
bash ~/Code/machine-setup/scripts/install-claude-plugins.sh --context work
```

**Prerequisites:** `jq` must be installed (it's in the Brewfile; if running without `setup.sh`, install it first with `brew install jq`). Always run `--context personal` before `--context work` — the work list is derived from whatever is installed in the personal context.

The script is idempotent — safe to rerun. To add a new plugin: install it in your personal context, sync to work via `--context work`, then add it to `PERSONAL_PLUGINS` in the script so fresh machines get it. Plugins in the `PERSONAL_ONLY` array are never synced to work. If the plugin comes from a marketplace not already registered in the script (`claude-plugins-official`, `cc-marketplace`, `craft`), also add a `claude plugin marketplace add` line to the script for each context that needs it.

---

## Machine-local secrets and overrides

`.zshrc` sources `~/.zshrc.local` at startup if it exists. Create it manually on each machine:

```zsh
export GITHUB_PERSONAL_ACCESS_TOKEN=ghp_...
export SOME_OTHER_SECRET=...
```

**Never put tokens or credentials directly in `.zshrc`** — it is tracked by Git.
