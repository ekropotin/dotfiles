-- nvim-treesitter's "main" branch is a full rewrite (required once we moved to
-- nvim 0.12): parsers are installed via require("nvim-treesitter").install(),
-- and features (highlight/indent) are enabled per-buffer instead of through a
-- single .setup({highlight=..., indent=...}) call.
require("nvim-treesitter").install({
    "c",
    "cpp",
    "go",
    "lua",
    "python",
    "rust",
    "tsx",
    "javascript",
    "typescript",
    "vimdoc",
    "vim",
    "bash",
    "markdown",
    "markdown_inline",
    "svelte",
})

vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
        if not lang or not vim.treesitter.language.add(lang) then
            return
        end
        vim.treesitter.start(args.buf, lang)
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})

require("nvim-treesitter-textobjects").setup({
    select = {
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
    },
    move = {
        set_jumps = true, -- whether to set jumps in the jumplist
    },
})

local ts_select = require("nvim-treesitter-textobjects.select")
local ts_move = require("nvim-treesitter-textobjects.move")

vim.keymap.set({ "x", "o" }, "aa", function()
    ts_select.select_textobject("@parameter.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ia", function()
    ts_select.select_textobject("@parameter.inner", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "af", function()
    ts_select.select_textobject("@function.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "if", function()
    ts_select.select_textobject("@function.inner", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ac", function()
    ts_select.select_textobject("@class.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ic", function()
    ts_select.select_textobject("@class.inner", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "]m", function()
    ts_move.goto_next_start("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "]]", function()
    ts_move.goto_next_start("@class.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "]M", function()
    ts_move.goto_next_end("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "][", function()
    ts_move.goto_next_end("@class.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[m", function()
    ts_move.goto_previous_start("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[[", function()
    ts_move.goto_previous_start("@class.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[M", function()
    ts_move.goto_previous_end("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[]", function()
    ts_move.goto_previous_end("@class.outer", "textobjects")
end)
