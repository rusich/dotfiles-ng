-- To find any highlight groups: "<cmd> Telescope highlights"
-- Each highlight group can take a table with variables fg, bg, bold, italic, etc
-- base30 variable names can also be used as colors

local M = {}

---@type Base46HLGroupsList
M.override = {
    Comment = {
        italic = true,
    },

    LspReferenceText = { link = "Visual" },
    LspReferenceRead = { link = "Visual" },
    LspReferenceWrite = { link = "Visual" },
    TreesitterContextBottom = { link = "Underlined" },
    TreesitterContextLineNumber = { link = "NormalFloat" },
    FoldColumn = { link = "Comment" },
}

---@type HLTable
M.add = {
    NvimTreeOpenedFolderName = { fg = "green", bold = true },
}

-- linking groups
vim.cmd("highlight! link TreesitterContextBottom Underlined")
vim.cmd("highlight! link TreesitterContextLineNumber NormalFloat")
-- vim.cmd("highlight! link TreesitterContextLineNumber NormalFloat")
-- vim.cmd("highlight! link LspReferenceText Visual")
-- vim.cmd("highlight! link LspReferenceRead Visual")
-- vim.cmd("highlight! link LspReferenceWrite Visual")
return M
