vim.api.nvim_create_user_command('SudoWrite', function()
  local file = vim.fn.expand '%:p'
  if file == '' or vim.bo.buftype ~= '' then
    vim.notify('SudoWrite: нет имени файла', vim.log.levels.ERROR)
    return
  end

  vim.cmd('silent noautocmd write !sudo tee ' .. vim.fn.shellescape(file) .. ' >/dev/null')
  if vim.v.shell_error == 0 then
    vim.cmd 'noautocmd edit!'
    vim.notify('SudoWrite: сохранено ' .. file)
  else
    vim.notify('SudoWrite: не удалось записать', vim.log.levels.ERROR)
  end
end, { desc = 'Записать файл через sudo' })
