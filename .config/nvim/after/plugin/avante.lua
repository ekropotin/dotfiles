require("avante").setup({
    -- agentic mode is very glitchy right now
    mode = "legacy",
    provider = "claude",
    providers = {
        gemini = {
            model = "gemini-2.5-pro-exp-03-25",
        },
        claude = {
            model = "claude-sonnet-4-20250514",
        },
    },
})

local api = require("avante.api")

vim.keymap.set({ "n", "v" }, "<leader>aa", api.ask, { desc = "[a]vante: [a]sk" })
vim.keymap.set("n", "<leader>ar", api.refresh, { desc = "[a]vante: [r]efresh" })
vim.keymap.set("v", "<leader>ae", api.edit, { desc = "[a]vante: [e]dit" })
