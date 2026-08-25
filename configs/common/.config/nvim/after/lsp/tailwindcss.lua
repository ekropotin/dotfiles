return {
    -- advertise color support so tailwind-tools.nvim's document color swatches work
    -- even though we skip tailwind-tools' own (deprecated) lspconfig-based setup
    capabilities = {
        textDocument = {
            colorProvider = {
                dynamicRegistration = true,
            },
        },
    },
}
