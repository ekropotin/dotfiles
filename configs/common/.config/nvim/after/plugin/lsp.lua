local lsp = require("ekropotin.lsp")

local mason_lspconfig = require("mason-lspconfig")

require("mason").setup()
-- Default fallback
for _, server_name in ipairs(mason_lspconfig.get_installed_servers()) do
    vim.lsp.config(server_name, {
        on_attach = lsp.on_attach,
        capabilities = lsp.capabilities,
    })
end

-- enable configs in "after/lsp"
require("mason-lspconfig").setup({
    ensure_installed = {
        "ruff",
        "pyrefly",
        "taplo",
        "emmet_ls",
        "svelte",
        "tailwindcss",
        "ts_ls",
        "terraformls",
        "bashls",
        "yamlls",
    },
    automatic_enable = {
        exclude = {
            -- rust-analyzer is managed by rustaceanvim (configured below)
            "rust_analyzer",
        },
    },
})
require("neodev").setup()

-- rustaceanvim is a ftplugin: no setup() call, just set vim.g.rustaceanvim
-- before any rust buffer loads (see :help rustaceanvim.config). It auto-detects
-- a mason-installed codelldb for DAP, so no manual adapter wiring is needed.
vim.g.rustaceanvim = {
    server = {
        on_attach = function(client, bufnr)
            lsp.on_attach(client, bufnr)
            vim.keymap.set("n", "<Leader>ca", function()
                vim.cmd.RustLsp("codeAction")
            end, { buffer = bufnr })
            vim.keymap.set("n", "<Leader>K", function()
                vim.cmd.RustLsp({ "hover", "actions" })
            end, { buffer = bufnr })
        end,
        capabilities = lsp.capabilities,
    },
}

-- setup Quickmark manually since it isn't managed by mason
-- (config is defined in after/lsp/quickmark.lua)
vim.lsp.enable("quickmark")
