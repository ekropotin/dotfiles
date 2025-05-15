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
require("mason-lspconfig").setup {
    automatic_enable = {
        exclude = {
            -- will setup below, wrapping by rust-tools
            "rust_analyzer"
        }
    }
}
require('neodev').setup()

-- rust_analyzer setup
local extension_path = vim.fn.exepath("codelldb") .. "/extension/"
local codelldb_path = extension_path .. "adapter/codelldb"
local liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"
local rt = require("rust-tools")
rt.setup({
    server = {
        on_attach = function(_, bufnr)
            lsp.on_attach(_, bufnr)
            vim.keymap.set("n", "<Leader>ca", rt.code_action_group.code_action_group,
                { buffer = bufnr })
            vim.keymap.set("n", "<Leader>K", function()
                rt.hover_actions.hover_actions()
                vim.schedule(rt.hover_actions.hover_actions)
            end, { buffer = bufnr })
        end,
        capabilities = lsp.capabilities,
        settings = {
            ["rust-analyzer"] = {
                checkOnSave = { command = "clippy" },
            },
        },
    },
    dap = {
        adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path)
    },
})
