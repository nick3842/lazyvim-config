-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.del("n", "<leader><space>")
vim.keymap.del("n", "<leader>ff")
-- Remove line moving keymaps
vim.keymap.del("n", "<A-j>")
vim.keymap.del("n", "<A-k>")
vim.keymap.del("i", "<A-j>")
vim.keymap.del("i", "<A-k>")
vim.keymap.del("v", "<A-j>")
vim.keymap.del("v", "<A-k>")

vim.keymap.set("n", "<leader>v", "<cmd>vsp<cr>")
vim.keymap.set("n", "<leader>h", "<cmd>noh<cr>")
vim.keymap.set("n", "<leader>p", "$p")

vim.keymap.set("n", "<C-h>", "<CMD>NavigatorLeft<CR>")
vim.keymap.set("n", "<C-j>", "<CMD>NavigatorDown<CR>")
vim.keymap.set("n", "<C-k>", "<CMD>NavigatorUp<CR>")
vim.keymap.set("n", "<C-l>", "<CMD>NavigatorRight<CR>")

vim.keymap.del({ "n" }, "<leader>l")
-- vim.keymap.del({ "n" }, "<leader>n")
vim.keymap.set(
  "n",
  "<leader>la",
  "<cmd>lua vim.lsp.buf.code_action()<cr>"
)
-- vim.keymap.set("n", "<leader>n", "<cmd>lua vim.diagnostic.goto_next()<cr>")
vim.keymap.del({ "n" }, "<leader>la")
vim.keymap.set(
  "n",
  "<leader>la",
  "<cmd>lua vim.lsp.buf.code_action()<cr>"
)
vim.keymap.set(
  "n",
  "<leader>a",
  "<cmd>lua vim.diagnostic.open_float()<cr>"
)
