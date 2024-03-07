local dap_python = require("dap-python")
local debugpy_install_path = require("mason-registry").get_package("debugpy"):get_install_path()
dap_python.setup(debugpy_install_path .. '/venv/bin/python')

vim.keymap.set("n", "<leader>dpr", dap_python.test_method, {desc = '[d]ebug [p]ython [r]un'})
