-- Lua script for Neovim that handles keyboard layout switching
-- when entering and leaving insert mode. It automatically saves and
-- restores the layout when entering and leaving insert mode.

function _G.get_kb_layout()
  return vim.fn.system { vim.fn.expand '$HOME/.config/nvim/tools/get_kb_layout.sh' }
end

vim.g.last_input_kb_layout = get_kb_layout()

local layout_toggle_tool = vim.fn.expand '$HOME/.dotfiles/legacy-configs/hypr/scripts/toggle_keyboard_layout'

-- Save used input keyboard layout when leaving insert mode
vim.api.nvim_create_autocmd('InsertLeave', {
  group = vim.api.nvim_create_augroup('save-input-layout', { clear = true }),
  callback = function()
    local cur_kb_layout = get_kb_layout()
    if cur_kb_layout ~= vim.g.last_input_kb_layout then
      vim.g.last_input_kb_layout = cur_kb_layout
    end

    if vim.g.last_input_kb_layout ~= 'en' then
      vim.fn.system { layout_toggle_tool, '--toggle' }
    end
  end,
})

-- Restore previously used input keyboard layout when entering insert mode
vim.api.nvim_create_autocmd('InsertEnter', {
  group = vim.api.nvim_create_augroup('restore-input-layout', { clear = true }),
  callback = function()
    local cur_kb_layout = get_kb_layout()
    if cur_kb_layout ~= vim.g.last_input_kb_layout then
      vim.fn.system { layout_toggle_tool, '--toggle' }
    end
  end,
})

-- Setting langmap for cyrillic symbols in normal mode
local function escape(str)
  local escape_chars = [[;,."|\]]
  return vim.fn.escape(str, escape_chars)
end
local en = [[qwertyuiop[]asdfghjkl;zxcvbnm,.]]
local ru = [[йцукенгшщзхъфывапролджячсмитьбю]]
local en_shift = [[QWERTYUIOP{}ASDFGHJKL:ZXCVBNM<>]]
local ru_shift = [[ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЯЧСМИТЬБЮ]]
vim.opt.langmap = vim.fn.join({ escape(ru_shift) .. ';' .. escape(en_shift), escape(ru) .. ';' .. escape(en) }, ',')
