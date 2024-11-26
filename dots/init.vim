call plug#begin()

" List your plugins here
Plug 'tpope/vim-sensible'
Plug 'gennaro-tedesco/nvim-jqx'
Plug 'cuducos/yaml.nvim'
Plug 'ellisonleao/glow.nvim'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'NvChad/nvim-colorizer.lua'
Plug 'Abstract-IDE/Abstract-cs'
Plug 'NTBBloodbath/galaxyline.nvim'
Plug 'lewis6991/gitsigns.nvim' 
Plug 'romgrk/barbar.nvim'
Plug 'edluffy/hologram.nvim'
Plug 'Xuyuanp/scrollbar.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'ms-jpq/coq_nvim'
Plug 'ms-jpq/coq.artifacts'
Plug 'ms-jpq/coq.thirdparty'

call plug#end()

" Copy Paste 
vnoremap <D-c> "+y
nnoremap <D-v> "+gP
inoremap <D-v> <C-r>+



" Goto buffer in position...
nnoremap <silent>    <A-1> <Cmd>BufferGoto 1<CR>
nnoremap <silent>    <A-2> <Cmd>BufferGoto 2<CR>
nnoremap <silent>    <A-3> <Cmd>BufferGoto 3<CR>
nnoremap <silent>    <A-4> <Cmd>BufferGoto 4<CR>
nnoremap <silent>    <A-5> <Cmd>BufferGoto 5<CR>
nnoremap <silent>    <A-6> <Cmd>BufferGoto 6<CR>
nnoremap <silent>    <A-7> <Cmd>BufferGoto 7<CR>
nnoremap <silent>    <A-8> <Cmd>BufferGoto 8<CR>
nnoremap <silent>    <A-9> <Cmd>BufferGoto 9<CR>
nnoremap <silent>    <A-0> <Cmd>BufferLast<CR>


" Tree
nnoremap  <C-T> :NvimTreeFocus<CR>

" Set recommended settings for nvim-tree
let g:nvim_tree_git_hl = 1
let g:nvim_tree_auto_close = 1
let g:nvim_tree_highlight_opened_files = 1


" Key mapping to toggle nvim-tree
nnoremap <C-n> :NvimTreeToggle<CR>

" Color scheme

colorscheme abscs



lua << EOF
require("nvim-tree").setup({})
-- Require Galaxyline
local gl = require('galaxyline')
require("galaxyline.themes.eviline")
require('hologram').setup{
    auto_display = true -- WIP automatic markdown image display, may be prone to breaking
}
-- Initialize COQ
vim.g.coq_settings = {
  auto_start = 'shut-up', -- Automatically start COQ
}

-- Optionally enable third-party integrations
require("coq_3p") {
  { src = "nvimlua", short_name = "nLUA" },   -- Lua API completion
  { src = "bc", short_name = "MATH", precision = 6 }, -- Calculator
}

EOF
