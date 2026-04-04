set nocompatible
syntax on

" Auto-install vim-plug if not present
let data_dir = '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Use Ctrl + [h,j,k,l] to move window focus
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l

" The NERDTree
map <C-n> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1

" test.vim
nnoremap <Leader>tn :TestNearest<CR>
nnoremap <Leader>tf :TestFile<CR>
nnoremap <Leader>ts :TestSuite<CR>
nnoremap <Leader>tl :TestLast<CR>
nnoremap <Leader>tg :TestVisit<CR>

" enable 256‑color support if it isn’t already
if &term =~ '256color'
  set t_Co=256
endif

" enable true‑color support
if has('termguicolors')
  set termguicolors
endif

" vim-mix-format
let g:mix_format_on_save = 1
let g:elm_format_on_save = 1
let g:rainbow_active = 1

" Disable swap files
set noswapfile

" Nicer colors for status and command line
set laststatus=2

" More readable command line mode completion
set wildmenu

" UI
set number			" line numbers
set ruler       " show the cursor position
set showcmd			" show command at bottom
set showmatch			" highlight matching [{()}]
" set clipboard=unnamedplus		" share clipboard and work with ctrl+v and ctrl+c
" unnamed plus was giving me some issues
set clipboard=unnamed
set history=1000

set tabstop=4			" spaces per tab
set shiftwidth=4        " shifts left or right by four spaces
set softtabstop=4		" tab while typing
set scrolloff=4			" scroll offset
set spell
" autocmd FileType markdown,text,gitcommit setlocal spell

set backspace=indent,eol,start	" can backspace in insert mode
set mouse=a			" can scroll with mouse
set expandtab " converts tabs to spaces
set wrap " enable line wrapping

set undofile " enable persistent undo
set ai       " autoindent
set si       " smart indent"

" Split window behavior
set splitright       " Vertical splits will automatically go to the right
set splitbelow       " Horizontal splits will automatically go below

" Enable folding
set foldmethod=indent
set foldlevel=99
nnoremap <space> za


" Better search
set hlsearch
set incsearch
set ignorecase
set smartcase     "type all lowercase = case-insensitive; type one+ words uppercase = case-sensitive

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
au FileType json setl sw=2 sts=2 et                " Indentation for json

" Git Branch/Lightline
let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'gitbranch#name'
      \ },
      \ }
" ================================================ ale lint ==========================================
let g:ale_linters = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'python': ['flake8'],
\   'javascript': ['eslint'],
\   'typescript': ['tsserver', 'tslint'],
\   'vue': ['eslint']
\}
let g:ale_fixers = {
\    'python': ['black', 'isort'],
\    'javascript': ['eslint'],
\    'typescript': ['prettier'],
\    'vue': ['eslint'],
\    'scss': ['prettier'],
\    'html': ['prettier']
\}
let g:ale_fix_on_save = 1

" Changes cursors depending on mode
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_SR = "\<Esc>]50;CursorShape=2\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

" ─── Custom high‑contrast highlights ───

" Change the default search result color: yellow background
highlight Search     ctermbg=yellow  ctermfg=NONE  gui=NONE
" Change the incremental‑search (as you type) color: green background
highlight IncSearch  ctermbg=cyan   ctermfg=NONE  gui=NONE
" Change Visual‑mode selection color: dark grey background
highlight Visual     ctermbg=darkgrey ctermfg=NONE gui=NONE
" (If you use CursorLine) change that too:
highlight CursorLine ctermbg=grey    cterm=NONE   gui=NONE

" ─── Spelling error highlights ───

" Invert fg/bg briefly so it really pops
highlight SpellBad cterm=reverse ctermfg=NONE ctermbg=NONE gui=reverse

" Missing-capital errors
highlight SpellCap   ctermfg=yellow  cterm=underline  gui=undercurl guisp=Yellow

" Rare words
highlight SpellRare  ctermfg=cyan    cterm=underline  gui=undercurl guisp=Cyan

" Local‑variant words
highlight SpellLocal ctermfg=green   cterm=underline  gui=undercurl guisp=Green

" ─── High‑contrast block cursor ───
" black text on a bright yellow block:
highlight Cursor    ctermfg=Black   ctermbg=Yellow cterm=NONE   gui=NONE
" (Optional) in Insert mode use a colored bar instead of block:
highlight CursorIM  ctermfg=Black   ctermbg=LightBlue cterm=NONE gui=NONE

" Persistent undo, stored outside the repo
if has("persistent_undo")
  set undofile
  set undodir=~/.vim/undodir
endif
