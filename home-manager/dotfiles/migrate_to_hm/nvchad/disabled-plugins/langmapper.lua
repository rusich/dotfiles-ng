---@type NvPluginSpec
local spec = {
    "Wansmer/langmapper.nvim",
    lazy = false,
    priority = 1, -- High priority is needed if you will use `autoremap()`
    config = function()
        local langmapper = require("langmapper")
        langmapper.setup({ autoremap = true, buffer = true })
        langmapper.hack_get_keymap()
    end,
}

return spec
