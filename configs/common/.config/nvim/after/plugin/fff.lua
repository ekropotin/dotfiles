local fff = require("fff")

-- Defaults are sensible and cover what the telescope pickers were configured
-- for: fff indexes from the cwd honouring .gitignore, so hidden files are
-- included and .git is not -- the reason find_files needed hidden = true and
-- live_grep needed --hidden --iglob '!.git'.
fff.setup({})

-- Index and grep from the git root rather than the cwd, for when nvim was
-- started somewhere below it. fff scans a single root at a time, so this
-- repoints the index; it stays there until something moves it back.
local function live_grep_git_root()
    fff.change_indexing_directory(vim.fs.root(0, ".git") or vim.fn.getcwd())
    fff.live_grep()
end

vim.api.nvim_create_user_command("LiveGrepGitRoot", live_grep_git_root, {})

-- Keymaps
-- find_files already leads with recently opened files thanks to frecency, so
-- <leader>? seeds the git:modified constraint instead of being a second plain
-- file finder. The trailing space leaves the query open to narrow further.
vim.keymap.set("n", "<leader>?", function()
    fff.find_files({ query = "git:modified " })
end, { desc = "[?] Find modified files" })
vim.keymap.set("n", "<leader>sf", fff.find_files, { desc = "[s]earch [f]iles" })
vim.keymap.set("n", "<leader>sg", fff.live_grep, { desc = "[s]earch by [g]rep" })
vim.keymap.set({ "n", "x" }, "<leader>sw", fff.live_grep_under_cursor, { desc = "[s]earch current [w]ord" })
vim.keymap.set("n", "<leader>sG", live_grep_git_root, { desc = "[s]earch by [g]rep on Git Root" })
