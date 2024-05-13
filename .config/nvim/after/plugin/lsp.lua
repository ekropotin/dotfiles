local util = require("lspconfig/util")
local path = util.path
local function get_python_path(workspace)
    -- Use activated virtualenv.
    if vim.env.VIRTUAL_ENV then
        return path.join(vim.env.VIRTUAL_ENV, "bin", "python")
    end

    -- Find and use virtualenv in workspace directory.
    for _, pattern in ipairs({ "*", ".*" }) do
        local match = vim.fn.glob(path.join(workspace, pattern, "pyvenv.cfg"))
        if match ~= "" then
            return path.join(path.dirname(match), "bin", "python")
        end
    end

    -- Fallback to system Python.
    return exepath("python3") or exepath("python") or "python"
end

local builtin = require('telescope.builtin')

--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
    local nmap = function(keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    nmap('gd', builtin.lsp_definitions, '[G]oto [D]efinition')
    nmap('gr', builtin.lsp_references, '[G]oto [R]eferences')
    nmap('gI', builtin.lsp_implementations, '[G]oto [I]mplementation')
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    nmap('K', function()
        vim.lsp.buf.hover()
        -- calling hover() twice jumps into the hover window
        vim.schedule(vim.lsp.buf.hover)
    end, 'Hover Documentation')

    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    nmap('<leader>D', builtin.lsp_type_definitions, 'Type [D]efinition')
    nmap('<leader>ds', builtin.lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('<leader>ws', builtin.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
    nmap('<leader>sid', vim.lsp.buf.signature_help, '[Si]gnature [D]ocumentation')
    nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    nmap('<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, '[W]orkspace [L]ist Folders')
    nmap('<leader>ch', vim.lsp.buf.incoming_calls, '[C]all [H]iearchy')

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })
end

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

local lspconfig = require('lspconfig')
local mason_registry = require("mason-registry")
local codelldb = mason_registry.get_package("codelldb")
local extension_path = codelldb:get_install_path() .. "/extension/"
local codelldb_path = extension_path .. "adapter/codelldb"
local liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"
mason_lspconfig.setup_handlers {
    function(server_name)
        lspconfig[server_name].setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }
    end,
    ['pyright'] = function()
        lspconfig.pyright.setup({
            before_init = function(_, config)
                config.settings.python.pythonPath = get_python_path(config.root_dir)
            end,
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
                python = {
                    analysis = {
                        useLibraryCodeForTypes = true,
                        typeCheckingMode = "basic",
                    },
                },
            },
        })
    end,
    ["rust_analyzer"] = function()
        local rt = require("rust-tools")
        rt.setup({
            server = {
                capabilities = capabilities,
                on_attach = function(_, bufnr)
                    on_attach(_, bufnr)
                    -- Override default LSP actions with rust-tools-powered capabilities
                    vim.keymap.set("n", "<Leader>ca", rt.code_action_group.code_action_group, { buffer = bufnr })
                    vim.keymap.set("n", "<Leader>K", function()
                        rt.hover_actions.hover_actions()
                        vim.schedule(rt.hover_actions.hover_actions)
                    end, { buffer = bufnr })
                end,
                settings = {
                    -- to enable rust-analyzer settings visit:
                    -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
                    ["rust-analyzer"] = {
                        checkOnSave = {
                            command = "clippy"
                        },
                    }
                }
            },
            dap = {
                adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path)
            }
        })
    end
}
