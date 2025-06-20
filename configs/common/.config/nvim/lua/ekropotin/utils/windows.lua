return {
    close_current_floating_window = function()
        local win_id = vim.api.nvim_get_current_win()
        local win_config = vim.api.nvim_win_get_config(win_id)
        if win_config.relative ~= "" then
            vim.api.nvim_win_close(win_id, false)
        end
    end,
    focus_latest_floating_window = function()
        local win_list = vim.api.nvim_list_wins()
        print(win_list)
        for i = #win_list, 1, -1 do
            local win_id = win_list[i]
            local win_config = vim.api.nvim_win_get_config(win_id)
            if win_config.relative ~= "" then
                vim.api.nvim_set_current_win(win_id)
                break
            end
        end
    end,
}
