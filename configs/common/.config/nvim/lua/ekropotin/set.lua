vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
-- vim.o.mouse = 'a'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = "yes"

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.wildmode = "longest,list"

-- Enable spellchecker
vim.o.spell = true
-- [[ Highlight on yank ]]
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = "*",
})

-- Show witespace characters
vim.api.nvim_set_option("list", true)
vim.api.nvim_set_option("listchars", "tab:»·,space:·,trail:·,extends:→,precedes:←")
vim.cmd("match EOLWhitespace /\\s\\+$/")
-- Uncomment the following line to highlight trailing whitespace
-- vim.cmd("highlight EOLWhitespace ctermbg=LightRed guibg=LightRed")

-- Use css grammar for postcss
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.postcss",
    command = "set filetype=css",
})
