# Vim Modernization + IdeaVim Setup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate Vim plugin manager from Vundle to vim-plug, prune/update the plugin list, and add a `.ideavimrc` for WebStorm's IdeaVim plugin.

**Architecture:** Four targeted file changes in the `machine-setup` public repo. No new abstractions — direct edits to `.vimrc`, `setup.sh`, `bootstrap.sh`, and a new `.ideavimrc`. The vim-plug auto-install snippet in `.vimrc` ensures the setup is self-contained even without running `setup.sh`.

**Tech Stack:** Vim, vim-plug, IdeaVim (WebStorm plugin), Bash

---

## Files

| File | Action | Responsibility |
|------|--------|----------------|
| `.vimrc` | Modify | Replace Vundle block with vim-plug, update plugin list |
| `setup.sh` | Modify | Replace Vundle install step with vim-plug install step |
| `bootstrap.sh` | Modify | Add `.ideavimrc` symlink |
| `.ideavimrc` | Create | IdeaVim config with moderate parity to `.vimrc` |

---

### Task 1: Replace Vundle with vim-plug in `.vimrc`

**Files:**
- Modify: `machine-setup/.vimrc`

- [ ] **Step 1: Add vim-plug auto-install snippet**

Add this block immediately after `syntax on` (line 2), before any plugin declarations:

```vim
" Auto-install vim-plug if not present
let data_dir = '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
```

- [ ] **Step 2: Replace the Vundle block with vim-plug**

Remove these lines (currently at the bottom of the file, around line 87–119):
```vim
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'avakhov/vim-yaml'                          " Yaml syntax
Plugin 'bronson/vim-trailing-whitespace'           " Hightlight trailing whitespace
Plugin 'kien/rainbow_parentheses.vim'              " Parenthesis highlighting
Plugin 'MarcWeber/vim-addon-mw-utils'              " Interprets file by extension
Plugin 'tpope/vim-surround'                        " Better parenthesis support
Plugin 'itchyny/lightline.vim'                     " Better status line
Plugin 'git@github.com:itchyny/vim-gitbranch.git'  " Git Branch display
Plugin 'elmcast/elm-vim'                           " Elm plugin
Plugin 'elixir-lang/vim-elixir'                    " Elixir plugin
Plugin 'elzr/vim-json'                             " Json
Plugin 'w0rp/ale'                                  " Linting engine
Plugin 'pangloss/vim-javascript'                   " Javascript
Plugin 'othree/yajs.vim'                           " javascript syntax
Plugin 'mxw/vim-jsx'                               " JSX highlighting
Plugin 'eagletmt/ghcmod-vim'
Plugin 'Shougo/vimproc'
Plugin 'rust-lang/rust.vim'                        " Rust plugin
Plugin 'preservim/nerdtree'                        " The NERDTree
Plugin 'tomlion/vim-solidity'                      " Solidity syntax
Plugin 'leafgarland/typescript-vim'                " Typescript syntax
Plugin 'mileszs/ack.vim'                           " ack.vim (brew install ack the_silver_searcher)
Plugin 'tmhedberg/SimpylFold'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
```

Replace with:
```vim
call plug#begin('~/.vim/plugged')

Plug 'avakhov/vim-yaml'                " Yaml syntax
Plug 'bronson/vim-trailing-whitespace' " Highlight trailing whitespace
Plug 'luochen1990/rainbow'             " Parenthesis highlighting (maintained fork)
Plug 'tpope/vim-surround'              " Surround motions
Plug 'itchyny/lightline.vim'           " Better status line
Plug 'itchyny/vim-gitbranch'           " Git branch display
Plug 'elmcast/elm-vim'                 " Elm
Plug 'elixir-lang/vim-elixir'          " Elixir
Plug 'elzr/vim-json'                   " JSON
Plug 'dense-analysis/ale'              " Linting engine
Plug 'pangloss/vim-javascript'         " Javascript
Plug 'maxmellon/vim-jsx-pretty'        " JSX highlighting (maintained)
Plug 'rust-lang/rust.vim'              " Rust
Plug 'preservim/nerdtree'              " File tree
Plug 'leafgarland/typescript-vim'      " Typescript
Plug 'mileszs/ack.vim'                 " ack/ag search
Plug 'tmhedberg/SimpylFold'            " Python folding

call plug#end()
filetype plugin indent on
```

- [ ] **Step 3: Enable rainbow parentheses**

The new `luochen1990/rainbow` plugin requires an explicit activation setting. Add this line in the lightline/plugin config section (near the other `let g:` settings):

```vim
let g:rainbow_active = 1
```

- [ ] **Step 4: Verify Vim opens without errors**

```bash
vim --version | head -1
vim -c ':q' 2>&1
```

Expected: no Vundle-related errors. If vim-plug isn't installed yet, you'll see a one-time install prompt on first open — that's correct.

- [ ] **Step 5: Commit**

```bash
cd ~/Code/machine-setup
git checkout -b feat/vim-plug-migration
git add .vimrc
git commit -m "feat: migrate from Vundle to vim-plug, update plugin list"
```

---

### Task 2: Update `setup.sh` to install vim-plug

**Files:**
- Modify: `machine-setup/setup.sh`

- [ ] **Step 1: Replace the Vundle install section**

Find and replace the entire Vundle section (currently labeled `"10/12 Vundle + Vim plugins"`):

```bash
# ── 9. Vundle + Vim plugins ────────────────────────────────────────────────────
info "10/12 Vundle + Vim plugins"
VUNDLE_DIR="$HOME/.vim/bundle/Vundle.vim"
if [ -d "$VUNDLE_DIR" ]; then
  skip "Vundle"
else
  warn "Cloning Vundle..."
  mkdir -p "$HOME/.vim/bundle"
  if git clone https://github.com/VundleVim/Vundle.vim.git "$VUNDLE_DIR"; then
    ok "Vundle cloned"
    done_item "Vundle"
  else
    warn "Failed to clone Vundle (SSH keys may not be configured yet)."
    manual_item "Clone Vundle: git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim"
  fi
fi

mkdir -p "$HOME/.vim/undodir"

if [ -d "$VUNDLE_DIR" ]; then
  warn "Running :PluginInstall in Vim (this may take a moment)..."
  if vim -u "$HOME/.vimrc" +PluginInstall +qall 2>/dev/null; then
    ok "Vim plugins installed"
    done_item "Vim plugins (Vundle)"
  else
    warn "Vim plugin install failed or had errors (may be fine; check manually)."
    manual_item "Open vim and run :PluginInstall after SSH keys are configured"
  fi
else
  manual_item "Open vim and run :PluginInstall after SSH keys are configured"
fi
```

Replace with:

```bash
# ── 9. vim-plug + Vim plugins ─────────────────────────────────────────────────
info "10/12 vim-plug + Vim plugins"
PLUG_FILE="$HOME/.vim/autoload/plug.vim"
mkdir -p "$HOME/.vim/undodir"

if [ -f "$PLUG_FILE" ]; then
  skip "vim-plug"
else
  warn "Installing vim-plug..."
  mkdir -p "$HOME/.vim/autoload"
  if curl -fLo "$PLUG_FILE" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim; then
    ok "vim-plug installed"
    done_item "vim-plug"
  else
    warn "Failed to install vim-plug."
    manual_item "Install vim-plug: curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
  fi
fi

if [ -f "$PLUG_FILE" ]; then
  warn "Running :PlugInstall in Vim (this may take a moment)..."
  if vim +PlugInstall +qall 2>/dev/null; then
    ok "Vim plugins installed"
    done_item "Vim plugins (vim-plug)"
  else
    warn "Vim plugin install failed or had errors (may be fine; check manually)."
    manual_item "Open vim and run :PlugInstall"
  fi
else
  manual_item "Open vim and run :PlugInstall after vim-plug is installed"
fi
```

- [ ] **Step 2: Verify the script is syntactically valid**

```bash
bash -n ~/Code/machine-setup/setup.sh
```

Expected: no output (clean parse).

- [ ] **Step 3: Commit**

```bash
git add setup.sh
git commit -m "feat: replace Vundle install step with vim-plug in setup.sh"
```

---

### Task 3: Create `.ideavimrc`

**Files:**
- Create: `machine-setup/.ideavimrc`

- [ ] **Step 1: Create the file with the following content**

```vim
" IdeaVim configuration for WebStorm
" Mirrors ~/.vimrc settings appropriate for an IDE context.
" Intentionally omits: color settings, cursor shapes, ale, lightline,
" mix_format/elm_format — WebStorm handles these natively.

" ── Extensions ────────────────────────────────────────────────────────────────
set surround        " Visual S" to surround — mirrors vim-surround
set commentary      " gcc / gc motion to comment
set highlightedyank " Briefly highlight yanked text

" ── Search ────────────────────────────────────────────────────────────────────
set hlsearch
set incsearch
set ignorecase
set smartcase

" ── Editor ────────────────────────────────────────────────────────────────────
set number
set scrolloff=4
set history=1000
set clipboard=unnamed
set wrap
set expandtab
set tabstop=4
set shiftwidth=4
set showmode
set showcmd
set showmatch

" ── Splits ────────────────────────────────────────────────────────────────────
set splitright
set splitbelow

" ── Folding ───────────────────────────────────────────────────────────────────
set foldmethod=indent
set foldlevel=99
nnoremap <space> za

" ── Window navigation (works across editor splits) ────────────────────────────
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l

" ── Test runner (delegates to WebStorm's built-in runner) ─────────────────────
" Approximate equivalents to test.vim keymaps.
" <Leader>tn — run test nearest to cursor (Run class/method at cursor)
" <Leader>tf — run all tests in file
" <Leader>ts — run the current run configuration (closest to suite)
" <Leader>tl — rerun the last test run
nnoremap <Leader>tn :action RunClass<CR>
nnoremap <Leader>tf :action RerunTests<CR>
nnoremap <Leader>ts :action RunConfiguration<CR>
nnoremap <Leader>tl :action Rerun<CR>
```

- [ ] **Step 2: Verify the file exists**

```bash
ls -la ~/Code/machine-setup/.ideavimrc
```

Expected: file listed with correct path.

- [ ] **Step 3: Commit**

```bash
git add .ideavimrc
git commit -m "feat: add .ideavimrc for WebStorm IdeaVim"
```

---

### Task 4: Update `bootstrap.sh` to symlink `.ideavimrc`

**Files:**
- Modify: `machine-setup/bootstrap.sh`

- [ ] **Step 1: Add the symlink line**

In `bootstrap.sh`, after the existing `link "$DOTFILES_DIR/.gitignore-global" "$HOME/.gitignore-global"` line, add:

```bash
link "$DOTFILES_DIR/.ideavimrc" "$HOME/.ideavimrc"
```

The full symlink block should now read:

```bash
if [ "$(uname -m)" = "arm64" ]; then
  link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
else
  link "$DOTFILES_DIR/.zshrc-intel" "$HOME/.zshrc"
fi
link "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"
link "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
link "$DOTFILES_DIR/.gitignore-global" "$HOME/.gitignore-global"
link "$DOTFILES_DIR/.ideavimrc" "$HOME/.ideavimrc"
```

- [ ] **Step 2: Verify the script is syntactically valid**

```bash
bash -n ~/Code/machine-setup/bootstrap.sh
```

Expected: no output.

- [ ] **Step 3: Run bootstrap to create the live symlink**

```bash
bash ~/Code/machine-setup/bootstrap.sh
```

Expected: output includes `Linking /Users/<you>/.ideavimrc -> .../machine-setup/.ideavimrc`

- [ ] **Step 4: Verify the symlink exists**

```bash
ls -la ~/.ideavimrc
```

Expected: `~/.ideavimrc -> /Users/<you>/Code/machine-setup/.ideavimrc`

- [ ] **Step 5: Commit**

```bash
git add bootstrap.sh
git commit -m "chore: symlink .ideavimrc in bootstrap"
```

---

### Task 5: Install plugins and verify Vim

- [ ] **Step 1: Install vim-plug**

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

Expected: file downloaded to `~/.vim/autoload/plug.vim`

- [ ] **Step 2: Install all plugins**

```bash
vim +PlugInstall +qall
```

Expected: Vim opens, installs plugins in parallel, and exits cleanly. May take 30–60 seconds.

- [ ] **Step 3: Open Vim and verify no errors**

```bash
vim --startuptime /tmp/vim-startup.log +q && cat /tmp/vim-startup.log | tail -5
```

Open Vim interactively and check: no error messages on startup, `:PlugStatus` shows all plugins as OK.

- [ ] **Step 4: Push the branch**

```bash
git push -u origin feat/vim-plug-migration
```

- [ ] **Step 5: Open a PR**

Title: `feat: migrate to vim-plug, add .ideavimrc`

Body should note: Vundle removed, 5 plugins dropped (abandoned/redundant), 2 repos corrected, `.ideavimrc` added for WebStorm IdeaVim.
