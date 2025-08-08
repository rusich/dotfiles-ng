---@type NvPluginSpec
local spec = {
    "Exafunction/codeium.vim",
    lazy = false,
    event = "BufEnter",
    config = function()
        vim.g.codeium_no_map_tab = 1
        vim.keymap.set("i", "<C-\\>", function()
            return vim.fn["codeium#Complete"]()
        end, { expr = true, silent = true })
        vim.keymap.set("i", "<c-x>", function()
            return vim.fn["codeium#Clear"]()
        end, { expr = true, silent = true })
    end,
}

return spec
