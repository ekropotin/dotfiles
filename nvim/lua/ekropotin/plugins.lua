require('lazy').setup({
    -- ThePrimeagen stuff
    'ThePrimeagen/harpoon',
    -- Theme
    { 'catppuccin/nvim',               name = "catppuccin", priority = 1000 },
    -- Tmux integration
    { 'christoomey/vim-tmux-navigator' },
    -- Git stuff
    'lewis6991/gitsigns.nvim',
    'tpope/vim-fugitive',
    'tpope/vim-rhubarb',
    -- Visualize undo branches
    'mbbill/undotree',
    {
        -- LSP Configuration & Plugins
        'neovim/nvim-lspconfig',
        dependencies = {
            -- Automatically install LSPs to stdpath for neovim
            {
                'williamboman/mason.nvim',
                opts = {
                    ensure_installed = {
                        "black",
                        "debugpy",
                        "ruff",
                        "pyright",
                        "rust-analyzer",
                        "codellbd",
                        "cpptools",
                        "marksman",
                        "markdownlint",
                        "taplo"
                    }
                }
            },
            'williamboman/mason-lspconfig.nvim',
            -- Additional lua configuration, makes nvim stuff amazing!
            'folke/neodev.nvim',
            -- Useful status updates for LSP
            -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },
        },
    },

    {
        -- Autocompletion
        'hrsh7th/nvim-cmp',
        dependencies = {
            -- Snippet Engine & its associated nvim-cmp source
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
            -- Adds LSP completion capabilities
            'hrsh7th/cmp-nvim-lsp',
            -- Adds a number of user-friendly snippets
            'rafamadriz/friendly-snippets',
        },
    },
    -- Useful plugin to show you pending keybinds.
    { 'folke/which-key.nvim',  opts = {} },
    {
        -- Add indentation guides even on blank lines
        'lukas-reineke/indent-blankline.nvim',
        main = 'ibl'
    },

    -- "gc" to comment visual regions/lines
    { 'numToStr/Comment.nvim', opts = {} },

    -- Fuzzy Finder (files, lsp, etc)
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            -- Fuzzy Finder Algorithm which requires local dependencies to be built.
            -- Only load if `make` is available. Make sure you have the system
            -- requirements installed.
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                -- NOTE: If you are having trouble with this installation,
                --       refer to the README for telescope-fzf-native for more instructions.
                build = 'make',
                cond = function()
                    return vim.fn.executable 'make' == 1
                end,
            }
        },
    },

    {
        -- Highlight, edit, and navigate code
        'nvim-treesitter/nvim-treesitter',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
        },
        build = ':TSUpdate',
    },
    'nvim-lualine/lualine.nvim',
    {
        'rcarriga/nvim-dap-ui',
        dependencies = {
            'mfussenegger/nvim-dap',
            "nvim-neotest/nvim-nio"
        }
    },
    {
        'kylechui/nvim-surround',
        version = "*",
        opts = {}
    },
    'stevearc/conform.nvim',
    -- Python stuff
    {
        'mfussenegger/nvim-dap-python',
        ft = 'python'
    },
    -- Rust stuff
    'simrat39/rust-tools.nvim',
    -- Show full call hierarchy
    {
        'ldelossa/litee-calltree.nvim',
        dependencies = {
            'ldelossa/litee.nvim'
        }
    },
    {
        "epwalsh/obsidian.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
    }
}, {})
