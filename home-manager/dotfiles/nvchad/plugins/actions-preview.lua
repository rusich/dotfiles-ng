---@type NvPluginSpec
local spec = {
    "aznhe21/actions-preview.nvim",
    opts = { -- options for vim.diff(): https://neovim.io/doc/user/lua.html#vim.diff()
        diff = {
            ctxlen = 3,
        },
        backend = { "telescope" },
    },
    keys = {
        {
            "<A-.>",
            "<cmd>lua require('actions-preview').code_actions()<cr>",
            mode = { "n", "v" },
            desc = "Code Actions",
        },
    },
}

return spec
