---@type NvPluginSpec
local spec = {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        -- project management
        {
            "ahmedkhalf/project.nvim",
            opts = {
                manual_mode = false,
            },
            event = "VeryLazy",
            config = function(_, opts)
                require("project_nvim").setup(opts)
                -- require("lazyvim.util").on_load("telescope.nvim", function()
                require("telescope").load_extension("projects")
                -- end)
            end,
            keys = {
                { "<leader>fp", "<Cmd>Telescope projects<CR>", desc = "Projects" },
            },
        },
    },
    opts = {
        defaults = {
            mappings = {
                i = {
                    ["<C-n>"] = require("telescope.actions").cycle_history_next,
                    ["<C-p>"] = require("telescope.actions").cycle_history_prev,
                    ["<C-j>"] = require("telescope.actions").move_selection_next,
                    ["<C-k>"] = require("telescope.actions").move_selection_previous,
                },
            },
        },
    },
}

return spec
