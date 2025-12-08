local function create_inbox_capture()
  local bufnr = vim.api.nvim_create_buf(false, true)
  local height = math.floor(vim.o.lines * 0.2)

  -- Создаем сплит
  vim.cmd('botright ' .. height .. 'split')
  local win_id = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win_id, bufnr)

  -- Настройки буфера
  vim.bo[bufnr].filetype = 'markdown'
  vim.bo[bufnr].buftype = 'acwrite'
  vim.bo[bufnr].bufhidden = 'wipe'

  -- Настройки окна через vim.wo
  vim.wo[win_id].number = false
  vim.wo[win_id].relativenumber = false
  vim.wo[win_id].wrap = true
  vim.wo[win_id].signcolumn = 'no'
  vim.wo[win_id].cursorline = true
  vim.wo[win_id].winhl = 'Normal:Normal,FloatBorder:FloatBorder'

  -- Шаблон с подсказками сверху
  local timestamp = os.date("%Y-%m-%d %H:%M")
  local template = {
    "<!-- Введите заметку ниже -->",
    "<!-- Ctrl+S сохранить, Ctrl+C отменить -->",
    "",
    "# TODO:  ",
    "- Captured: `" .. timestamp .. "`",
  }

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, template)

  -- Устанавливаем курсор на строку "# TODO: " (строка 4)
  vim.api.nvim_win_set_cursor(win_id, { 4, 9 })

  local function save_and_cleanup()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    -- Удаляем строки комментариев (<!-- ... -->)
    local cleaned_lines = {}
    for _, line in ipairs(lines) do
      if not line:match("^<!%-%-") then
        table.insert(cleaned_lines, line)
      end
    end

    local content = table.concat(cleaned_lines, "\n")

    local inbox_path = vim.fn.expand("~/Nextcloud/Notes/Inbox.md")

    -- Добавляем в конец файла
    if vim.fn.filereadable(inbox_path) == 1 then
      local current_lines = vim.fn.readfile(inbox_path)
      local new_lines = vim.split(content, "\n")
      for _, line in ipairs(new_lines) do
        table.insert(current_lines, line)
      end
      vim.fn.writefile(current_lines, inbox_path)
    else
      vim.fn.writefile(vim.split(entry, "\n"), inbox_path)
    end

    vim.notify("✅ Добавлено в Inbox", vim.log.levels.INFO)

    -- Cleanup
    vim.api.nvim_win_close(win_id, true)
    pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
  end

  local function cancel_and_cleanup()
    vim.api.nvim_win_close(win_id, true)
    pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
  end

  -- Маппинги
  local map_opts = { buffer = bufnr, silent = true }
  vim.keymap.set({ 'n', 'i' }, '<C-s>', save_and_cleanup, map_opts)
  vim.keymap.set({ 'n', 'i' }, '<C-c>', cancel_and_cleanup, map_opts)
  -- vim.keymap.set('n', '<Esc>', cancel_and_cleanup, map_opts)

  -- Автокоманда для cleanup
  vim.api.nvim_create_autocmd('BufWipeout', {
    buffer = bufnr,
    once = true,
    callback = function()
      if vim.api.nvim_win_is_valid(win_id) then
        vim.api.nvim_win_close(win_id, true)
      end
    end
  })

  -- Переходим в insert mode сразу
  vim.cmd('startinsert')
end

-- Команда
vim.api.nvim_create_user_command('InboxCapture', create_inbox_capture, {
  desc = 'Capture to Inbox'
})

vim.keymap.set('n', '<leader>nc', '<cmd>InboxCapture<CR>', {
  desc = 'Capture to Inbox'
})


--- Review Captures
local function review_captures()
  local Snacks = require("snacks")
  local inbox_path = vim.fn.expand("~/Nextcloud/Notes/Inbox.md")

  -- Проверяем существование файла
  if vim.fn.filereadable(inbox_path) ~= 1 then
    vim.notify("❌ Файл Inbox.md не найден", vim.log.levels.ERROR)
    return
  end

  -- Читаем файл
  local lines = vim.fn.readfile(inbox_path)
  local headers = {}

  -- Ищем все заголовки
  for i, line in ipairs(lines) do
    local title = line:match("^#+ %s*(.+)$")
    if title then
      -- Ищем timestamp
      local timestamp = ""
      for j = i + 1, math.min(i + 5, #lines) do
        local ts = lines[j]:match("^- Captured: `([^`]+)`")
        if ts then
          timestamp = ts
          break
        end
      end

      table.insert(headers, {
        line = i, -- 1-based
        text = title,
        timestamp = timestamp,
        full_line = line
      })
    end
  end

  if #headers == 0 then
    vim.notify("📭 В Inbox.md нет заголовков TODO", vim.log.levels.INFO)
    return
  end

  -- Создаем элементы для пикера
  local items = {}
  local longest_text = 0

  for i, h in ipairs(headers) do
    table.insert(items, {
      idx = i,
      score = i,
      text = h.text,
      timestamp = h.timestamp,
      line = h.line,
      file = inbox_path,
      pos = { h.line, 0 },
    })

    longest_text = math.max(longest_text, #h.text)
  end

  return Snacks.picker({
    items = items,
    format = function(item)
      local ret = {}
      -- Исправляем форматирование: %-15s значит "выровнять по левому краю, ширина 15 символов"
      -- Но если longest_text слишком большой, лучше ограничить
      local display_width = math.min(longest_text, 91)

      local formatted_text = string.format("%-" .. display_width .. "s",
        #item.text > display_width and item.text:sub(1, display_width - 3) .. "..." or item.text)
      ret[#ret + 1] = { formatted_text, 'SnacksPickerLabel' }

      -- Вторая часть: timestamp если есть
      if item.timestamp and item.timestamp ~= "" then
        ret[#ret + 1] = { "  [" .. item.timestamp .. "]", 'SnacksPickerComment' }
      end

      return ret
    end,
    preview = "file",
    confirm = function(picker, item)
      picker:close()

      -- Открываем файл в основном окне
      vim.cmd("edit " .. vim.fn.fnameescape(item.file))

      -- Устанавливаем курсор на выбранную строку
      vim.api.nvim_win_set_cursor(0, { item.line, 0 })
      vim.cmd("normal! zz")

      vim.notify("📝 Перешли к: " .. item.text, vim.log.levels.INFO)
    end,
    prompt = "Inbox: "
  })
end

-- Команда
vim.api.nvim_create_user_command('ReviewInbox', review_captures, {
  desc = 'Просмотреть все captures в Inbox.md'
})

vim.keymap.set('n', '<leader>ni', '<cmd>ReviewInbox<CR>', {
  desc = 'Find captures in Inbox'
})
