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
      vim.fn.writefile(vim.split(content, "\n"), inbox_path)
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


-- Refile heading
local function get_all_notes()
  local notes_dir = vim.fn.expand("~/Nextcloud/Notes")
  local notes = {}

  -- Используем vim.fn.globpath для рекурсивного поиска markdown файлов
  local files = vim.fn.globpath(notes_dir, "**/*.md", false, true)

  for _, file in ipairs(files) do
    -- Пропускаем сам Inbox.md
    if not file:match("Inbox%.md$") then
      local content = vim.fn.readfile(file)
      local title = nil

      -- Парсим frontmatter для title
      local in_yaml = false
      for _, line in ipairs(content) do
        if line:match("^---$") then
          in_yaml = not in_yaml
        elseif in_yaml and line:match("^title:") then
          title = line:match('title:%s*["\']?(.*)["\']?$')
          if title then
            title = title:gsub('^["\'](.*)["\']$', '%1')
          end
          break
        end
      end

      -- Если title не найден, используем имя файла
      if not title or title == "" then
        title = vim.fn.fnamemodify(file, ":t:r")
      end

      table.insert(notes, {
        path = file,
        title = title,
        filename = vim.fn.fnamemodify(file, ":t")
      })
    end
  end

  return notes
end

local function get_current_heading_content()
  local bufnr = vim.api.nvim_get_current_buf()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- Находим начало текущего заголовка
  local start_line = current_line
  while start_line > 1 do
    if lines[start_line - 1]:match("^#+ ") then
      break
    end
    start_line = start_line - 1
  end

  -- Если мы не на заголовке, ищем предыдущий заголовок
  if not lines[start_line - 1]:match("^#+ ") then
    for i = current_line - 1, 1, -1 do
      if lines[i - 1]:match("^#+ ") then
        start_line = i
        break
      end
    end
  end

  -- Проверяем, что нашли заголовок
  if not lines[start_line - 1]:match("^#+ ") then
    return nil
  end

  -- Находим конец раздела
  local end_line = start_line
  for i = start_line + 1, #lines do
    if lines[i - 1]:match("^#+ ") then
      end_line = i - 2 -- строка ПЕРЕД следующим заголовком
      break
    end
  end

  -- Если дошли до конца файла без нахождения другого заголовка
  if end_line == start_line then
    end_line = #lines
  end

  -- Извлекаем содержание
  local content_lines = {}
  for i = start_line - 1, end_line do
    table.insert(content_lines, lines[i])
  end

  return {
    heading = lines[start_line - 1],
    heading_text = lines[start_line - 1]:match("^#+%s+(.+)$") or "",
    content = table.concat(content_lines, "\n"),
    start_line = start_line,
    end_line = end_line + 1, -- делаем инклюзивным
    bufnr = bufnr,
    lines = lines
  }
end

local function refile_heading()
  local Snacks = require("snacks")

  -- Получаем текущий заголовок и его содержание
  local heading_data = get_current_heading_content()

  if not heading_data then
    vim.notify("❌ Не на заголовке!", vim.log.levels.ERROR)
    return
  end

  -- Получаем все заметки для выбора
  local notes = get_all_notes()

  if #notes == 0 then
    vim.notify("❌ Нет заметок для перемещения", vim.log.levels.ERROR)
    return
  end

  -- Создаем items для пикера
  local items = {}
  local longest_title = 0

  for i, note in ipairs(notes) do
    table.insert(items, {
      idx = i,
      score = i,
      text = note.title,
      path = note.path,
      filename = note.filename
    })

    longest_title = math.max(longest_title, #note.title)
  end

  -- Определяем ширину для форматирования
  local display_width = math.min(longest_title, 60)

  return Snacks.picker({
    items = items,
    format = function(item)
      local ret = {}
      -- Заголовок заметки
      local formatted_title = string.format("%-" .. display_width .. "s",
        #item.text > display_width and item.text:sub(1, display_width - 3) .. "..." or item.text)
      ret[#ret + 1] = { formatted_title, 'SnacksPickerLabel' }

      -- Имя файла
      ret[#ret + 1] = { "  (" .. item.filename .. ")", 'SnacksPickerComment' }
      return ret
    end,
    preview = function(picker, item)
      if not item then return end

      -- Показываем содержимое целевой заметки
      local bufnr = picker:get_buf('preview')
      if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        bufnr = vim.api.nvim_create_buf(false, true)
        picker:set_buf('preview', bufnr)
      end

      local content = vim.fn.readfile(item.path)
      vim.api.nvim_buf_set_option(bufnr, 'filetype', 'markdown')
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, content)

      return bufnr
    end,
    confirm = function(picker, item)
      picker:close()

      -- Подтверждение
      local choice = vim.fn.confirm(
        string.format("Переместить '%s' в заметку '%s'?",
          heading_data.heading_text, item.text),
        "&Yes\n&No", 2
      )

      if choice ~= 1 then
        vim.notify("❌ Отменено", vim.log.levels.INFO)
        return
      end

      -- 1. Добавляем в целевую заметку
      local target_path = item.path

      -- Читаем целевую заметку
      local target_content = {}
      local target_file = io.open(target_path, "r")
      if target_file then
        for line in target_file:lines() do
          table.insert(target_content, line)
        end
        target_file:close()
      end

      -- Разбиваем содержание на строки
      table.insert(target_content, "")
      local heading_lines = {}
      for line in heading_data.content:gmatch("[^\n]+") do
        table.insert(heading_lines, line)
      end
      for _, line in ipairs(heading_lines) do
        table.insert(target_content, line)
      end

      -- Записываем целевую заметку
      local target_file_out = io.open(target_path, "w")
      if target_file_out then
        for i, line in ipairs(target_content) do
          target_file_out:write(line)
          if i < #target_content then
            target_file_out:write("\n")
          end
        end
        target_file_out:close()
      else
        vim.notify("❌ Не могу открыть файл для записи: " .. target_path, vim.log.levels.ERROR)
        return
      end

      -- 2. Удаляем из исходного файла
      local source_lines = heading_data.lines
      local new_source_lines = {}

      -- Копируем все строки КРОМЕ перемещаемого блока
      for i = 1, #source_lines do
        -- Проверяем, находится ли строка в перемещаемом блоке
        local is_in_block = false
        for j = heading_data.start_line - 1, heading_data.end_line - 1 do
          if i == j + 1 then -- +1 потому что Lua 1-based, а end_line инклюзивный
            is_in_block = true
            break
          end
        end

        if not is_in_block then
          table.insert(new_source_lines, source_lines[i - 1])
        end
      end

      -- Обновляем исходный буфер
      vim.api.nvim_buf_set_lines(heading_data.bufnr, 0, -1, false, new_source_lines)

      -- Перемещаем курсор на строку перед удаленным разделом
      local new_cursor_line = math.min(heading_data.start_line - 2, #new_source_lines - 1)
      if new_cursor_line < 1 then new_cursor_line = 1 end
      vim.api.nvim_win_set_cursor(0, { new_cursor_line, 0 })

      vim.notify(string.format("✅ Перемещено в: %s", item.text), vim.log.levels.INFO)

      -- Сохраняем изменения в исходном файле
      vim.cmd("write")
    end,
    layout = { preset = "ivy" },
    prompt = "Куда переместить '" .. heading_data.heading_text .. "'?"
  })
end

-- Команда
vim.api.nvim_create_user_command('RefileHeading', refile_heading, {
  desc = 'Переместить текущий заголовок в другую заметку'
})

vim.keymap.set('n', '<leader>nr', '<cmd>RefileHeading<CR>', {
  desc = 'Refile current heading'
})

-- Archive
local function get_daily_note_path(date_str)
  -- date_str в формате "2025-01-01"
  local notes_dir = vim.fn.expand("~/Nextcloud/Notes")
  local daily_dir = notes_dir .. "/daily"

  -- Создаем директорию daily если нет
  if vim.fn.isdirectory(daily_dir) == 0 then
    vim.fn.mkdir(daily_dir, "p")
  end

  return daily_dir .. "/" .. date_str .. ".md"
end


local function archive_heading_enhanced()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local source_file = vim.api.nvim_buf_get_name(bufnr)
  local source_filename = vim.fn.fnamemodify(source_file, ":t:r")

  -- Получаем текущий заголовок и его содержание
  local heading_data = get_current_heading_content() -- используем функцию из предыдущего кода

  if not heading_data then
    vim.notify("❌ Поместите курсор на заголовок", vim.log.levels.ERROR)
    return
  end

  -- Ищем Completion строку в содержании
  local completion_date = nil
  local content_lines = {}
  for line in heading_data.content:gmatch("[^\n]+") do
    table.insert(content_lines, line)
    local completion_match = line:match("^- Completion: `([^`]+)`")
    if completion_match then
      completion_date = completion_match
    end
  end

  -- Определяем дату архивации
  local archive_date = completion_date or os.date("%Y-%m-%d")
  local archive_date_clean = archive_date:match("(%d%d%d%d%-%d%d%-%d%d)") or os.date("%Y-%m-%d")

  -- Путь к daily заметке
  local daily_path = get_daily_note_path(archive_date_clean)

  -- Подготавливаем контент для архивации
  local archived_content = {
    "",
  }

  -- Добавляем оригинальное содержание
  for _, line in ipairs(content_lines) do
    table.insert(archived_content, line)
  end

  -- Добавляем метку архивации если ее нет
  local has_archive_marker = false
  for _, line in ipairs(content_lines) do
    if line:match("^- Archived:") or line:match("^- Архивировано:") then
      has_archive_marker = true
      break
    end
  end

  if not has_archive_marker then
    table.insert(archived_content, "")
    table.insert(archived_content,
      "- Archived from: [[" .. source_filename .. "]] on `" .. os.date("%Y-%m-%d %H:%M") .. "`")
  end

  -- Читаем или создаем daily заметку
  local daily_content = {}
  if vim.fn.filereadable(daily_path) == 1 then
    daily_content = vim.fn.readfile(daily_path)

    -- Проверяем есть ли frontmatter
    local has_date_heading = false
    for _, line in ipairs(daily_content) do
      if line == "# " .. archive_date_clean then
        has_date_heading = not has_date_heading
      end
    end

    if not has_date_heading then
      local new_content = {
        "# " .. archive_date_clean,
        ""
      }
      for _, line in ipairs(daily_content) do
        table.insert(new_content, line)
      end
      daily_content = new_content
    end
  else
    daily_content = {
      "# " .. archive_date_clean,
      ""
    }
  end

  -- Добавляем архивированный контент в конец
  for _, line in ipairs(archived_content) do
    table.insert(daily_content, line)
  end

  -- Записываем daily заметку
  local file = io.open(daily_path, "w")
  if file then
    for i, line in ipairs(daily_content) do
      file:write(line)
      if i < #daily_content then
        file:write("\n")
      end
    end
    file:close()
  else
    vim.notify("❌ Не могу создать файл: " .. daily_path, vim.log.levels.ERROR)
    return
  end

  -- Удаляем из исходного файла
  local new_source_lines = {}
  local in_block = false
  local block_start = heading_data.start_line - 1
  local block_end = heading_data.end_line - 1

  for i = 1, #lines do
    if i - 1 < block_start or i - 1 > block_end then
      table.insert(new_source_lines, lines[i - 1])
    end
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_source_lines)

  -- Перемещаем курсор
  local new_cursor = math.min(block_start, #new_source_lines)
  if new_cursor < 1 then new_cursor = 1 end
  vim.api.nvim_win_set_cursor(0, { new_cursor, 0 })

  -- Сохраняем
  vim.cmd("write")

  -- Показываем результат
  local message = "📦 Архивировано в daily/" .. archive_date_clean .. ".md"
  if completion_date then
    message = message .. " (дата выполнения: " .. completion_date .. ")"
  end

  vim.notify(message, vim.log.levels.INFO)
end

-- Альтернативная команда
vim.api.nvim_create_user_command('ArchiveHeading', archive_heading_enhanced, {
  desc = 'Archive heading to daily note (enhanced)'
})

vim.keymap.set('n', '<leader>n$', '<cmd>ArchiveHeading<CR>', {
  desc = 'Archive heading to daily note (enhanced)'
})
