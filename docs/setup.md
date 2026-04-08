# Script Reference

## What `setup.sh` does

Each step prints "already done, skipping" if it detects it has been run before. The script is safe to rerun on an existing machine.

1. Installs Xcode Command Line Tools (triggers the system dialog if missing, then waits for it to complete)
2. Installs Homebrew (Apple Silicon path: `/opt/homebrew`)
3. Creates `~/Code/` if it doesn't exist, then clones this repo to `~/Code/machine-setup` (skips if already present)
4. Runs `brew bundle install --file=Brewfile` — installs all formulae and casks; warns on failures but does not exit
5. Installs Oh My Zsh (`RUNZSH=no KEEP_ZSHRC=yes` so it doesn't hijack the shell session or overwrite `.zshrc`), then clones `zsh-autosuggestions` and `zsh-syntax-highlighting` into `custom/plugins/`
6. Runs `bootstrap.sh` to create all dotfile symlinks
7. Prompts for your Git name and email and writes them to `~/.gitconfig` (skips if already set)
8. Sources NVM from Homebrew, installs the current Node LTS, and sets it as the default
9. Installs SDKMAN
10. Installs [vim-plug](https://github.com/junegunn/vim-plug) via curl, creates `~/.vim/undodir`, runs `:PlugInstall` in Vim
11. Makes `brew-maintenance.sh`, `brew-maintenance-simple.sh`, `git-pull-all`, and `who-is-listening` executable in `scripts/` (they are on PATH via `.zshrc`)
12. Creates `~/.zsh/completions/` and clones `maven-bash-completion`
13. Installs Claude Code (skips if already present)
14. Skips plugin install and adds it to the post-setup summary — plugin install requires authentication, which must happen after setup

---

## What `bootstrap.sh` does

- Verifies the repo exists at `~/Code/machine-setup`
- Backs up any existing dotfiles (only if they are not already symlinks), appending `.pre-bootstrap.<timestamp>` to the filename:
  - `~/.zshrc`
  - `~/.vimrc`
  - `~/.gitconfig`
  - `~/.gitignore-global`
  - `~/.ideavimrc`
  - `~/Library/Application Support/Code/User/settings.json`
- Detects architecture (Apple Silicon vs Intel) and symlinks the appropriate `.zshrc` to `~/.zshrc`
- Creates all dotfile symlinks pointing back to this repo
- Symlinks `~/.gitignore-global` to this repo's `.gitignore-global` (the tracked `.gitconfig` already sets `core.excludesfile` to point there)

---

## Rollback

If something goes wrong after running `bootstrap.sh`:

**1. Remove the symlinks:**

```bash
rm ~/.zshrc ~/.vimrc ~/.gitconfig ~/.gitignore-global ~/.ideavimrc \
   "$HOME/Library/Application Support/Code/User/settings.json"
```

**2. Restore the backups** (replace `<timestamp>` with the value printed when the script ran):

```bash
mv ~/.zshrc.pre-bootstrap.<timestamp> ~/.zshrc
mv ~/.vimrc.pre-bootstrap.<timestamp> ~/.vimrc
mv ~/.gitconfig.pre-bootstrap.<timestamp> ~/.gitconfig
mv ~/.gitignore-global.pre-bootstrap.<timestamp> ~/.gitignore-global
mv ~/.ideavimrc.pre-bootstrap.<timestamp> ~/.ideavimrc
mv "$HOME/Library/Application Support/Code/User/settings.json.pre-bootstrap.<timestamp>" \
   "$HOME/Library/Application Support/Code/User/settings.json"
```

**3. Reload:**

```bash
source ~/.zshrc
```
