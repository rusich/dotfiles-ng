---@type NvPluginSpec
local spec = {
    {
        "chrisgrieser/nvim-origami",
        event = "BufReadPost",
        opts = {
            keepFoldsAcrossSessions = true,
            pauseFoldsOnSearch = true,
            setupFoldKeymaps = false,
        },
        config = true,
    },
}

return spec
