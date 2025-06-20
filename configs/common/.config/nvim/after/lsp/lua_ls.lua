lsp = require("ekropotin.lsp")

return {
    on_attach = lsp.on_attach,
    capabilities = lsp.capabilities,
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
            },
        },
    },
}
