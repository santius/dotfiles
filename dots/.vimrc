" ====================
" Basic Settings
" ====================
set nocompatible              " Use Vim settings, rather than Vi settings
syntax enable                 " Enable syntax highlighting
filetype plugin indent on     " Enable file type detection

" Color scheme
if has('termguicolors')
    set termguicolors
endif
let g:solarized_termcolors=256
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
set listchars=tab:>\ ,trail:.,eol:$,nbsp:_,extends:>,precedes:<
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

" Additional UI improvements
set cmdheight=2             " Give more space for displaying messages
set shortmess+=c           " Don't pass messages to ins-completion-menu
set pumheight=10           " Makes popup menu smaller
set splitright             " Vertical splits will automatically be to the right
set splitbelow            " Horizontal splits will automatically be below
set conceallevel=0        " So that I can see `` in markdown files
set showtabline=2         " Always show tabs

" Better backup, swap and undo persistence
set directory=$HOME/.vim/swp//     " Centralize swp files
set backup
set backupdir=$HOME/.vim/backup//  " Centralize backups
set undofile
set undodir=$HOME/.vim/undo//      " Centralize undo history

" ====================
" Key Mappings
" ====================
let mapleader=","       " Set leader key

" Quick save
nnoremap <leader>w :w<CR>

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

" Save with sudo
command! W w !sudo tee % > /dev/null

" Additional Key Mappings
" Quick edit/source vimrc
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

" Window resizing with Leader key (more macOS friendly)
nnoremap <leader>j :resize -2<CR>
nnoremap <leader>k :resize +2<CR>
nnoremap <leader>l :vertical resize -2<CR>
nnoremap <leader>h :vertical resize +2<CR>

" Better indenting
vnoremap < <gv
vnoremap > >gv

" Find current file in NERDTree
nnoremap <leader>nf :NERDTreeFind<CR>

nnoremap <leader><Tab> :NERDTreeToggle<CR>
nnoremap <leader><f> :NERDTreeFocus<CR>

" NERDTree settings
let NERDTreeShowHidden=1                " Show hidden files
let NERDTreeMinimalUI=1                 " Hide help text
let NERDTreeAutoDeleteBuffer=1          " Delete buffer when file is deleted
let NERDTreeQuitOnOpen=0               " Keep NERDTree open when opening a file
let NERDTreeIgnore=['\.DS_Store$', '\.git$', '\.svn$', '\.hg$', 'node_modules$']

" Theme switching shortcuts
nnoremap <leader>t1 :colorscheme solarized<CR>
nnoremap <leader>t2 :colorscheme gruvbox<CR>
nnoremap <leader>t3 :colorscheme nord<CR>
nnoremap <leader>t4 :colorscheme dracula<CR>
nnoremap <leader>t5 :colorscheme onedark<CR>
nnoremap <leader>t6 :colorscheme palenight<CR>
nnoremap <leader>t7 :colorscheme tender<CR>
nnoremap <leader>t8 :colorscheme catppuccin<CR>

" Add a function to toggle dark/light mode
function! ToggleBackground()
    if &background == "dark"
        set background=light
    else
        set background=dark
    endif,t8
endfunction
nnoremap <leader>bg :call ToggleBackground()<CR>

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

" Switch between Catppuccin flavors
function! SwitchCatppuccinFlavour()
  let flavours = ['latte', 'frappe', 'macchiato', 'mocha']
  let current = index(flavours, g:catppuccin_flavour)
  let next = (current + 1) % len(flavours)
  let g:catppuccin_flavour = flavours[next]
  colorscheme catppuccin
  echo "Catppuccin flavour: " . g:catppuccin_flavour
endfunction
nnoremap <leader>cf :call SwitchCatppuccinFlavour()<CR>

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
filetype off
call pathogen#infect()
call pathogen#helptags()
filetype plugin indent on
syntax on

" CtrlP settings (if installed)
let g:ctrlp_show_hidden=1
let g:ctrlp_custom_ignore={
	\ 'dir':  '\.git$\|\.hg$\|\.svn$\|bower_components$\|dist$\|node_modules$\|project_files$\|test$',
	\ 'file': '\.exe$\|\.so$\|\.dll$\|\.pyc$'
	\ }

" Status line configuration
set statusline=%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)

" ALE (Linting) settings
if exists('g:loaded_ale')
    let g:ale_sign_error = '✘'
    let g:ale_sign_warning = '⚠'
    let g:ale_linters = {
    \   'python': ['flake8', 'pylint'],
    \   'javascript': ['eslint'],
    \}
endif

" ====================
" Advanced Functions
" ====================
" Add these new functions

" Toggle between number and relativenumber
function! ToggleNumber()
    if(&relativenumber == 1)
        set norelativenumber
        set number
    else
        set relativenumber
    endif
endfunction
nnoremap <leader>r :call ToggleNumber()<CR>

" Delete trailing white space on save
fun! CleanExtraSpaces()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun
autocmd BufWritePre * :call CleanExtraSpaces()

" ====================
" File Type Specific Settings
" ====================
augroup FileTypeSpecific
    autocmd!
    " Python
    autocmd FileType python setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4
    " JavaScript/TypeScript
    autocmd FileType javascript,typescript setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
    " Markdown
    autocmd FileType markdown setlocal wrap spell textwidth=80
    " Git commit
    autocmd FileType gitcommit setlocal spell textwidth=72
augroup END

" Add this to your Plugin Settings section
" Auto open NERDTree when starting Vim
autocmd VimEnter * NERDTree | wincmd p

" Close vim if NERDTree is the only window remaining
" autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Quick switch between NERDTree and file windows
nnoremap <leader>m :NERDTreeFocus<CR>
nnoremap <leader>f :wincmd l<CR>

" Terminal commands
" Open terminal in vertical split
nnoremap <leader>tv :vertical terminal<CR>

" Open terminal in horizontal split
nnoremap <leader>th :terminal<CR>

" Open terminal in new tab
nnoremap <leader>tt :tab terminal<CR>

" Quick shell command execution
nnoremap <leader>cmd :!

" Add to the Plugin Settings section
" Theme settings
" Gruvbox settings
let g:gruvbox_contrast_dark = 'medium'
let g:gruvbox_italic = 1

" Nord settings
let g:nord_italic = 1
let g:nord_underline = 1
let g:nord_italic_comments = 1
let g:nord_cursor_line_number_background = 1

" Dracula settings
let g:dracula_italic = 1
let g:dracula_colorterm = 0

" Onedark settings
let g:onedark_terminal_italics = 1

" Palenight settings
let g:palenight_terminal_italics = 1

" Tender settings
let g:tender_italic = 1

" Catppuccin settings
let g:catppuccin_flavour = "mocha" " latte, frappe, macchiato, mocha
let g:airline_theme = 'catppuccin'

" Add this to test
nnoremap <leader>xx :echo "Leader key works!"<CR>

" Smooth scroll configuration
noremap <silent> <c-u> :call smooth_scroll#up(&scroll, 15, 2)<CR>
noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 15, 2)<CR>
noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 15, 4)<CR>
noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 15, 4)<CR>

" Startify configuration
let g:startify_session_dir = '~/.vim/session'
let g:startify_lists = [
      \ { 'type': 'files',     'header': ['   Recent Files']            },
      \ { 'type': 'dir',       'header': ['   Current Directory: '. getcwd()] },
      \ { 'type': 'sessions',  'header': ['   Sessions']       },
      \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
      \ ]
let g:startify_bookmarks = [
      \ { 'v': '~/.vimrc' },
      \ { 'z': '~/.zshrc' },
      \ ]

let s:header_cmd = 'fortune | cowsay -W 80 -f $(cowsay -l | sed "/[A-Z].*$/d" | shuf -n 1)'
let g:startify_custom_header =  startify#center(split(system(s:header_cmd), '\n'))
let g:startify_session_autoload = 1
let g:startify_session_delete_buffers = 1
let g:startify_change_to_vcs_root = 1
let g:startify_fortune_use_unicode = 1
let g:startify_session_persistence = 1

" Make Startify appear when all buffers are closed
autocmd BufDelete * if empty(filter(tabpagebuflist(), '!buflisted(v:val)')) && winnr('$') == 1 | Startify | endif

" Minimap configuration
let g:minimap_width = 16
let g:minimap_auto_start = 1
let g:minimap_auto_start_win_enter = 1
let g:minimap_highlight_range = 1
let g:minimap_highlight_search = 1

" Minimap toggle
nnoremap <leader>mm :MinimapToggle<CR>

" vim-devicons configuration
let g:webdevicons_enable = 1
let g:webdevicons_enable_nerdtree = 1
let g:webdevicons_enable_airline_tabline = 1
let g:webdevicons_enable_airline_statusline = 1
let g:webdevicons_enable_startify = 1
let g:webdevicons_conceal_nerdtree_brackets = 1
let g:DevIconsEnableFoldersOpenClose = 1
let g:WebDevIconsUnicodeDecorateFolderNodes = 1
let g:DevIconsEnableFolderExtensionPatternMatching = 1

" Ensure UTF-8 is set
set encoding=utf8

" Fix alignment issues
set ambiwidth=single

" vim-cool configuration
let g:CoolTotalMatches = 1  " Show number of matches in the command line


" Airline configuration
let g:airline_powerline_fonts = 1                 " Enable powerline symbols
let g:airline#extensions#tabline#enabled = 1      " Enable the tabline
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#branch#enabled = 1       " Show git branch
let g:airline#extensions#hunks#enabled = 1        " Show git hunks
let g:airline_skip_empty_sections = 1            " Remove empty sections
let g:airline#extensions#tabline#enabled = 1

" Add keyboard shortcut to cycle through airline themes
function! s:AirlineThemeNext()
  let themes = ['solarized', 'gruvbox', 'dracula', 'onedark', 'palenight', 'tender']
  let current = index(themes, g:airline_theme)
  let next = (current + 1) % len(themes)
  let g:airline_theme = themes[next]
  AirlineRefresh
  echo 'Airline theme: ' . g:airline_theme
endfunction

nnoremap <leader>at :call <SID>AirlineThemeNext()<CR>

" vim-flog configuration
let g:flog_default_arguments = {
      \ 'max_count': 512,
      \ 'all': 1,
      \ 'date': 'short',
      \ }

" Flog key mappings
nnoremap <leader>gf :Flog<CR>
nnoremap <leader>gfl :Flogsplit<CR>
