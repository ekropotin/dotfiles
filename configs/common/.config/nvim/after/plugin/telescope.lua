local builtin = require("telescope.builtin")
local telescope = require("telescope")

-- File finding and content grep moved to fff (see after/plugin/fff.lua).
-- Telescope keeps the pickers fff has no equivalent for.
telescope.setup({
    defaults = {
        file_ignore_patterns = { "^.git/" },
        -- telescope's previewer still targets the old nvim-treesitter API
        -- (nvim-treesitter.parsers.ft_to_lang), which no longer exists after
        -- moving to the "main" branch rewrite. Fall back to regex/syntax
        -- highlighting in previews until telescope updates.
        preview = {
            treesitter = false,
        },
        mappings = {
            i = {
                ["<C-u>"] = false,
                ["<C-d>"] = false,
            },
        },
    },
})

pcall(builtin.load_extension, "fzf")

-- Keymaps
vim.keymap.set("n", "<leader>/", function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
        winblend = 10,
        previewer = false,
    }))
end, { desc = "[/] Fuzzily search in current buffer" })
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[s]earch [h]elp" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[s]earch [d]iagnostics" })
vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[s]earch [r]esume" })
vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "[s]earch [b]uffers" })
