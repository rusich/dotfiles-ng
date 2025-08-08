---@type NvPluginSpec
local spec = {
    "folke/flash.nvim",
    event = "VeryLazy",
    vscode = true,
    opts = {},
    keys = {
        {
            "s",
            mode = { "n" },
            function()
                require("flash").jump()
            end,
            desc = "Flash",
        },
    },
}

return spec
