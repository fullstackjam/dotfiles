" Basic settings
set number
set relativenumber
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab
set softtabstop=4
set smarttab
set wrap
set linebreak
set textwidth=0
set wrapmargin=0
set scrolloff=8
set sidescrolloff=8

" Search settings
set ignorecase
set smartcase
set incsearch
set hlsearch

" UI settings
set showcmd
set showmode
set ruler
set laststatus=2
set wildmenu
set wildmode=longest:list,full
set backspace=indent,eol,start
set mouse=a
set cursorline
set termguicolors
set signcolumn=yes

" File settings
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,gbk,gb2312,big5
set fileformats=unix,dos,mac

" Syntax highlighting
syntax on
filetype on
filetype plugin on
filetype indent on

" Color scheme
colorscheme default

" Key mappings
let mapleader = " "
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>wq :wq<CR>
nnoremap <leader>h :nohlsearch<CR>
nnoremap <leader>e :e<CR>
nnoremap <leader>r :source %<CR>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Better navigation
nnoremap <C-u> <C-u>zz
nnoremap <C-d> <C-d>zz
nnoremap n nzzzv
nnoremap N Nzzzv

" Better indenting
vnoremap < <gv
vnoremap > >gv

" Auto commands
autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab
autocmd FileType javascript setlocal tabstop=2 shiftwidth=2 expandtab
autocmd FileType html setlocal tabstop=2 shiftwidth=2 expandtab
autocmd FileType css setlocal tabstop=2 shiftwidth=2 expandtab
autocmd FileType yaml setlocal tabstop=2 shiftwidth=2 expandtab
