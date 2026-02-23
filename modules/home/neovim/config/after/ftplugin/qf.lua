-- Handy remove from quickfix
local del_qf_item = function()
  local items = vim.fn.getqflist()
  local line = vim.fn.line '.'
  table.remove(items, line)
  vim.fn.setqflist(items, 'r')
  vim.api.nvim_win_set_cursor(0, { line, 0 })
end

local del_qf_items = function()
  local items = vim.fn.getqflist()
  local line1 = vim.fn.line 'v'
  local line2 = vim.fn.line '.'
  local start = math.min(line1, line2)
  local finish = math.max(line1, line2)
  for i = finish, start, -1 do
    table.remove(items, i)
  end
  vim.fn.setqflist(items, 'r')
  vim.api.nvim_win_set_cursor(0, { start, 0 })
end

vim.keymap.set('n', 'dd', del_qf_item, { silent = true, buffer = true, desc = 'Remove entry from QF' })
vim.keymap.set('v', 'd', del_qf_items, { silent = true, buffer = true, desc = 'Remove entry from QF' })
