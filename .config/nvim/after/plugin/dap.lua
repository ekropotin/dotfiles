local dap = require("dap")
local dap_widgets = require("dap.ui.widgets")

require("mason-nvim-dap").setup({
    ensure_installed = {
        "python",
        "codellbd",
        "cppdbg",
    },
})

vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debugger: Continue" })
vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debugger: step over" })
vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debugger: step into" })
vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debugger: step out" })
vim.keymap.set("n", "<Leader>b", dap.toggle_breakpoint, { desc = "toggle [b]reakpoint" })
vim.keymap.set("n", "<Leader>B", dap.set_breakpoint, { desc = "set [B]reakpoint" })
vim.keymap.set("n", "<Leader>lp", function()
    dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end, { desc = "Debugger: Continue" })
vim.keymap.set("n", "<Leader>dr", dap.repl.open, { desc = "[d]ebugger [r]epl" })
vim.keymap.set("n", "<Leader>dl", dap.run_last, { desc = "[d]ebugger run [l]ast" })
vim.keymap.set({ "n", "v" }, "<Leader>dh", dap_widgets.hover, { desc = "[d]ebugger [h]over" })
vim.keymap.set({ "n", "v" }, "<Leader>dp", dap_widgets.preview, { desc = "[d]ebugger [p]review" })

vim.keymap.set("n", "<Leader>df", function()
    dap_widgets.centered_float(dap_widgets.frames)
end, { desc = "[d]ebugger frames" })
vim.keymap.set("n", "<Leader>ds", function()
    dap_widgets.centered_float(dap_widgets.scopes)
end, { desc = "[d]ebugger [s]copes" })
