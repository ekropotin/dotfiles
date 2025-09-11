local obsidian_vault_path = vim.env.OBSIDIAN_VAULT

if obsidian_vault_path == nil or obsidian_vault_path == "" then
    vim.notify("Obsidian: OBSIDIAN_VAULT environment variable is not set or empty", vim.log.levels.DEBUG)
    return
end

-- Expand the path to handle ~ and relative paths
local expanded_path = vim.fn.expand(obsidian_vault_path)

-- Convert to absolute path if it's not already
if not vim.startswith(expanded_path, "/") then
    expanded_path = vim.fn.fnamemodify(expanded_path, ":p")
end

-- Remove trailing slash if present
obsidian_vault_path = expanded_path:gsub("/$", "")

if vim.fn.isdirectory(obsidian_vault_path) ~= 1 then
    vim.notify("Obsidian: Vault directory does not exist: " .. obsidian_vault_path, vim.log.levels.WARN)
    return
end

local note_id_func = function(title)
    -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
    -- In this case a note with the title 'My new note' will be given an ID that looks
    -- like 'my-new-note-1657296016', and therefore the file name 'my-new-note-1657296016.md'
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

require("obsidian").setup({
    workspaces = {
        {
            name = "vault",
            path = obsidian_vault_path,
        },
    },
    ui = {
        enable = false,
    },
    daily_notes = {
        folder = "dailies",
        template = "daily.md",
    },
    templates = {
        subdir = "templates",
    },
    note_id_func = note_id_func,
    disable_frontmatter = true,
    attachments = {
        img_folder = "files",
        confirm_img_paste = false,
    },
})

local function createNoteWithDefaultTemplate()
    local TEMPLATE_FILENAME = "fleeting.md"
    local obsidian = require("obsidian").get_client()
    local utils = require("obsidian.util")

    -- prevent Obsidian.nvim from injecting it's own frontmatter table
    obsidian.opts.disable_frontmatter = true

    -- prompt for note title
    -- @see: borrowed from obsidian.command.new
    local note
    local title = utils.input("Enter title or path (optional): ")
    if not title then
        return
    elseif title == "" then
        title = nil
    end

    note = obsidian:create_note({ title = title, no_write = true })

    if not note then
        return
    end
    -- open new note in a buffer
    obsidian:open_note(note, { sync = true })
    -- NOTE: make sure the template folder is configured in Obsidian.nvim opts
    obsidian:write_note_to_buffer(note, { template = TEMPLATE_FILENAME })
    -- hack: delete empty lines before frontmatter; template seems to be injected at line 2
    vim.api.nvim_buf_set_lines(0, 0, 1, false, {})
end

vim.keymap.set("n", "<leader>nn", createNoteWithDefaultTemplate, { desc = "[n]ew [n]ote" })
vim.keymap.set("n", "<leader>snf", vim.cmd.ObsidianQuickSwitch, { desc = "[s]earch [n]otes [f]iles" })
vim.keymap.set("n", "<leader>sng", vim.cmd.ObsidianSearch, { desc = "[s]earch [n]otes [g]rep" })
vim.keymap.set("n", "<leader>snt", vim.cmd.ObsidianTags, { desc = "[s]earch [n]otes [t]ags" })
vim.keymap.set("n", "<leader>nbl", vim.cmd.ObsidianBacklinks, { desc = "[n]ote [b]ack [l]inks" })
vim.keymap.set("n", "<leader>nl", vim.cmd.ObsidianLinks, { desc = "[n]ote [l]inks" })
vim.keymap.set("n", "<leader>nt", vim.cmd.ObsidianTemplate, { desc = "[n]ote [t]emplate" })
