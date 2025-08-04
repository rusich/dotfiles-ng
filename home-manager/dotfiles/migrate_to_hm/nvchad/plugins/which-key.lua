---@type NvPluginSpec
local spec = {
    "folke/which-key.nvim",
    lazy = false,
    dependencies = { "Wansmer/langmapper.nvim" },
    config = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 300

        local lmu = require("langmapper.utils")
        local view = require("which-key.view")
        local execute = view.execute

        -- wrap `execute()` and translate sequence back
        view.execute = function(prefix_i, mode, buf)
            -- Translate back to English characters
            prefix_i = lmu.translate_keycode(prefix_i, "default", "ru")
            execute(prefix_i, mode, buf)
        end

        -- If you want to see translated operators, text objects and motions in
        -- which-key prompt
        -- local presets = require('which-key.plugins.presets')
        -- presets.operators = lmu.trans_dict(presets.operators)
        -- presets.objects = lmu.trans_dict(presets.objects)
        -- presets.motions = lmu.trans_dict(presets.motions)
        -- etc
        local wk = require("which-key")
        wk.setup({
            icons = {
                breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
                separator = "➜", -- symbol used between a key and it's label
                group = "", -- symbol prepended to a group
            },
            triggers_blacklist = {
                o = lmu.trans_list({ ";", ".", '"', "'", "j", "k" }),
                i = lmu.trans_list({ ";", ".", '"', "'", "j", "k", "<leader>" }),
                c = lmu.trans_list({ ";", ".", '"', "'", "j", "k", "<leader>" }),
                n = lmu.trans_list({ ";", ".", '"', "'", "j", "k" }),
                v = lmu.trans_list({ ";", ".", '"', "'", "j", "k" }),
            },
        })

        wk.register({
            ["<leader>а"] = "which_key_ignore",
            ["<leader>б"] = "which_key_ignore",
            ["<leader>в"] = "which_key_ignore",
            ["<leader>г"] = "which_key_ignore",
            ["<leader>д"] = "which_key_ignore",
            ["<leader>е"] = "which_key_ignore",
            ["<leader>ё"] = "which_key_ignore",
            ["<leader>ж"] = "which_key_ignore",
            ["<leader>з"] = "which_key_ignore",
            ["<leader>и"] = "which_key_ignore",
            ["<leader>й"] = "which_key_ignore",
            ["<leader>к"] = "which_key_ignore",
            ["<leader>л"] = "which_key_ignore",
            ["<leader>м"] = "which_key_ignore",
            ["<leader>н"] = "which_key_ignore",
            ["<leader>о"] = "which_key_ignore",
            ["<leader>п"] = "which_key_ignore",
            ["<leader>р"] = "which_key_ignore",
            ["<leader>с"] = "which_key_ignore",
            ["<leader>т"] = "which_key_ignore",
            ["<leader>у"] = "which_key_ignore",
            ["<leader>ф"] = "which_key_ignore",
            ["<leader>х"] = "which_key_ignore",
            ["<leader>ц"] = "which_key_ignore",
            ["<leader>ч"] = "which_key_ignore",
            ["<leader>ш"] = "which_key_ignore",
            ["<leader>щ"] = "which_key_ignore",
            ["<leader>ъ"] = "which_key_ignore",
            ["<leader>ы"] = "which_key_ignore",
            ["<leader>ь"] = "which_key_ignore",
            ["<leader>э"] = "which_key_ignore",
            ["<leader>ю"] = "which_key_ignore",
            ["<leader>я"] = "which_key_ignore",

            ["<leader>А"] = "which_key_ignore",
            ["<leader>Б"] = "which_key_ignore",
            ["<leader>В"] = "which_key_ignore",
            ["<leader>Г"] = "which_key_ignore",
            ["<leader>Д"] = "which_key_ignore",
            ["<leader>Е"] = "which_key_ignore",
            ["<leader>Ё"] = "which_key_ignore",
            ["<leader>Ж"] = "which_key_ignore",
            ["<leader>З"] = "which_key_ignore",
            ["<leader>И"] = "which_key_ignore",
            ["<leader>Й"] = "which_key_ignore",
            ["<leader>К"] = "which_key_ignore",
            ["<leader>Л"] = "which_key_ignore",
            ["<leader>М"] = "which_key_ignore",
            ["<leader>Н"] = "which_key_ignore",
            ["<leader>О"] = "which_key_ignore",
            ["<leader>П"] = "which_key_ignore",
            ["<leader>Р"] = "which_key_ignore",
            ["<leader>С"] = "which_key_ignore",
            ["<leader>Т"] = "which_key_ignore",
            ["<leader>У"] = "which_key_ignore",
            ["<leader>Ф"] = "which_key_ignore",
            ["<leader>Х"] = "which_key_ignore",
            ["<leader>Ц"] = "which_key_ignore",
            ["<leader>Ч"] = "which_key_ignore",
            ["<leader>Ш"] = "which_key_ignore",
            ["<leader>Щ"] = "which_key_ignore",
            ["<leader>Ъ"] = "which_key_ignore",
            ["<leader>Ы"] = "which_key_ignore",
            ["<leader>Ь"] = "which_key_ignore",
            ["<leader>Э"] = "which_key_ignore",
            ["<leader>Ю"] = "which_key_ignore",
            ["<leader>Я"] = "which_key_ignore",

            ["<leader>fa"] = { name = "AstroNvim" },
            ["<leader>fl"] = { name = "LazyVim" },
            ["<leader>t"] = { name = "󰙨 Testing " },
            ["<leader><tab>"] = { name = "󰓩 Tabs " },
            ["<leader>a"] = { name = "󰭻 AI " },
            ["<leader>b"] = { name = " Buffer " },
            ["<leader>d"] = { name = " Debug " },
            ["<leader>c"] = { name = "󱘗 Code " },
            ["<leader>f"] = { name = "󰈞 Find/File " },
            ["<leader>g"] = { name = " Git " },
            ["<leader>q"] = { name = "󰗼 Quit/Session " },
            ["<leader>s"] = { name = " Search " },
            ["<leader>u"] = { name = "󰡮 UI " },
            ["<leader>w"] = { name = " Windows " },
            ["<leader>x"] = { name = " Diagnostics/Quickfix " },
        })
    end,
}

return spec
