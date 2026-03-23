vim.api.nvim_create_autocmd('PackChanged', { callback = function(ev)
  local name, kind = ev.data.spec.name, ev.data.kind
  if name == 'nvim-treesitter' and kind == 'update' then
    if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
    vim.cmd('TSUpdate')
  end
end })

vim.pack.add({
  'https://github.com/nvim-mini/mini.nvim',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/mason-org/mason.nvim',
})

require("mason").setup()

local ensure_installed = {
  "lua-language-server",
  "ruff",
  "bash-language-server",
}

for _, pkg in ipairs(ensure_installed) do
  local p = require("mason-registry").get_package(pkg)
  if not p:is_installed() then
    p:install()
  end
end

vim.cmd.colorscheme('miniwinter')
require('mini.basics').setup()
require('mini.surround').setup()
require("mason").setup()
vim.lsp.enable({ 'lua_ls' })

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)
vim.keymap.set("n", "<leader>lz", vim.cmd.Lazy)
vim.keymap.set("n", "<leader>m", vim.cmd.Mason, { desc = "Open Mason" })
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.o.clipboard = 'unnamedplus'
vim.o.hlsearch = false
vim.o.shiftwidth = 4

