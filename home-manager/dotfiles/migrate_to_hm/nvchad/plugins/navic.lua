---@type NvPluginSpec
local spec = {
    "SmiteshP/nvim-navic",
    dependencies = "neovim/nvim-lspconfig",
    opts = {
        lsp = {
            auto_attach = true,
            preference = nil,
        },
        highlight = true,
        separator = " > ",
        depth_limit = 5,
        depth_limit_indicator = "..",
        safe_output = true,
        lazy_update_context = false,
        click = true,
    },
    config = function(_, opts)
        dofile(vim.g.base46_cache .. "navic")
        require("nvim-navic").setup(opts)
    end,
}

return spec
