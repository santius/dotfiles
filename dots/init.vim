" ====================
" Plugin Management
" ====================
call plug#begin()

" Core Functionality
Plug 'tpope/vim-sensible'                " Sensible defaults
Plug 'tpope/vim-surround'                " Surround text objects
Plug 'tpope/vim-commentary'              " Comment code
Plug 'tpope/vim-repeat'                  " Better command repeat
Plug 'tpope/vim-fugitive'                " Git integration

" File Navigation & Search
Plug 'nvim-tree/nvim-tree.lua'          " File explorer
Plug 'nvim-tree/nvim-web-devicons'      " File icons
Plug 'nvim-telescope/telescope.nvim'     " Fuzzy finder
Plug 'nvim-lua/plenary.nvim'            " Required by telescope

" UI Enhancements
Plug 'nvim-lualine/lualine.nvim'        " Status line
Plug 'romgrk/barbar.nvim'               " Buffer line
Plug 'lewis6991/gitsigns.nvim'          " Git signs
Plug 'lukas-reineke/indent-blankline.nvim' " Indent guides
Plug 'NvChad/nvim-colorizer.lua'        " Color highlighter
Plug 'folke/which-key.nvim'             " Key binding helper

" Code Intelligence
Plug 'neovim/nvim-lspconfig'            " LSP support
Plug 'hrsh7th/nvim-cmp'                 " Completion engine
Plug 'hrsh7th/cmp-nvim-lsp'             " LSP completion
Plug 'hrsh7th/cmp-buffer'               " Buffer completion
Plug 'hrsh7th/cmp-path'                 " Path completion
Plug 'L3MON4D3/LuaSnip'                 " Snippet engine
Plug 'saadparwaiz1/cmp_luasnip'         " Snippet completion
Plug 'windwp/nvim-autopairs'            " Auto pairs
Plug 'numToStr/Comment.nvim'            " Smart commenting

" Language Support
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'fatih/vim-go'                     " Go support
Plug 'rust-lang/rust.vim'               " Rust support
Plug 'pangloss/vim-javascript'          " JavaScript support
Plug 'MaxMEllon/vim-jsx-pretty'         " JSX support
Plug 'leafgarland/typescript-vim'       " TypeScript support
Plug 'vim-python/python-syntax'         " Python support

" File Type Support
Plug 'gennaro-tedesco/nvim-jqx'         " JSON support
Plug 'cuducos/yaml.nvim'                " YAML support
Plug 'ellisonleao/glow.nvim'            " Markdown preview

" Utilities
Plug 'edluffy/hologram.nvim'            " Image display
Plug 'Xuyuanp/scrollbar.nvim'           " Scrollbar
Plug 'folke/zen-mode.nvim'              " Distraction-free mode
Plug 'folke/trouble.nvim'               " Diagnostics window

call plug#end()

" ====================
" Basic Settings
" ====================
set encoding=utf-8
set fileencoding=utf-8
set number relativenumber      " Show relative line numbers
set cursorline                " Highlight current line
set mouse=a                   " Enable mouse support
set hidden                    " Allow hidden buffers
set nobackup                 " No backup files
set nowritebackup            " No backup files during write
set noswapfile               " No swap files
set updatetime=300           " Faster completion
set timeoutlen=500           " Faster key sequence completion
set scrolloff=8              " Keep 8 lines above/below cursor
set sidescrolloff=8          " Keep 8 columns left/right of cursor
set signcolumn=yes           " Always show sign column
set expandtab                " Use spaces instead of tabs
set tabstop=4                " Tab width
set shiftwidth=4             " Indent width
set smartindent              " Smart indentation
set ignorecase               " Case-insensitive search
set smartcase                " Case-sensitive if uppercase present
set clipboard+=unnamedplus   " Use system clipboard

" ====================
" Key Mappings
" ====================
" Set leader key
let mapleader = " "

" Copy Paste
vnoremap <D-c> "+y
nnoremap <D-v> "+gP
inoremap <D-v> <C-r>+

" Buffer navigation
nnoremap <silent> <A-1> <Cmd>BufferGoto 1<CR>
nnoremap <silent> <A-2> <Cmd>BufferGoto 2<CR>
nnoremap <silent> <A-3> <Cmd>BufferGoto 3<CR>
nnoremap <silent> <A-4> <Cmd>BufferGoto 4<CR>
nnoremap <silent> <A-5> <Cmd>BufferGoto 5<CR>
nnoremap <silent> <A-6> <Cmd>BufferGoto 6<CR>
nnoremap <silent> <A-7> <Cmd>BufferGoto 7<CR>
nnoremap <silent> <A-8> <Cmd>BufferGoto 8<CR>
nnoremap <silent> <A-9> <Cmd>BufferGoto 9<CR>
nnoremap <silent> <A-0> <Cmd>BufferLast<CR>

" File explorer
nnoremap <C-n> :NvimTreeToggle<CR>
nnoremap <C-t> :NvimTreeFocus<CR>

" ====================
" Theme & Colors
" ====================
set termguicolors
colorscheme abscs

" ====================
" Plugin Configuration
" ====================
lua << EOF
-- Tree configuration
require("nvim-tree").setup({
    git = {
        enable = true,
        ignore = false,
    },
    view = {
        width = 30,
    },
})

-- LSP configuration
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Setup language servers
local servers = { 'pyright', 'tsserver', 'gopls', 'rust_analyzer' }
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
        capabilities = capabilities,
    }
end

-- Completion setup
local cmp = require('cmp')
cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' },
    })
})

-- Treesitter configuration
require('nvim-treesitter.configs').setup({
    ensure_installed = {
        "lua", "vim", "python", "javascript",
        "typescript", "go", "rust"
    },
    highlight = { enable = true },
    indent = { enable = true },
})

-- Status line
require('lualine').setup({
    options = {
        theme = 'auto',
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
    },
})

-- Git signs
require('gitsigns').setup()

-- Auto pairs
require('nvim-autopairs').setup()

-- Which key
require('which-key').setup()

-- Colorizer
require('colorizer').setup()

-- Comments
require('Comment').setup()

-- Trouble
require('trouble').setup()

-- Hologram
require('hologram').setup({
    auto_display = true
})
EOF
