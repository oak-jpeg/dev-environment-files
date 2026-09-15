-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Cmd+S to save (WezTerm/Ghostty map Cmd+S -> Ctrl+S at the terminal level)
vim.keymap.set({ "n", "v" }, "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
vim.keymap.set("i", "<C-s>", "<Esc><cmd>w<CR>a", { desc = "Save file" })

-- Backspace/Delete deletes the Visual selection, like a normal text editor
vim.keymap.set("v", "<BS>", "d", { desc = "Delete selection" })
vim.keymap.set("v", "<Del>", "d", { desc = "Delete selection" })
