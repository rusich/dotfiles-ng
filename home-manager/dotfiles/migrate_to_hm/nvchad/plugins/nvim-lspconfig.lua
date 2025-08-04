---@type NvPluginSpec
local spec = {
    "neovim/nvim-lspconfig",
    dependencies = {
        -- format & linting
        {
            "jose-elias-alvarez/null-ls.nvim",
            config = function()
                require("custom.configs.null-ls")
            end,
        },
        {
            "williamboman/mason-lspconfig.nvim",
        },
    },
    config = function()
        require("plugins.configs.lspconfig")
        require("custom.configs.lspconfig")
    end, -- Override to setup mason-lspconfig
}

return spec
