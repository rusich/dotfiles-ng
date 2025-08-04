---@type NvPluginSpec
local spec = {
    "rcarriga/nvim-dap-ui",
    dependencies = {
        { "nvim-neotest/nvim-nio" },
    },
    -- stylua: ignore
    keys = {
        { "<leader>de", function() require("dapui").eval(nil, { enter = true }) end, desc = "Eval (F2)", mode = { "n", "v" } },
        { "<F2>",       function() require("dapui").eval(nil, { enter = true }) end, desc = "Eval",      mode = { "n", "v" } },

    },
    opts = {},
    config = function(_, opts)
        -- setup dap config by VsCode launch.json file
        -- require("dap.ext.vscode").load_launchjs()
        local dap = require("dap")
        local dapui = require("dapui")
        dapui.setup(opts)
        dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open({})
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close({})
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close({})
        end
    end,
}

return spec
