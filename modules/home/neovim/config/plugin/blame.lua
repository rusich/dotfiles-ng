local ns = vim.api.nvim_create_namespace('my_line_blame')
local timer = assert(vim.uv.new_timer())
local augroup = vim.api.nvim_create_augroup('my_line_blame', { clear = true })
local enabled = true
local id

local function clear()
  if id then
    pcall(vim.api.nvim_buf_del_extmark, 0, ns, id)
    id = nil
  end
end

local function update()
  if not enabled then
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].buftype ~= '' then
    clear()
    return
  end

  local file = vim.fn.expand '%:p'
  local line = vim.api.nvim_win_get_cursor(0)[1]
  if file == '' or vim.fn.filereadable(file) ~= 1 then
    clear()
    return
  end

  local out = vim.fn.system { 'git', 'blame', '-L', line .. ',' .. line, '--date=short', '--line-porcelain', '--', file }
  if vim.v.shell_error ~= 0 or out == '' then
    clear()
    return
  end

  local sha = out:match '^(%x+)'
  local author = (out:match '\nauthor (.+)\n' or ''):gsub('%s+$', '')
  local ts = out:match '\nauthor%-time (%d+)\n'
  local summary = (out:match '\nsummary (.+)\n' or ''):gsub('%s+$', '')
  if author == '' then
    clear()
    return
  end

  local date = ts and os.date('%Y-%m-%d', tonumber(ts)) or ''

  clear()
  id = vim.api.nvim_buf_set_extmark(buf, ns, line - 1, 0, {
    virt_text = {
      { (' │ %s %s, %s · %s'):format(sha:sub(1, 7), author, date, summary), 'LineBlame' },
    },
    virt_text_pos = 'eol',
    right_gravity = false,
    hl_mode = 'combine',
  })
end

local function schedule()
  timer:start(250, 0, function()
    vim.schedule(update)
  end)
end

vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'BufEnter' }, {
  group = augroup,
  callback = schedule,
})

vim.api.nvim_create_autocmd({ 'BufLeave', 'VimLeave' }, {
  group = augroup,
  callback = clear,
})

vim.api.nvim_set_hl(0, 'LineBlame', { link = 'Comment' })

vim.keymap.set('n', '<leader>uB', function()
  enabled = not enabled
  if not enabled then
    clear()
  else
    update()
  end
  vim.notify('Line blame: ' .. (enabled and 'on' or 'off'))
end, { desc = 'Toggle line blame' })
