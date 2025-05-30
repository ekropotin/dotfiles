local M = {}

M.capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

local builtin = require("telescope.builtin")

M.on_attach = function(_, bufnr)
    local nmap = function(keys, func, desc)
        if desc then
            desc = "LSP: " .. desc
        end

        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
    end

    nmap("gd", builtin.lsp_definitions, "[G]oto [D]efinition")
    nmap("gr", builtin.lsp_references, "[G]oto [R]eferences")
    nmap("gI", builtin.lsp_implementations, "[G]oto [I]mplementation")
    nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

    nmap("K", function()
        vim.lsp.buf.hover()
        -- calling hover() twice jumps into the hover window
        vim.schedule(vim.lsp.buf.hover)
    end, "Hover Documentation")

    nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
    nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
    nmap("<leader>D", builtin.lsp_type_definitions, "Type [D]efinition")
    nmap("<leader>ds", builtin.lsp_document_symbols, "[D]ocument [S]ymbols")
    nmap("<leader>ws", builtin.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
    nmap("<leader>sid", vim.lsp.buf.signature_help, "[Si]gnature [D]ocumentation")
    nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
    nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
    nmap("<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "[W]orkspace [L]ist Folders")
    nmap("<leader>ch", vim.lsp.buf.incoming_calls, "[C]all [H]iearchy")

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
        vim.lsp.buf.format()
    end, { desc = "Format current buffer with LSP" })
end

return M
