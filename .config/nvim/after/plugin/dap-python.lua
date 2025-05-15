local dap_python = require("dap-python")
dap_python.setup(vim.fn.exepath("debugpy") .. "/venv/bin/python")

vim.keymap.set("n", "<leader>dpr", dap_python.test_method, { desc = "[d]ebug [p]ython [r]un" })
