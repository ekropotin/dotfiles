require("conform").setup({
    formatters_by_ft = {
        python = { "ruff_fix", "ruff_format", "black" },
        markdown = { "markdownlint" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        lua = { "stylua" },
        rust = { "rustfmt" },
        ["*"] = { "trim_whitespace", "trim_newlines" },
    },
    format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
    },
})
