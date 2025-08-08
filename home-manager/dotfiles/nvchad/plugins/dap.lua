local function execute()
    local ft = vim.bo.filetype

    local cmd = "lua require('nvterm.terminal').send("
    if ft == "lua" then
        cmd = cmd .. "'lua %', 'horizontal')"
    elseif ft == "cs" then
        cmd = cmd .. "'dotnet run', 'horizontal')"
    elseif ft == "rust" then
        cmd = cmd .. "'cargo run', 'horizontal')"
    else
        cmd = cmd .. "'./%', 'horizontal')"
    end

    vim.cmd("lua require('nvterm.terminal').new('horizontal')")
    vim.cmd(cmd)

    vim.defer_fn(function()
        vim.cmd("startinsert")
    end, 100)
    vim.defer_fn(function()
        vim.cmd("stopinsert")
    end, 300)
end

local function setup_dap_hilights()
    -- vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#ffffff", bg = "#4a1717" })
    vim.api.nvim_set_hl(0, "DapBreakpoint", { bg = "#33111a" })
    vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#61afef", bg = "#31353f" })
    vim.api.nvim_set_hl(0, "DapStoppedBg", { bg = "#31353f" })
    vim.api.nvim_set_hl(0, "DapStoppedFg", { fg = "#98c379", bg = "#31353f" })

    vim.fn.sign_define(
        "DapBreakpoint",
        { text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
    )
    vim.fn.sign_define(
        "DapBreakpointCondition",
        { text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
    )
    vim.fn.sign_define(
        "DapBreakpointRejected",
        { text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
    )
    vim.fn.sign_define(
        "DapLogPoint",
        { text = "", texthl = "DapLogPoint", linehl = "DapLogPoint", numhl = "DapLogPoint" }
    )
    vim.fn.sign_define(
        "DapStopped",
        { text = "", texthl = "DapStoppedFg", linehl = "DapStoppedBg", numhl = "DapStoppedBg" }
    )
end

---@type NvPluginSpec
local spec = {
    "mfussenegger/nvim-dap",
    dependencies = {
        { "rcarriga/nvim-dap-ui" },
        {
            "theHamsta/nvim-dap-virtual-text",
            opts = {},
        },
    },
    keys = {
        {
            "<leader>dB",
            function()
                require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
            end,
            desc = "Breakpoint Condition (F8)",
        },
        {
            "<F8>",
            function()
                require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
            end,
            desc = "Debug: Breakpoint Condition",
        },
        {
            "<leader>db",
            function()
                require("dap").toggle_breakpoint()
            end,
            desc = "Toggle Breakpoint (F9)",
        },
        {
            "<F9>",
            function()
                require("dap").toggle_breakpoint()
            end,
            desc = "Debug: Toggle Breakpoint",
        },
        {
            "<leader>dc",
            function()
                require("dap").continue()
            end,
            desc = "Start/Continue (F5)",
        },
        {
            "<F5>",
            function()
                require("dap").continue()
            end,
            desc = "Debug: Start/Continue",
        },

        {
            "<leader>da",
            function()
                require("dap").run("codelldb", { args = vim.fn.input("Args: ") })
            end,
            desc = "Debug: Start with args",
        },
        {
            "<leader>dC",
            function()
                require("dap").run_to_cursor()
            end,
            desc = "Run to Cursor (F7)",
        },
        {
            "<F7>",
            function()
                require("dap").run_to_cursor()
            end,
            desc = "Debug: Run to Cursor",
        },
        {
            "<leader>dg",
            function()
                require("dap").goto_()
            end,
            desc = "Go to line (no execute)",
        },
        {
            "<leader>di",
            function()
                require("dap").step_into()
            end,
            desc = "Step Into (F11)",
        },
        {
            "<F11>",
            function()
                require("dap").step_into()
            end,
            desc = "Debug: Step Into",
        },
        {
            "<leader>dj",
            function()
                require("dap").down()
            end,
            desc = "Stack Down",
        },
        {
            "<leader>dk",
            function()
                require("dap").up()
            end,
            desc = "Stack Up",
        },
        {
            "<leader>dl",
            function()
                require("dap").run_last()
            end,
            desc = "Run Last",
        },
        {
            "<leader>dO",
            function()
                require("dap").step_out()
            end,
            desc = "Step Out (F12)",
        },
        {
            "<F12>",
            function()
                require("dap").step_out()
            end,
            desc = "Debug: Step Out",
        },
        {
            "<leader>do",
            function()
                require("dap").step_over()
            end,
            desc = "Step Over (F10)",
        },
        {
            "<F10>",
            function()
                require("dap").step_over()
            end,
            desc = "Debug: Step Over",
        },
        {
            "<leader>dp",
            function()
                require("dap").pause()
            end,
            desc = "Pause",
        },
        {
            "<leader>dr",
            function()
                require("dap").repl.toggle()
            end,
            desc = "Toggle REPL",
        },
        {
            "<leader>dI",
            "<Cmd>lua vim.ui.input('Input: ', function (input) local pid = vim.fn.system(\"pidof -s dotnet | tr -d '\\n' \"); vim.fn.system('echo ' .. input .. ' > /proc/'..pid.. '/fd/0') end)<cr>",
            desc = "Netcoredbg STDIN",
        },
        {
            "<leader>ds",
            function()
                require("dap").session()
            end,
            desc = "Session",
        },
        {
            "<leader>dt",
            function()
                require("dap").terminate()
            end,
            desc = "Terminate (F6)",
        },
        {
            "<F6>",
            function()
                require("dap").terminate()
            end,
            desc = "Debug: Terminate",
        },
        {
            "<leader>dw",
            "\"wyiw<cmd>lua require('dapui').elements.watches.add(vim.fn.getreg('w'))<cr>",
            desc = "Add to watchlist",
        },
        {
            "<leader>du",
            "<cmd>lua require('dapui').toggle()<cr>",
            desc = "Toggle UI",
        },
        {
            "<leader>dE",
            execute,
            desc = "Run in terminal (F4)",
        },
        {
            "<F4>",
            execute,
            desc = "Run in terminal",
        },
    },
    config = function()
        dofile(vim.g.base46_cache .. "dap")
        setup_dap_hilights()
    end,
}

return spec
