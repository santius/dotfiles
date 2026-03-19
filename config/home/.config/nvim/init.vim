" ================================================================
" Neovim init.vim
" Objective: predictable behavior, minimal conflicts, clear sections.
" ================================================================

" ----------------------------------------------------------------
" Bootstrap and compatibility
" ----------------------------------------------------------------
set nocompatible

" nvim-tree requires netrw disabled before plugin load.
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1

" ----------------------------------------------------------------
" Plugin manager: vim-plug
" ----------------------------------------------------------------
call plug#begin('~/.local/share/nvim/plugged')

" UI and startup
Plug 'mhinz/vim-startify'
Plug 'romainl/vim-cool'
Plug 'folke/which-key.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'folke/tokyonight.nvim'
Plug 'rebelot/kanagawa.nvim'
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }

" Navigation and editing helpers
Plug 'tpope/vim-surround'
Plug 'numToStr/Comment.nvim'
Plug 'jiangmiao/auto-pairs'
Plug 'easymotion/vim-easymotion'
Plug 'mg979/vim-visual-multi'
Plug 'terryma/vim-smooth-scroll'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'ap/vim-css-color'
Plug 'MeanderingProgrammer/render-markdown.nvim'

" Search and file discovery
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'akinsho/toggleterm.nvim', { 'tag': '*' }

" Git workflow
Plug 'tpope/vim-fugitive'
Plug 'rbong/vim-flog'
Plug 'lewis6991/gitsigns.nvim'

" Tree and icons
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-tree/nvim-web-devicons'

" Syntax / parser
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Optional code minimap
Plug 'wfxr/minimap.vim'

call plug#end()

" ----------------------------------------------------------------
" Base editor behavior
syntax enable
filetype plugin indent on

" Visual theme: true color + global colorscheme
set termguicolors
set background=dark
silent! colorscheme tokyonight-night

" Optional GUI font (Neovide/Nvim-Qt). No effect in terminal if unsupported.
if exists('+guifont')
  set guifont=JetBrainsMono\ Nerd\ Font:h14
endif

set encoding=utf-8
" fileencoding is buffer-local; guard when sourcing init from non-modifiable buffers.
if &modifiable
  set fileencoding=utf-8
endif

" Line numbers: absolute in insert mode, relative in normal mode.
set number
set relativenumber

set ruler
set wildmenu
set showcmd
set laststatus=2
set noshowmode
set signcolumn=yes
set cursorline
set scrolloff=8
set sidescrolloff=8
set nowrap
set list
set listchars=tab:>\ ,trail:.,eol:$,nbsp:_,extends:>,precedes:<
set showmatch

" Search
set hlsearch
set incsearch
set ignorecase
set smartcase
set gdefault

" Indentation defaults
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set autoindent
set smartindent
set shiftround

" Performance and files
set updatetime=300
set timeoutlen=500
set lazyredraw
set hidden
set autoread
set nobackup
set nowritebackup
set noswapfile
set undofile
set undodir=~/.local/state/nvim/undo
call mkdir(expand(&undodir), 'p')

" System integration
set clipboard=unnamedplus
set mouse=a
set backspace=indent,eol,start
set noerrorbells
set visualbell
set t_vb=

" UI ergonomics
set cmdheight=1
set shortmess+=c
set pumheight=10
set splitright
set splitbelow
set conceallevel=0
set showtabline=2
set ambiwidth=single

" ----------------------------------------------------------------
" Leader and keymaps
" ----------------------------------------------------------------
let mapleader = ","

" Save and quit helpers
nnoremap <leader>w :w<CR>
nnoremap <leader>W :wqa<CR>
nnoremap <leader>Q :qa!<CR>
command! W w !sudo tee % > /dev/null

" Buffer navigation
nnoremap <leader>l :bnext<CR>
nnoremap <leader>h :bprevious<CR>
nnoremap <leader>q :bp <BAR> bd #<CR>

" Window navigation and resizing
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Move lines up/down in normal and visual mode
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv
nnoremap <leader>j :m .+1<CR>==
nnoremap <leader>k :m .-2<CR>==
vnoremap <leader>j :m '>+1<CR>gv=gv 
vnoremap <leader>k :m '<-2<CR>gv=gv

" Better indenting for selected blocks
vnoremap < <gv
vnoremap > >gv

" Config reload helpers
nnoremap <leader>vr :source $MYVIMRC<CR>

" Terminal helpers
function! OpenTerminalRightStack() abort
  if exists('g:term_right_stack_winid') && win_id2win(g:term_right_stack_winid) > 0
    call win_gotoid(g:term_right_stack_winid)
    if &buftype !=# 'terminal'
      unlet g:term_right_stack_winid
      call OpenTerminalRightStack()
      return
    endif

    " Move to the lowest terminal in that column before splitting.
    while 1
      let l:prev = win_getid()
      wincmd j
      if win_getid() == l:prev
        break
      endif
      if &buftype !=# 'terminal'
        call win_gotoid(l:prev)
        break
      endif
    endwhile

    belowright split
    terminal
  else
    botright vsplit
    terminal
  endif

  let g:term_right_stack_winid = win_getid()
  startinsert
endfunction

function! OpenTerminalRightColumn() abort
  botright vsplit
  terminal
  let g:term_right_stack_winid = win_getid()
  startinsert
endfunction

nnoremap <leader>tv :vertical terminal<CR>
nnoremap <leader>th :terminal<CR>
nnoremap <leader>tt :tab terminal<CR>
nnoremap <leader>tr :call OpenTerminalRightStack()<CR>
nnoremap <leader>tc :call OpenTerminalRightColumn()<CR>
nnoremap <leader>cmd :!
nnoremap <silent> <leader>to <cmd>ToggleTerm direction=horizontal<CR>
nnoremap <silent> <leader>tf <cmd>ToggleTerm direction=float<CR>
nnoremap <silent> <leader>ff <cmd>Telescope find_files<CR>
nnoremap <silent> <leader>fg <cmd>Telescope live_grep<CR>
nnoremap <silent> <leader>fb <cmd>Telescope buffers<CR>
nnoremap <silent> <leader>fh <cmd>Telescope help_tags<CR>

" NvimTree shortcuts
nnoremap <leader><Tab> :NvimTreeToggle<CR>
nnoremap <leader>nf :NvimTreeFindFile<CR>
nnoremap <leader>f :NvimTreeFocus<CR>

" Minimap toggle
nnoremap <silent> <leader>md <cmd>RenderMarkdown toggle<CR>
nnoremap <leader>mm :MinimapToggle<CR>

" Utility toggles
function! ToggleBackground() abort
  if &background ==# 'dark'
    set background=light
  else
    set background=dark
  endif
endfunction
nnoremap <leader>bg :call ToggleBackground()<CR>

function! ToggleNumber() abort
  if &relativenumber
    set norelativenumber
  else
    set relativenumber
  endif
endfunction
nnoremap <leader>r :call ToggleNumber()<CR>

" Colorscheme switcher
let g:colorscheme_cycle = ['tokyonight-night', 'kanagawa-wave', 'catppuccin-mocha']
let g:colorscheme_cycle_index = 0

function! SetColorscheme(name) abort
  execute 'silent! colorscheme ' . a:name
  let l:idx = index(g:colorscheme_cycle, a:name)
  if l:idx >= 0
    let g:colorscheme_cycle_index = l:idx
  endif
  echo 'Colorscheme: ' . a:name
endfunction

function! CycleColorscheme() abort
  let g:colorscheme_cycle_index = (g:colorscheme_cycle_index + 1) % len(g:colorscheme_cycle)
  call SetColorscheme(g:colorscheme_cycle[g:colorscheme_cycle_index])
endfunction

nnoremap <leader>ct :call CycleColorscheme()<CR>
nnoremap <leader>c1 :call SetColorscheme('tokyonight-night')<CR>
nnoremap <leader>c2 :call SetColorscheme('kanagawa-wave')<CR>
nnoremap <leader>c3 :call SetColorscheme('catppuccin-mocha')<CR>

" Stronger split borders (visibility only; width is still 1 cell)
function! s:ApplyUIHighlights() abort
  highlight WinSeparator gui=bold guifg=#7aa2f7 cterm=bold ctermfg=75
endfunction
call s:ApplyUIHighlights()

" ----------------------------------------------------------------
" Functions and autocommands
" ----------------------------------------------------------------
function! s:CleanExtraSpaces() abort
  let l:save_cursor = getpos('.')
  let l:old_query = getreg('/')
  silent! %s/\s\+$//e
  call setpos('.', l:save_cursor)
  call setreg('/', l:old_query)
endfunction

augroup CoreAutocmds
  autocmd!

  " Return to last known cursor position.
  autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line('$') | execute "normal! g`\"" | endif

  " Trim trailing spaces on save.
  autocmd BufWritePre * call s:CleanExtraSpaces()
  " Re-apply custom highlights after every colorscheme switch.
  autocmd ColorScheme * call s:ApplyUIHighlights()

  " Relative number only outside insert mode.
  autocmd InsertEnter * set norelativenumber
  autocmd InsertLeave * set relativenumber
augroup END

augroup FileTypeSpecific
  autocmd!
  autocmd FileType python setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4
  autocmd FileType javascript,typescript setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
  autocmd FileType markdown setlocal wrap spell textwidth=80
  autocmd FileType gitcommit setlocal spell textwidth=72
augroup END

augroup StartifyBehavior
  autocmd!
  autocmd BufDelete * if empty(filter(tabpagebuflist(), '!buflisted(v:val)')) && winnr('$') == 1 | Startify | endif
augroup END
augroup TerminalDefaults
  autocmd!
  autocmd TermOpen * startinsert
  autocmd BufEnter,WinEnter term://* startinsert
augroup END


" ----------------------------------------------------------------
" Plugin configuration
" ----------------------------------------------------------------
" Startify
let g:startify_session_dir = '~/.local/share/nvim/session'
let g:startify_lists = [
      \ { 'type': 'files',     'header': ['   Recent Files'] },
      \ { 'type': 'dir',       'header': ['   Current Directory: ' . getcwd()] },
      \ { 'type': 'sessions',  'header': ['   Sessions'] },
      \ { 'type': 'bookmarks', 'header': ['   Bookmarks'] },
      \ ]
let g:startify_bookmarks = [
      \ { 'i': '~/.config/nvim/init.vim' },
      \ { 'z': '~/.zshrc' },
      \ { 'z': '~/.gitconfig' },
      \ ]

" vim-cool
let g:CoolTotalMatches = 1

" Smooth scroll
nnoremap <silent> <leader><Up> :call smooth_scroll#up(&scroll, 25, 1)<CR>
nnoremap <silent> <leader><Down> :call smooth_scroll#down(&scroll, 15, 1)<CR>
" Minimap
let g:minimap_width = 48
let g:minimap_highlight_range = 1
let g:minimap_highlight_search = 1
let g:minimap_git_colors = 1

" Indent guides
let g:indent_guides_enable_on_vim_startup = 0
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1

" which-key setup
lua << EOF
local ok_wk, wk = pcall(require, 'which-key')
if ok_wk then
  wk.setup({
    plugins = {
      spelling = { enabled = true },
    },
    window = {
      border = 'single',
    },
  })
end
EOF

" telescope.nvim setup
lua << EOF
local ok_telescope, telescope = pcall(require, 'telescope')
if ok_telescope then
  telescope.setup({
    defaults = {
      layout_strategy = 'horizontal',
      sorting_strategy = 'ascending',
      layout_config = {
        prompt_position = 'top',
      },
      winblend = 0,
    },
  })
end
EOF

" toggleterm.nvim setup
lua << EOF
local ok_toggleterm, toggleterm = pcall(require, 'toggleterm')
if ok_toggleterm then
  toggleterm.setup({
    size = 18,
    shade_terminals = true,
    start_in_insert = true,
    insert_mappings = true,
    persist_size = true,
    close_on_exit = true,
    direction = 'horizontal',
  })
end
EOF

" lualine setup (statusline)
lua << EOF
local ok_lualine, lualine = pcall(require, 'lualine')
if ok_lualine then
  lualine.setup({
    options = {
      theme = 'auto',
      globalstatus = true,
      section_separators = '',
      component_separators = '',
    },
    sections = {
      lualine_a = {'mode'},
      lualine_b = {'branch', 'diff'},
      lualine_c = {{'filename', path = 1}},
      lualine_x = {'encoding', 'fileformat', 'filetype'},
      lualine_y = {'progress'},
      lualine_z = {'location'},
    },
  })
end
EOF

" Comment.nvim setup
lua << EOF
local ok_comment, comment = pcall(require, 'Comment')
if ok_comment then
  comment.setup()
end
EOF

" render-markdown.nvim setup
lua << EOF
local ok_render, render_markdown = pcall(require, 'render-markdown')
if ok_render then
  render_markdown.setup({
    file_types = { 'markdown' },
    render_modes = { 'n', 'c', 't' },
  })
end
EOF

" Flog: Git history graph with practical defaults
let g:flog_default_arguments = {
      \ 'all': 1,
      \ 'max_count': 300,
      \ 'date': 'short',
      \ }

" Open Flog
nnoremap <silent> <leader>gf  <cmd>Flog<CR>
nnoremap <silent> <leader>gfl <cmd>Flogsplit<CR>

" Flog for current file
nnoremap <silent> <leader>gff <cmd>Flog -- %<CR>

" nvim-tree
lua << EOF
require('nvim-tree').setup({
  sort_by = 'case_sensitive',
  sync_root_with_cwd = true,
  respect_buf_cwd = true,

  view = {
    preserve_window_proportions = true,
    width = {
      min = 28,
      max = 42,
      padding = 1,
    },
  },

  renderer = {
    group_empty = true,
    highlight_git = 'name',
    highlight_diagnostics = 'name',
    highlight_modified = 'name',
    indent_markers = {
      enable = true,
    },
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
        diagnostics = true,
        modified = true,
      },
    },
  },

  filters = {
    dotfiles = false,
    git_ignored = false,
  },

  git = {
    enable = true,
    ignore = false,
  },

  diagnostics = {
    enable = true,
    show_on_dirs = true,
  },

  modified = {
    enable = true,
    show_on_dirs = true,
  },

  actions = {
    open_file = {
      window_picker = {
        enable = false,
      },
      resize_window = true,
    },
  },

  update_focused_file = {
    enable = true,
    update_root = {
      enable = true,
    },
  },
})

vim.api.nvim_create_autocmd('BufEnter', {
  nested = true,
  callback = function()
    local only_tree = #vim.api.nvim_list_wins() == 1
      and vim.api.nvim_buf_get_name(0):match('NvimTree_') ~= nil
    local has_modified = #vim.fn.getbufinfo({ bufmodified = 1 }) > 0

    if only_tree and not has_modified then
      vim.cmd('quit')
    end
  end,
})
EOF

" gitsigns setup (safe if plugin is unavailable)
lua << EOF
local ok, gitsigns = pcall(require, 'gitsigns')
if ok then
  gitsigns.setup()
end
EOF

" Startup behavior
function! s:HandleVimStartup() abort
  if argc() == 0
    if exists(':Startify') == 2
      silent! Startify
    endif
    if exists(':NvimTreeOpen') == 2
      silent! NvimTreeOpen
      wincmd w
    endif
  elseif argc() == 1 && isdirectory(argv()[0])
    if exists(':NvimTreeOpen') == 2
      execute 'silent! NvimTreeOpen ' . fnameescape(argv()[0])
      wincmd w
    endif
  else
    if exists(':NvimTreeOpen') == 2
      silent! NvimTreeOpen
      wincmd w
    endif
  endif
endfunction

augroup VimStartup
  autocmd!
  autocmd VimEnter * call s:HandleVimStartup()
augroup END
