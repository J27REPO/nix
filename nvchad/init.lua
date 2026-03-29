-- Bootstrap lazy.nvim
vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath
  }
end
vim.opt.rtp:prepend(lazypath)

-- Configurar plugins: NvChad
require("lazy").setup({
  { "NvChad/NvChad", lazy = false },
})

-- Base NvChad config
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")
require "nvchad.mappings"
require "options"
require "autocmds"
require "chadrc"

-- ========================
-- CUSTOM KEYBINDINGS
-- ========================
local map = vim.keymap.set

-- Save file: Space + s + s
map("n", "<leader>ss", ":w<CR>", { desc = "Save file" })

-- Close neovim: Space + q + q
map("n", "<leader>qq", ":q<CR>", { desc = "Close neovim" })
