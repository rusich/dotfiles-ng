local opt = vim.opt

opt.confirm = false
-- opt.spell = false
opt.spelllang = "ru,en"
opt.relativenumber = true

-- folds
vim.o.foldcolumn = "auto" -- "auto" or "0"

-- Global vars
-- vim.g.diffview_opened = false

-- lanmap
local function escape(str)
  local escape_chars = [[;,."|\]]
  return vim.fn.escape(str, escape_chars)
end

local en = [[qwertyuiop[]asdfghjkl;zxcvbnm,.]]
local ru = [[йцукенгшщзхъфывапролджячсмитьбю]]
local en_shift = [[QWERTYUIOP{}ASDFGHJKL:ZXCVBNM<>]]
local ru_shift = [[ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЯЧСМИТЬБЮ]]
vim.opt.langmap = vim.fn.join({ escape(ru_shift) .. ";" .. escape(en_shift), escape(ru) .. ";" .. escape(en) }, ",")

--codeium
-- vim.g.codeium_no_map_tab = 1
-- vim.g.codeium_disable_bindings = 1
