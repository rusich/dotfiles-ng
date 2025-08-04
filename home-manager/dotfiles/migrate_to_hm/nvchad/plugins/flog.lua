---@type NvPluginSpec
local spec = {
    "rbong/vim-flog",
    lazy = true,
    cmd = { "Flog", "Flogsplit", "Floggit" },
    dependencies = {
        "tpope/vim-fugitive",
    },
    keys = {
        { "<leader>gl", "<cmd>Flogsplit<cr>", desc = "Log" },
    },
}

return spec
