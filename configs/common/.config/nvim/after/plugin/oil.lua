require("oil").setup({
    view_options = {
        show_hidden = true,
    },
    keymaps = {
        -- keep <C-h>/<C-l> as window navigation instead of oil's defaults
        -- ("open in horizontal split" / "refresh")
        ["<C-h>"] = false,
        ["<C-l>"] = false,
    },
})
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
