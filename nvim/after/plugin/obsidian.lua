local obsidian_vault_path = vim.env.OBSIDIAN_VAULT
if obsidian_vault_path == nil then
    obsidian_vault_path = vim.env.HOME
end

local note_id_func = function(title)
    -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
    -- In this case a note with the title 'My new note' will be given an ID that looks
    -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
    local prefix = ""
    if title ~= nil then
        -- If title is given, transform it into valid file name.
        prefix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
    else
        -- If title is nil, just add 4 random uppercase letters to the suffix.
        for _ = 1, 4 do
            prefix = prefix .. string.char(math.random(65, 90))
        end
    end
    return prefix .. "_" .. (os.time())
end

require('obsidian').setup({
    workspaces = {
        {
            name = "vault",
            path = obsidian_vault_path
        }
    },
    ui = {
        enable = false
    },
    daily_notes = {
        folder = "dailies"
    },
    templates = {
        subdir = "templates"
    },
    note_id_func = note_id_func
});

vim.keymap.set("n", "<leader>nn", vim.cmd.ObsidianNew, { desc = '[n]ote [n]ew' })
vim.keymap.set("n", "<leader>snf", vim.cmd.ObsidianQuickSwitch, { desc = '[s]earch [n]otes [f]iles' })
vim.keymap.set("n", "<leader>sng", vim.cmd.ObsidianSearch, { desc = '[s]earch [n]otes [g]rep' })
vim.keymap.set("n", "<leader>snt", vim.cmd.ObsidianTags, { desc = '[s]earch [n]otes [t]ags' })
vim.keymap.set("n", "<leader>nbl", vim.cmd.ObsidianBacklinks, { desc = '[n]ote [b]ack [l]inks' })
vim.keymap.set("n", "<leader>nl", vim.cmd.ObsidianLinks, { desc = '[n]ote [l]inks' })
