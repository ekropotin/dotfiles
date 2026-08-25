local lsp = require("ekropotin.lsp")

return {
    -- quickmark-server should be in the PATH
    cmd = { "quickmark-server" },
    filetypes = { "markdown" },
    root_markers = { "quickmark.toml", ".git" },
    on_attach = lsp.on_attach,
    capabilities = lsp.capabilities,
    settings = {},
}
