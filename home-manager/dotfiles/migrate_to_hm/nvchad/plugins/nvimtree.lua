---@type NvPluginSpec
local spec = {
    "nvim-tree/nvim-tree.lua",
    opts = {

        git = {
            enable = true,
        },

        renderer = {
            highlight_git = true,
            icons = {
                show = {
                    git = true,
                },
                glyphs = {
                    folder = {
                        default = "󰉋",
                    },
                },
            },
        },
    },
}

return spec
