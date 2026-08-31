-- 🤖 Neovim + OpenCode: конфигурация по README + минимальный фикс диффов.
-- https://github.com/nickjvandyke/opencode.nvim
--
-- TUI (`<C-.>`) запускает `opencode --port` (инстанс на случайном свободном
-- порту в каталоге проекта), плагин сам его находит (pgrep/lsof + cwd).
--
-- Единственное отличие от ванили: `untrim_diff` — opencode отдаёт
-- `metadata.diff` через свою trimDiff (срезает общий min-отступ контентных
-- строк), из-за чего штатный `:diffpatch` не накладывает патч и показывает две
-- одинаковые панели. Мы восстанавливаем отступ и вызываем оригинальный
-- обработчик — discovery/подключение не трогаем.

--- trimDiff срезает min-отступ у всех контентных строк (`+`/`-`/` `, кроме
--- `---`/`+++`); min считается по непустым строкам. Восстанавливаем отступ:
--- берём первую контекстную/удалённую строку первого хунка, сверяем её отступ
--- с файлом (delta), и дописываем delta пробелов всем контентным строкам.
local function untrim_diff(diff, filepath)
  local fp = vim.fn.fnamemodify(filepath, ':p')
  if vim.fn.filereadable(fp) ~= 1 and vim.env.HOME and vim.env.HOME ~= '' then
    fp = vim.fs.normalize(vim.fs.joinpath(vim.env.HOME, filepath))
  end
  if vim.fn.filereadable(fp) ~= 1 then
    return diff
  end

  local fl = vim.fn.readfile(fp)
  local lines = vim.split(diff, '\n')

  local delta, i = nil, 1
  while i <= #lines and not delta do
    local s = lines[i]:match('^@@ %-(%d+)')
    if s then
      local old_idx = tonumber(s)
      i = i + 1
      while i <= #lines and not delta and not lines[i]:match('^@@') do
        local p = lines[i]:sub(1, 1)
        if p == ' ' or p == '-' then
          local l = fl[old_idx]
          local d_indent = (lines[i]:sub(2):match('^(%s*)') or ''):len()
          local f_indent = l and (l:match('^(%s*)') or ''):len() or 0
          if f_indent > d_indent then
            delta = f_indent - d_indent
          end
          old_idx = old_idx + 1
        elseif p == '+' or lines[i] == '' then
          -- добавления/пустые строки не двигают индекс файла
        else
          old_idx = old_idx + 1
        end
        i = i + 1
      end
    else
      i = i + 1
    end
  end

  if not delta then
    return diff
  end

  local pad = string.rep(' ', delta)
  for j, ln in ipairs(lines) do
    local p = ln:sub(1, 1)
    if (p == ' ' or p == '-' or p == '+') and not ln:match('^%-%-%-') and not ln:match('^%+%+%+') then
      local content = ln:sub(2)
      if content:find('%S') then
        lines[j] = p .. pad .. content
      end
    end
  end
  return table.concat(lines, '\n')
end

local opencode_cmd = 'opencode --port'
---@type snacks.terminal.Opts
local snacks_terminal_opts = {
  win = {
    position = 'right',
    enter = false,
  },
}

---@type LazyPluginSpec
return {
  'nickjvandyke/opencode.nvim',
  version = '*', -- последний стабильный релиз
  lazy = false, -- постоянный коннект: события, autoread, permission-диффы

  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      server = {
        -- Если сервер проекта не найден — поднимаем его в терминале справа.
        start = function()
          require('snacks.terminal').open(opencode_cmd, snacks_terminal_opts)
        end,
      },
    }

    -- FIX (минимальный): восстановить срезанный trimDiff отступ перед штатным
    -- `diffpatch`, чтобы панели не были «идентичными».
    local edits = require('opencode.events.permissions.edits')
    local orig_diff = edits.diff
    edits.diff = function(event)
      if event.type == 'permission.asked' and event.properties.permission == 'edit' then
        local meta = event.properties.metadata or {}
        if meta.diff ~= '' and meta.filepath then
          meta.diff = untrim_diff(meta.diff, meta.filepath)
        end
      end
      return orig_diff(event)
    end

    -- Recommended/example keymaps (README)
    vim.keymap.set({ 'n', 'x' }, '<C-a>', function()
      require('opencode').ask '@this: '
    end, { desc = 'Ask OpenCode…' })
    vim.keymap.set({ 'n', 'x' }, '<C-x>', function()
      require('opencode').select()
    end, { desc = 'Select OpenCode…' })
    vim.keymap.set({ 'n', 'x' }, 'go', function()
      return require('opencode').operator '@this '
    end, { desc = 'Append range to OpenCode', expr = true })
    vim.keymap.set({ 'n' }, 'goo', function()
      return require('opencode').operator('@this ') .. '_'
    end, { desc = 'Append line to OpenCode', expr = true })
    vim.keymap.set({ 'n' }, '<S-C-u>', function()
      require('opencode').command 'session.half.page.up'
    end, { desc = 'Scroll OpenCode up' })
    vim.keymap.set({ 'n' }, '<S-C-d>', function()
      require('opencode').command 'session.half.page.down'
    end, { desc = 'Scroll OpenCode down' })

    -- Toggle TUI (README, snacks.terminal).
    vim.keymap.set({ 'n', 't' }, '<C-.>', function()
      require('snacks.terminal').toggle(opencode_cmd, snacks_terminal_opts)
    end, { desc = 'Toggle OpenCode' })

    -- Показать терминал при отправке промпта (README).
    vim.api.nvim_create_autocmd('User', {
      pattern = { 'OpencodeEvent:tui.command.execute' },
      callback = function(args)
        ---@type opencode.server.Event
        local event = args.data.event
        if event.properties.command == 'prompt.submit' then
          local win = require('snacks.terminal').get(opencode_cmd, { create = false })
          if win then
            win:show()
          end
        end
      end,
    })
  end,
}
