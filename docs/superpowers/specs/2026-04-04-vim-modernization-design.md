# Vim Modernization + IdeaVim Setup

**Date:** 2026-04-04
**Repo:** machine-setup (public)

---

## Goal

Two parallel improvements to the machine setup:

1. Migrate the Vim plugin manager from Vundle to vim-plug, prune/update the plugin list
2. Add a `.ideavimrc` for WebStorm's IdeaVim plugin with moderate parity to `.vimrc`

---

## Section 1 — Plugin Manager Migration

Replace Vundle with **vim-plug**.

**Why vim-plug:**
- Parallel plugin installs (faster)
- Auto-installs on first launch via a bootstrap snippet — no manual `:PluginInstall`
- Simpler, actively maintained, widely adopted Vundle successor
- Syntax is nearly identical to Vundle (`Plug` instead of `Plugin`)

**Changes to `.vimrc`:**
- Remove `set rtp+=~/.vim/bundle/Vundle.vim`, `call vundle#begin()`, `call vundle#end()`
- Add vim-plug auto-install snippet at the top
- Replace `Plugin` declarations with `Plug`

**Changes to `setup.sh`:**
- Replace Vundle clone step with vim-plug `curl` install
- Replace headless `:PluginInstall` with `:PlugInstall`

---

## Section 2 — Plugin List

**Keep (repo corrected where moved):**
- `tpope/vim-surround`
- `bronson/vim-trailing-whitespace`
- `luochen1990/rainbow` (replaces abandoned `kien/rainbow_parentheses.vim`)
- `itchyny/lightline.vim`
- `itchyny/vim-gitbranch`
- `elmcast/elm-vim`
- `elixir-lang/vim-elixir`
- `dense-analysis/ale` (replaces `w0rp/ale`)
- `pangloss/vim-javascript`
- `maxmellon/vim-jsx-pretty` (replaces abandoned `mxw/vim-jsx`)
- `rust-lang/rust.vim`
- `preservim/nerdtree`
- `leafgarland/typescript-vim`
- `mileszs/ack.vim`
- `avakhov/vim-yaml`
- `elzr/vim-json`
- `tmhedberg/SimpylFold`

**Dropped (abandoned or redundant):**
- `kien/rainbow_parentheses.vim` — abandoned; replaced by luochen1990/rainbow
- `othree/yajs.vim` — redundant with pangloss/vim-javascript
- `mxw/vim-jsx` — abandoned; replaced by maxmellon/vim-jsx-pretty
- `eagletmt/ghcmod-vim` + `Shougo/vimproc` — Haskell tooling, unused
- `MarcWeber/vim-addon-mw-utils` — snipmate dependency only, snipmate not used
- `tomlion/vim-solidity` — Solidity, unused

---

## Section 3 — `.ideavimrc`

New file: `machine-setup/.ideavimrc`, symlinked to `~/.ideavimrc` via `bootstrap.sh`.

**IdeaVim extensions enabled:**
- `set surround` — visual-mode `S"` surrounding (mirrors vim-surround)
- `set commentary` — `gcc`/`gc` commenting
- `set highlightedyank` — briefly highlights yanked text

**Settings mirrored from `.vimrc`:**
- Search: `hlsearch`, `incsearch`, `ignorecase`, `smartcase`
- Editor: `number`, `scrolloff=4`, `history=1000`, `clipboard=unnamed`, `wrap`, `expandtab`, `tabstop=4`, `shiftwidth=4`
- Splits: `splitright`, `splitbelow`
- Folding: `foldmethod=indent`, `foldlevel=99`, `<space>` → `za`

**Keymaps:**
- `Ctrl+[hjkl]` → `<C-w>[hjkl]` — navigate between editor splits
- `<Leader>tn/tf/ts/tl` — delegate to WebStorm's native test runner via `action` (mirrors test.vim keymaps)

**Intentionally omitted:**
- All color/highlight settings — not applicable in IDE
- Cursor shape escape sequences (`t_SI`/`t_SR`/`t_EI`) — terminal-only
- `ale`, `lightline`, `mix_format_on_save`, `elm_format_on_save` — WebStorm handles natively

**`bootstrap.sh` change:**
Add one line: `link "$DOTFILES_DIR/.ideavimrc" "$HOME/.ideavimrc"`

---

## Files Changed

| File | Repo | Change |
|------|------|--------|
| `.vimrc` | machine-setup | Vundle → vim-plug, plugin list updated |
| `setup.sh` | machine-setup | Vundle install → vim-plug install |
| `bootstrap.sh` | machine-setup | Add `.ideavimrc` symlink |
| `.ideavimrc` | machine-setup | New file |
