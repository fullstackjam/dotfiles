" Neovim Configuration
" A clean, modern setup with essential plugins

" Basic settings
set number
set relativenumber
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
set wrap
set linebreak
set showcmd
set wildmenu
set wildmode=longest:full,full
set cursorline
set scrolloff=8
set sidescrolloff=8
set mouse=a

" Search settings
set hlsearch
set incsearch
set ignorecase
set smartcase

" File settings
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8
set backupcopy=yes
set undofile
set undodir=~/.vim/undodir

" Colorscheme
set termguicolors
colorscheme default

" Key mappings
let mapleader = " "

" Clear search highlighting
nnoremap <leader>h :nohlsearch<CR>

" Better window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Resize windows
nnoremap <C-Up> :resize +2<CR>
nnoremap <C-Down> :resize -2<CR>
nnoremap <C-Left> :vertical resize -2<CR>
nnoremap <C-Right> :vertical resize +2<CR>

" Move lines up/down
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Buffer navigation
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprev<CR>
nnoremap <leader>bd :bdelete<CR>

" File navigation
nnoremap <leader>ff :find *<Space>
nnoremap <leader>fg :grep<Space>

" Auto commands
augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
augroup END

augroup filetype_settings
    autocmd!
    autocmd FileType python setlocal shiftwidth=4 tabstop=4
    autocmd FileType javascript setlocal shiftwidth=2 tabstop=2
    autocmd FileType typescript setlocal shiftwidth=2 tabstop=2
    autocmd FileType json setlocal shiftwidth=2 tabstop=2
    autocmd FileType yaml setlocal shiftwidth=2 tabstop=2
    autocmd FileType markdown setlocal wrap linebreak
augroup END

" Plugin manager (vim-plug)
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
    silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.local/share/nvim/plugged')

" Essential plugins
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'

" File navigation
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Git integration
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Syntax and language support
Plug 'sheerun/vim-polyglot'

" Status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Colorschemes
Plug 'morhetz/gruvbox'
Plug 'joshdick/onedark.vim'

call plug#end()

" Plugin configurations
let g:airline_powerline_fonts = 1
let g:airline_theme = 'onedark'

" FZF configuration
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>g :Rg<CR>

" Git configurations
nnoremap <leader>gs :Git<CR>
nnoremap <leader>gc :Git commit<CR>
nnoremap <leader>gp :Git push<CR>
nnoremap <leader>gl :Git log<CR>

" GitGutter configuration
let g:gitgutter_enabled = 1
let g:gitgutter_map_keys = 0
nnoremap <leader>gn :GitGutterNextHunk<CR>
nnoremap <leader>gp :GitGutterPrevHunk<CR>
nnoremap <leader>gh :GitGutterPreviewHunk<CR>

" Colorscheme settings
if has('termguicolors')
    set termguicolors
endif

" Enable gruvbox colorscheme
try
    colorscheme gruvbox
    set background=dark
catch
    colorscheme default
endtry
