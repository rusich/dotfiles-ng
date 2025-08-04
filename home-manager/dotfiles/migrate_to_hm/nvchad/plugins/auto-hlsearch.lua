---@type NvPluginSpec
local spec = {
    "asiryk/auto-hlsearch.nvim",
    event = "VeryLazy",
    config = true,
    opts = {
        remap_keys = { "?", "*", "#", "n", "N" },
    },
}

return spec
