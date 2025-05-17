require("avante").setup({
    provider = "claude",
})

local api = require("avante.api")

vim.keymap.set({ "n", "v" }, "<leader>aa", api.ask, { desc = "[a]vante: [a]sk" })
vim.keymap.set("n", "<leader>ar", api.refresh, { desc = "[a]vante: [r]efresh" })
vim.keymap.set("v", "<leader>ae", api.edit, { desc = "[a]vante: [e]dit" })
