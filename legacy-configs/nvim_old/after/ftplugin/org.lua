local function org_toggle_concealcursor()
  local conceal = vim.wo.concealcursor
  if conceal == 'niv' then
    vim.wo.concealcursor = ''
  elseif conceal == '' then
    vim.wo.concealcursor = 'niv'
  end
end

vim.keymap.set('n', '<leader>oC', org_toggle_concealcursor, { desc = 'Toggle org concealcursor' })
vim.keymap.set('n', '<leader>ce', '<cmd>MdEval<cr>', { desc = 'Evaluate code block' })

vim.wo.wrap = false
vim.wo.conceallevel = 2
vim.wo.concealcursor = 'niv'
vim.wo.breakindent = true
vim.bo.textwidth = 80
-- vim.wo.foldcolumn = 1
