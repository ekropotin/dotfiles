---------------------
-- General remappings
---------------------
vim.g.mapleader = " "

-- Quickly insert an empty new line without entering insert mode
vim.keymap.set(
    "n",
    "<leader>o",
    "o<Esc>",
    { desc = "[o]pen a new line below the current line without leaving the normal mode" }
)
vim.keymap.set(
    "n",
    "<leader>O",
    "O<Esc>",
    { desc = "[O]pen a new line above the current line without leaving the normal mode" }
)
-- Drag and drop selection with J and K
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
-- Don't move cursor at the EOL after appending lines
vim.keymap.set("n", "J", "mzJ`z")
-- Keep the cursor in the middle of the screen during half page scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- Keeps search term in the middle
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
-- When pasting over higlighted text, send it to the void register, thus preserving pasted text in the default register
vim.keymap.set("x", "<leader>p", [["_dP]])
-- Delete in the void register
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])
-- Yank in the system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "[y]ank selection in the system clipboard" })
-- current line only
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "[Y]ank current line in the system clipboard" })
-- Switch between projects
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", { desc = "Switch session" })
-- Disable arrows in non-insert mode
vim.keymap.set({ "n", "v", "x" }, "<Up>", "<nop>")
vim.keymap.set({ "n", "v", "x" }, "<Down>", "<nop>")
vim.keymap.set({ "n", "v", "x" }, "<Left>", "<nop>")
vim.keymap.set({ "n", "v", "x" }, "<Right>", "<nop>")
-- Keymaps for better default experience
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
-- Navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz", { desc = "Go to next item in the quick fix list" })
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz", { desc = "Go to previous item in the quick fix list" })
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Go to next item in the location list" })
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Go to previous item in the location list" })
vim.keymap.set("n", ".d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "/d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })
-- Remap keys for window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true, silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { noremap = true, silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { noremap = true, silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true, silent = true })

-- Close currently active floating window on Escape
local window_utils = require("ekropotin.utils.windows")
vim.keymap.set("n", "<Esc>", window_utils.close_current_floating_window, { noremap = true, silent = true })
