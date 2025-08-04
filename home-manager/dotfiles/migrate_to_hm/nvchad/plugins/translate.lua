---@type NvPluginSpec
local spec = {
    "uga-rosa/translate.nvim",
    keys = {
        { "<C-t>", "<cmd>Translate RU<cr>", desc = "Translate selection", mode = { "v" } },
    },
    opts = {
        default = {
            output = "floating",
            command = "translate_shell", --  "google"
        },
        silent = true,
        preset = {
            output = {
                split = {
                    append = false,
                    position = "top",
                    min_size = 0.2,
                    max_size = 0.2,
                },
            },
        },
    },
    cmd = {
        "Translate",
    },
}

return spec
