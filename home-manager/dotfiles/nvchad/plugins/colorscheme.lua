local is_vim = vim.fn.has("nvim") ~= 1

---@type NvPluginSpec
local spec = {
    -- Configure LazyVim to load gruvbox
    {
        "catppuccin/nvim",
        lazy = false,
        name = "catppuccin",
        opts = {
            flavour = "mocha", -- latte, frappe, macchiato, mocha
            background = {
                -- :h background
                light = "latte",
                dark = "mocha",
            },
            dim_inactive = {
                enabled = true,
                shade = "dark",
                percentage = 0.5,
            },
            color_overrides = {},
            highlight_overrides = {},
            integrations = {
                aerial = true,
                alpha = true,
                cmp = true,
                dashboard = true,
                dap = {
                    enabled = true,
                    enable_ui = true, -- enable nvim-dap-ui
                },
                flash = true,
                notify = true,
                fidget = true,
                gitsigns = true,
                markdown = true,
                mason = true,
                mini = {
                    enabled = true,
                    indentscope_color = "", -- catppuccin color (eg. `lavender`) Default: text
                },
                neogit = true,
                nvimtree = true,
                neotree = true,
                ufo = true,
                rainbow_delimiters = true,
                semantic_tokens = not is_vim,
                telescope = { enabled = true },
                treesitter = not is_vim,
                barbecue = {
                    dim_dirname = true,
                    bold_basename = true,
                    dim_context = false,
                    alt_background = false,
                },
                illuminate = {
                    enabled = true,
                    lsp = false,
                },
                indent_blankline = {
                    enabled = true,
                    scope_color = "",
                    colored_indent_levels = false,
                },
                native_lsp = {
                    enabled = true,
                    virtual_text = {
                        errors = { "italic" },
                        hints = { "italic" },
                        warnings = { "italic" },
                        information = { "italic" },
                    },
                    underlines = {
                        errors = { "underline" },
                        hints = { "underline" },
                        warnings = { "underline" },
                        information = { "underline" },
                    },
                    inlay_hints = {
                        background = true,
                    },
                },
                navic = {
                    enabled = false,
                    custom_bg = "NONE",
                },
                dropbar = {
                    enabled = true,
                    color_mode = false,
                },
                neotest = true,
            },
        },
    },
    {
        "EdenEast/nightfox.nvim",
        opts = {
            options = {
                compile_path = vim.fn.stdpath("cache") .. "/nightfox",
                compile_file_suffix = "_compiled", -- Compiled file suffix
                transparent = false, -- Disable setting background
                terminal_colors = true, -- Set terminal colors (vim.g.terminal_color_*) used in `:terminal`
                dim_inactive = true, -- Non focused panes set to alternative background
                module_default = true, -- Default enable value for modules
                colorblind = {
                    enable = false, -- Enable colorblind support
                    simulate_only = false, -- Only show simulated colorblind colors and not diff shifted
                    severity = {
                        protan = 0, -- Severity [0,1] for protan (red)
                        deutan = 0, -- Severity [0,1] for deutan (green)
                        tritan = 0, -- Severity [0,1] for tritan (blue)
                    },
                },
                styles = {
                    -- Style to be applied to different syntax groups
                    comments = "italic", -- Value is any valid attr-list value `:help attr-list`
                    conditionals = "NONE",
                    constants = "NONE",
                    functions = "NONE",
                    keywords = "NONE",
                    numbers = "NONE",
                    operators = "NONE",
                    strings = "NONE",
                    types = "NONE",
                    variables = "NONE",
                },
                inverse = {
                    -- Inverse highlight for different types
                    match_paren = false,
                    visual = false,
                    search = false,
                },
                modules = { -- List of various plugins and additional options
                    -- ...
                },
            },
            palettes = {},
            specs = {},
            groups = {},
        },
    },
}

return spec
