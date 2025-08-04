---@type NvPluginSpec
local spec = {
    "Saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
        src = {
            cmp = { enabled = true },
        },
    },
}

return spec
