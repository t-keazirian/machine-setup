# Dotfiles

This repo is the single source of truth for my shell, Vim, and Git configuration.

## What’s in here

- `.zshrc` (symlinked to `~/.zshrc`)
- `.vimrc` (symlinked to `~/.vimrc`)
- `.gitconfig` (symlinked to `~/.gitconfig`)
- `.gitignore-global` (symlinked to `~/.gitignore-global`)
- `.gitignore` (repo-level ignore for editor artifacts)

## How it works

Instead of copying dotfiles around, this setup uses symlinks:

- `~/.zshrc` points to `~/Code/dotfiles/.zshrc`
- `~/.vimrc` points to `~/Code/dotfiles/.vimrc`
- `~/.gitconfig` points to `~/Code/dotfiles/.gitconfig`
- `~/.gitignore-global` points to `~/Code/dotfiles/.gitignore-global`

Edits to the dotfiles are automatically tracked by Git.

## Bootstrap a new machine

1) Clone this repo to the expected location:

```bash
git clone git@github.com:t-keazirian/dotfiles.git ~/Code/dotfiles
```

2) Run the bootstrap script:

```bash
cd ~/Code/dotfiles
chmod +x bootstrap.sh
./bootstrap.sh
```

3) Restart your terminal

```bash
source ~/.zshrc
```

### What bootstrap.sh does
- Verifies the repo exists at ~/Code/dotfiles
- Backs up any existing dotfiles (only if they are not symlinks):
- `~/.zshrc` -> `~/.zshrc.pre-bootstrap`
- `~/.vimrc` -> `~/.vimrc.pre-bootstrap`
- `~/.gitconfig` -> `~/.gitconfig.pre-bootstrap`
- `~/.gitignore-global` -> `~/.gitignore-global.pre-bootstrap`
- Creates symlinks in the home directory pointing to this repo’s files
- Configures Git to use `~/.gitignore-global` via `core.excludesfile`

### Rollback

If something goes wrong:

1) Remove the symlink(s):

```bash
rm ~/.zshrc ~/.vimrc ~/.gitconfig ~/.gitignore-global
```

2) Restore the backups:

```bash
mv ~/.zshrc.pre-bootstrap ~/.zshrc
mv ~/.vimrc.pre-bootstrap ~/.vimrc
mv ~/.gitconfig.pre-bootstrap ~/.gitconfig
mv ~/.gitignore-global.pre-bootstrap ~/.gitignore-global
```

3) Reload terminal

#### Notes
- Symlinks are machine-specific and must be created on each machine.
- Moving the repo requires recreating symlinks (they store the path).


