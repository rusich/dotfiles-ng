---@type NvPluginSpec
local spec = {
    "hrsh7th/nvim-cmp",
    dependencies = {
        {
            "Saecki/crates.nvim",
            event = { "BufRead Cargo.toml" },
            opts = {
                src = {
                    cmp = { enabled = true },
                },
            },
        },
    },
    opts = function(_, opts)
        local cmp = require("cmp")
        opts.sources = cmp.config.sources(vim.list_extend(opts.sources, {
            { name = "crates" },
        }))
    end,
}

return spec
