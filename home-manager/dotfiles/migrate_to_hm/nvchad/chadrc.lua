---@type ChadrcConfig
local M = {}

-- Path to overriding theme and highlights files
local highlights = require("custom.highlights")

M.ui = {
    theme = "decay",
    theme_toggle = { "decay", "one_light" },

    hl_override = highlights.override,
    hl_add = highlights.add,

    statusline = {
        theme = "default",
        separator_style = "default",
        overriden_modules = function(modules)
            -- modules[1] = (function()
            --     return "MODE!"
            -- end)()

            -- define the somefunction anywhwere in your custom dir, just call it well!
            -- modules[2] = somefunction()

            -- adding a module between 2 modules
            -- Use the table.insert functin to insert at specific index
            -- This will insert a new module at index 2 and previous index 2 will become 3 now

            table.insert(
                modules,
                4,
                (function()
                    return " " .. require("nvim-navic").get_location()
                end)()
            )

            table.insert(
                modules,
                10,
                (function()
                    return "  [" .. vim.fn["codeium#GetStatusString"]() .. "] "
                end)()
            )
        end,
    },
    telescope = {
        style = "bordered",
    },

    nvdash = {
        buttons = {
            { "  Find File", "Spc f f", "Find files" },
            { "󰈚  Recent Files", "Spc f r", "Recent files " },
            { "󰈭  Find Word", "Spc f w", "Grep in files" },
            { "  Projects", "Spc f p", "Bookmarsk" },
            { "  Bookmarks", "Spc s m", "Bookmarsk" },
            { "  Themes", "Spc u t", "Telescope themes" },
            { "  Mappings", "Spc u c", "NvCheatsheet" },
        },
    },

    extended_integrations = { "navic", "dap", "todo", "lspsaga", "trouble" },
}

M.plugins = "custom.plugins"

-- check core.mappings for table structure
M.mappings = require("custom.mappings")

return M
