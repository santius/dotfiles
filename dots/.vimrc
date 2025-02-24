" ====================
" Basic Settings
" ====================
set nocompatible              " Use Vim settings, rather than Vi settings
syntax enable                 " Enable syntax highlighting
filetype plugin indent on     " Enable file type detection

" Color scheme
colorscheme solarized
let g:solarized_termtrans=1
set background=dark
set termguicolors            " Enable true color support

" UI Configuration
set number relativenumber     " Show relative line numbers
set ruler                    " Show cursor position
set wildmenu                 " Enhanced command-line completion
set showcmd                  " Show partial commands
set laststatus=2            " Always show status line
set noshowmode              " Don't show mode (shown in status line)
set signcolumn=yes          " Always show sign column
set cursorline              " Highlight current line
set scrolloff=8             " Keep 8 lines above/below cursor
set sidescrolloff=8         " Keep 8 columns left/right of cursor
set nowrap                  " Don't wrap lines
set list                    " Show invisible characters
set listchars=tab:▸\ ,trail:·,eol:¬,nbsp:_,extends:❯,precedes:❮
set showmatch               " Show matching brackets

" Search Settings
set hlsearch                " Highlight search results
set incsearch               " Show search matches as you type
set ignorecase             " Ignore case when searching
set smartcase              " Case-sensitive if search contains uppercase
set gdefault               " Add the g flag to search/replace by default

" Indentation
set expandtab              " Use spaces instead of tabs
set tabstop=2             " Number of spaces for tab
set softtabstop=2         " Number of spaces for tab while editing
set shiftwidth=2          " Number of spaces for autoindent
set autoindent            " Copy indent from current line
set smartindent           " Smart autoindenting
set shiftround            " Round indent to multiple of shiftwidth

" File Handling
set encoding=utf-8        " Use UTF-8 encoding
set fileencoding=utf-8    " Use UTF-8 encoding for written files
set hidden                " Allow hidden buffers
set autoread              " Reload files changed outside vim
set nobackup             " Don't create backup files
set nowritebackup        " Don't create backup files during write
set noswapfile           " Don't create swap files
set undofile             " Persistent undo
set undodir=~/.vim/undo  " Set undo directory

" Performance
set updatetime=300       " Faster completion
set timeoutlen=500      " Faster key sequence completion
set lazyredraw          " Don't redraw while executing macros
set ttyfast             " Faster terminal connection

" System Integration
set clipboard=unnamed    " Use system clipboard
set mouse=a             " Enable mouse in all modes
set backspace=indent,eol,start  " Make backspace work as expected
set noerrorbells        " Disable error bells
set visualbell t_vb=    " Disable visual bell

" ====================
" Key Mappings
" ====================
let mapleader=","       " Set leader key

" Quick save
nnoremap <leader>w :w<CR>

" Clear search highlighting
nnoremap <leader><space> :noh<CR>

" Buffer navigation
nnoremap <leader>l :bnext<CR>
nnoremap <leader>h :bprevious<CR>
nnoremap <leader>q :bp <BAR> bd #<CR>

" Split navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Move lines up/down
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Strip trailing whitespace
nnoremap <leader>ss :call StripWhitespace()<CR>

" Save with sudo
command! W w !sudo tee % > /dev/null

" ====================
" Functions
" ====================
" Strip trailing whitespace
function! StripWhitespace()
	let save_cursor = getpos(".")
	let old_query = getreg('/')
	:%s/\s\+$//e
	call setpos('.', save_cursor)
	call setreg('/', old_query)
endfunction

" ====================
" Auto Commands
" ====================
if has("autocmd")
	" Enable file type detection
	filetype on

	" Treat .json files as JavaScript
	autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript

	" Treat .md files as Markdown
	autocmd BufNewFile,BufRead *.md setlocal filetype=markdown

	" Return to last edit position when opening files
	autocmd BufReadPost *
		\ if line("'\"") > 0 && line("'\"") <= line("$") |
		\   exe "normal! g`\"" |
		\ endif

	" Automatically remove trailing whitespace on save
	autocmd BufWritePre * :%s/\s\+$//e

	" Set relative numbers in normal mode, absolute in insert mode
	autocmd InsertEnter * :set norelativenumber
	autocmd InsertLeave * :set relativenumber
endif

" ====================
" Plugin Settings
" ====================
" Enable Pathogen
execute pathogen#infect()

" NERDTree settings (if installed)
let NERDTreeShowHidden=1
let NERDTreeIgnore=['\.DS_Store$', '\.git$', '\.svn$']

" CtrlP settings (if installed)
let g:ctrlp_show_hidden=1
let g:ctrlp_custom_ignore={
	\ 'dir':  '\.git$\|\.hg$\|\.svn$\|bower_components$\|dist$\|node_modules$\|project_files$\|test$',
	\ 'file': '\.exe$\|\.so$\|\.dll$\|\.pyc$'
	\ }

" Status line configuration
set statusline=%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)