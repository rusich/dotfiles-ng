-- ~/.config/nvim/plugin/notes.lua
-- Единый модуль для работы с заметками

local M = {}

-- Конфигурация
local config = {
  notes_dir = "~/Nextcloud/Notes",
  inbox_file = "Inbox.md",
  daily_dir = "daily",
}

-- Утилиты --------------------------------------------------------------------
local function expand_path(path)
  return vim.fn.expand(path)
end

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO)
end

local function read_file(path)
  if vim.fn.filereadable(path) == 1 then
    return vim.fn.readfile(path)
  end
  return {}
end

local function write_file(path, lines)
  vim.fn.writefile(lines, path)
end

local function file_exists(path)
  return vim.fn.filereadable(path) == 1
end

local function get_current_date(format)
  return os.date(format or "%Y-%m-%d")
end

local function get_current_datetime()
  return os.date("%Y-%m-%d %H:%M")
end

-- Получить путь до Inbox
local function get_inbox_path()
  return expand_path(config.notes_dir .. "/" .. config.inbox_file)
end
--
-- Получить путь до daily заметки (исправленная версия)
local function get_daily_note_path(date_str)
  local daily_dir = expand_path(config.notes_dir .. "/" .. config.daily_dir)

  if vim.fn.isdirectory(daily_dir) == 0 then
    vim.fn.mkdir(daily_dir, "p")
  end

  return daily_dir .. "/" .. date_str .. ".md"
end

-- Получить все заметки (кроме Inbox)
local function get_all_notes()
  local notes_dir = expand_path(config.notes_dir)
  local notes = {}

  local files = vim.fn.globpath(notes_dir, "**/*.md", false, true)

  for _, file in ipairs(files) do
    if not file:match(config.inbox_file:gsub("%.", "%%.") .. "$") then
      local content = read_file(file)
      local title = nil
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

-- Получить данные текущего заголовка (исправленная версия с правильными индексами)
local function get_current_heading_data()
  local bufnr = vim.api.nvim_get_current_buf()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]        -- 1-based
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false) -- Lua table, 1-based

  -- Ищем ближайший заголовок ВЫШЕ (включая текущую строку)
  local start_line = current_line
  local found_header = false

  -- Проходим от текущей строки вверх
  for i = current_line, 1, -1 do
    if lines[i] and lines[i]:match("^#+ ") then
      start_line = i
      found_header = true
      break
    end
  end

  if not found_header then
    return nil
  end

  -- Определяем уровень заголовка
  local header_line = lines[start_line]
  local header_level = header_line:match("^(#+)")
  local header_text = header_line:match("^#+%s+(.+)$") or ""

  -- Ищем конец раздела (следующий заголовок с таким же или меньшим уровнем)
  local end_line = #lines

  for i = start_line + 1, #lines do
    local match = lines[i]:match("^(#+)%s+")
    if match and #match <= #header_level then
      end_line = i - 1 -- строка перед следующим заголовком
      break
    end
  end

  -- Собираем содержание
  local content_lines = {}
  for i = start_line, end_line do
    table.insert(content_lines, lines[i])
  end

  -- start_line и end_line здесь 1-based индексы для строк в файле
  return {
    heading = header_line,
    heading_text = header_text,
    content = table.concat(content_lines, "\n"),
    content_lines = content_lines,
    start_line = start_line, -- 1-based для файла
    end_line = end_line,     -- 1-based для файла
    bufnr = bufnr,
    lines = lines
  }
end

-- Удалить блок из буфера (исправленная версия)
local function remove_block_from_buffer(heading_data)
  local new_lines = {}
  local block_start = heading_data.start_line -- 1-based
  local block_end = heading_data.end_line     -- 1-based

  -- Проходим по всем строкам файла (1-based)
  for i = 1, #heading_data.lines do
    -- Пропускаем строки в диапазоне [block_start, block_end]
    if i < block_start or i > block_end then
      table.insert(new_lines, heading_data.lines[i])
    end
  end

  vim.api.nvim_buf_set_lines(heading_data.bufnr, 0, -1, false, new_lines)

  -- Устанавливаем курсор на строку перед удаленным блоком
  local new_cursor = math.min(block_start - 1, #new_lines)
  if new_cursor < 1 then new_cursor = 1 end
  vim.api.nvim_win_set_cursor(0, { new_cursor, 0 })

  vim.cmd("write")
end


-- Создание временного окна для ввода
local function create_temp_window(options)
  local defaults = {
    height_ratio = 0.2,
    filetype = 'markdown',
    template = {},
    on_save = nil,
    on_cancel = nil,
  }

  local opts = vim.tbl_extend("force", defaults, options or {})

  local bufnr = vim.api.nvim_create_buf(false, true)
  local height = math.floor(vim.o.lines * opts.height_ratio)

  vim.cmd('botright ' .. height .. 'split')
  local win_id = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win_id, bufnr)

  -- Настройки буфера
  vim.bo[bufnr].filetype = opts.filetype
  vim.bo[bufnr].buftype = 'acwrite'
  vim.bo[bufnr].bufhidden = 'wipe'

  -- Настройки окна
  vim.wo[win_id].number = false
  vim.wo[win_id].relativenumber = false
  vim.wo[win_id].wrap = true
  vim.wo[win_id].signcolumn = 'no'
  vim.wo[win_id].cursorline = true
  vim.wo[win_id].winhl = 'Normal:Normal,FloatBorder:FloatBorder'

  -- Устанавливаем содержимое
  if #opts.template > 0 then
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, opts.template)
  end

  local function cleanup()
    if vim.api.nvim_win_is_valid(win_id) then
      vim.api.nvim_win_close(win_id, true)
    end
    pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
  end

  local function save_and_cleanup()
    if opts.on_save then
      local success = pcall(opts.on_save, bufnr)
      if success then
        cleanup()
      end
    else
      cleanup()
    end
  end

  local function cancel_and_cleanup()
    if opts.on_cancel then
      opts.on_cancel()
    end
    cleanup()
  end

  -- Маппинги
  local map_opts = { buffer = bufnr, silent = true }
  vim.keymap.set({ 'n', 'i' }, '<C-s>', save_and_cleanup, map_opts)
  vim.keymap.set({ 'n', 'i' }, '<C-c>', cancel_and_cleanup, map_opts)

  -- Автокоманда для cleanup
  vim.api.nvim_create_autocmd('BufWipeout', {
    buffer = bufnr,
    once = true,
    callback = cleanup
  })

  return {
    bufnr = bufnr,
    win_id = win_id,
    cleanup = cleanup
  }
end

-- Проверить, можно ли выполнить операцию с текущим заголовком
local function validate_heading_operation()
  local heading_data = get_current_heading_data()

  if not heading_data then
    return nil, "❌ Не на заголовке или файл не является заметкой"
  end

  -- Проверяем, что файл находится в директории заметок
  local current_file = vim.api.nvim_buf_get_name(heading_data.bufnr)
  local notes_dir = expand_path(config.notes_dir)

  if not current_file:match("^" .. notes_dir:gsub("%.", "%%."):gsub("%-", "%%-")) then
    return nil, "❌ Файл не находится в директории заметок"
  end

  return heading_data, nil
end

-- Проверить, можно ли удалить файл
local function validate_file_operation()
  local bufnr = vim.api.nvim_get_current_buf()
  local file_path = vim.api.nvim_buf_get_name(bufnr)

  -- Проверяем, что файл существует и это обычный файл (не unsaved buffer)
  if file_path == "" or file_path:match("^term://") then
    return nil, "❌ Не на сохраненном файле"
  end

  if not file_exists(file_path) then
    return nil, "❌ Файл не существует на диске"
  end

  -- Проверяем, что файл находится в директории заметок (опционально)
  local notes_dir = expand_path(config.notes_dir)
  if not file_path:match("^" .. notes_dir:gsub("%.", "%%."):gsub("%-", "%%-")) then
    return file_path, "⚠️  Внимание: файл не находится в директории заметок"
  end

  return file_path, nil
end

-- Inbox Capture --------------------------------------------------------------
function M.capture_to_inbox()
  local template = {
    "<!-- Введите заметку ниже -->",
    "<!-- Ctrl+S сохранить, Ctrl+C отменить -->",
    "",
    "# TODO:  ",
    "- Captured: `" .. get_current_datetime() .. "`",
  }

  local win = create_temp_window({
    template = template,
    on_save = function(bufnr)
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      local cleaned_lines = {}

      for _, line in ipairs(lines) do
        if not line:match("^<!%-%-") then
          table.insert(cleaned_lines, line)
        end
      end

      local inbox_path = get_inbox_path()
      local existing_lines = read_file(inbox_path)

      for _, line in ipairs(cleaned_lines) do
        table.insert(existing_lines, line)
      end

      write_file(inbox_path, existing_lines)
      notify("✅ Добавлено в Inbox")
    end
  })

  -- Устанавливаем курсор на строку "# TODO: " (строка 4)
  vim.api.nvim_win_set_cursor(win.win_id, { 4, 9 })
  vim.cmd('startinsert')
end

-- Review Inbox ---------------------------------------------------------------
function M.review_inbox()
  local Snacks = require("snacks")
  local inbox_path = get_inbox_path()

  if not file_exists(inbox_path) then
    notify("❌ Файл Inbox.md не найден", vim.log.levels.ERROR)
    return
  end

  local lines = read_file(inbox_path)
  local headers = {}

  for i, line in ipairs(lines) do
    local title = line:match("^#+ %s*(.+)$")
    if title then
      local timestamp = ""
      for j = i + 1, math.min(i + 5, #lines) do
        local ts = lines[j]:match("^- Captured: `([^`]+)`")
        if ts then
          timestamp = ts
          break
        end
      end

      table.insert(headers, {
        line = i,
        text = title,
        timestamp = timestamp,
      })
    end
  end

  if #headers == 0 then
    notify("📭 В Inbox.md нет заголовков TODO", vim.log.levels.INFO)
    return
  end

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
      local display_width = math.min(longest_text, 91)

      local formatted_text = string.format("%-" .. display_width .. "s",
        #item.text > display_width and item.text:sub(1, display_width - 3) .. "..." or item.text)
      ret[#ret + 1] = { formatted_text, 'SnacksPickerLabel' }

      if item.timestamp and item.timestamp ~= "" then
        ret[#ret + 1] = { "  [" .. item.timestamp .. "]", 'SnacksPickerComment' }
      end

      return ret
    end,
    preview = "file",
    confirm = function(picker, item)
      picker:close()

      vim.cmd("edit " .. vim.fn.fnameescape(item.file))
      vim.api.nvim_win_set_cursor(0, { item.line, 0 })
      vim.cmd("normal! zz")

      notify("📝 Перешли к: " .. item.text)
    end,
    prompt = "Inbox: "
  })
end

-- Refine Heading -------------------------------------------------------------
function M.refine_heading()
  local Snacks = require("snacks")
  local heading_data, error_msg = validate_heading_operation()
  if not heading_data then
    notify(error_msg, vim.log.levels.ERROR)
    return
  end

  local notes = get_all_notes()

  if #notes == 0 then
    notify("❌ Нет заметок для перемещения", vim.log.levels.ERROR)
    return
  end

  local items = {}
  local longest_title = 0

  for i, note in ipairs(notes) do
    table.insert(items, {
      idx = i,
      score = i,
      text = note.title,
      path = note.path,
      filename = note.filename,
    })

    longest_title = math.max(longest_title, #note.title)
  end

  local display_width = math.min(longest_title, 60)

  return Snacks.picker({
    items = items,
    format = function(item)
      local formatted_title = string.format("%-" .. display_width .. "s",
        #item.text > display_width and item.text:sub(1, display_width - 3) .. "..." or item.text)
      return { { formatted_title, 'SnacksPickerLabel' } }
    end,
    preview = "file",
    confirm = function(picker, item)
      picker:close()

      local choice = vim.fn.confirm(
        string.format("Переместить '%s' в заметку '%s'?",
          heading_data.heading_text, item.text),
        "&Yes\n&No", 2
      )

      if choice ~= 1 then
        notify("❌ Отменено")
        return
      end

      -- Добавляем в целевую заметку
      local target_lines = read_file(item.path)
      table.insert(target_lines, "")

      for line in heading_data.content:gmatch("[^\n]+") do
        table.insert(target_lines, line)
      end

      write_file(item.path, target_lines)

      -- Удаляем из исходной
      remove_block_from_buffer(heading_data)

      notify(string.format("✅ Перемещено в: %s", item.text))
    end,
    layout = { preset = "ivy" },
    prompt = "Куда переместить '" .. heading_data.heading_text .. "'?"
  })
end

--
-- Archive Heading ------------------------------------------------------------
function M.archive_heading()
  local heading_data, error_msg = validate_heading_operation()
  if not heading_data then
    notify(error_msg, vim.log.levels.ERROR)
    return
  end

  -- Ищем дату выполнения
  local completion_date = nil
  for _, line in ipairs(heading_data.content_lines) do
    local completion_match = line:match("^- Completion: `([^`]+)`")
    if completion_match then
      completion_date = completion_match
      break
    end
  end

  -- Определяем дату архивации
  local archive_date = completion_date or get_current_date()
  local archive_date_clean = archive_date:match("(%d%d%d%d%-%d%d%-%d%d)") or get_current_date()

  -- Путь к daily заметке
  local daily_path = get_daily_note_path(archive_date_clean)

  -- Создаем новый контент с меткой архивации после заголовка
  local archived_content = {}
  local source_filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(heading_data.bufnr), ":t:r")
  local archive_marker = "- Archived from: [[" .. source_filename .. "]] on `" .. get_current_datetime() .. "`"
  local found_header = false

  -- Проходим по строкам и вставляем метку после первого найденного заголовка
  for _, line in ipairs(heading_data.content_lines) do
    table.insert(archived_content, line)

    -- Если это заголовок и мы еще не вставляли метку
    if not found_header and line:match("^#+ ") then
      -- Проверяем, есть ли уже метка архивации в исходном контенте
      local has_existing_marker = false
      for _, content_line in ipairs(heading_data.content_lines) do
        if content_line:match("^- Archived from:") or
            content_line:match("^- Архивировано:") then
          has_existing_marker = true
          break
        end
      end

      -- Если нет существующей метки, добавляем новую
      if not has_existing_marker then
        table.insert(archived_content, archive_marker)
      end

      found_header = true
    end
  end

  -- Читаем существующую daily заметку
  local daily_content = read_file(daily_path)

  -- Проверяем, есть ли уже frontmatter в файле
  local has_frontmatter = false
  local frontmatter_end = 0

  if #daily_content >= 3 and daily_content[1] == "---" then
    for i = 2, #daily_content do
      if daily_content[i] == "---" then
        has_frontmatter = true
        frontmatter_end = i
        break
      end
    end
  end

  if #daily_content == 0 or not has_frontmatter then
    -- Создаем новую daily заметку с frontmatter
    daily_content = {
      "---",
      "title: " .. archive_date_clean,
      "created: " .. get_current_datetime(),
      "tags:",
      "  - daily-notes",
      "---",
      "",
      "# " .. archive_date_clean,
      ""
    }

    -- Добавляем существующий контент (если файл уже был)
    if #daily_content > 0 and has_frontmatter then
      -- Пропускаем frontmatter и заголовок даты в существующем файле
      local skip_lines = frontmatter_end + 1
      if daily_content[skip_lines] and daily_content[skip_lines]:match("^# " .. archive_date_clean) then
        skip_lines = skip_lines + 1
      end

      for i = skip_lines, #daily_content do
        table.insert(daily_content, daily_content[i])
      end
    end
  else
    -- Файл существует и имеет frontmatter
    -- Проверяем, есть ли уже заголовок с датой после frontmatter
    local has_date_header = false
    local insert_position = frontmatter_end + 2 -- после "---" и пустой строки

    -- Ищем заголовок с датой
    for i = insert_position, #daily_content do
      if daily_content[i] == "# " .. archive_date_clean then
        has_date_header = true
        insert_position = i + 1
        break
      elseif daily_content[i]:match("^#+ ") then
        -- Нашли другой заголовок, вставляем перед ним
        insert_position = i
        break
      end
    end

    -- Если не нашли заголовок с датой, добавляем его
    if not has_date_header then
      table.insert(daily_content, insert_position, "")
      table.insert(daily_content, insert_position + 1, "# " .. archive_date_clean)
      insert_position = insert_position + 2
    end
  end

  -- Добавляем архивированный контент в конец файла
  for _, line in ipairs(archived_content) do
    table.insert(daily_content, line)
  end

  -- Записываем daily заметку
  write_file(daily_path, daily_content)

  -- Удаляем из исходного файла
  remove_block_from_buffer(heading_data)

  -- Показываем результат
  local message = "📦 Архивировано в daily/" .. archive_date_clean .. ".md"
  if completion_date then
    message = message .. " (дата выполнения: " .. completion_date .. ")"
  end

  notify(message)
end

-- Remove Current File --------------------------------------------------------
function M.remove_current_file()
  local file_path, warning_msg = validate_file_operation()
  if not file_path then
    notify(warning_msg, vim.log.levels.ERROR)
    return
  end

  -- Если есть предупреждение, но файл валиден - показываем его
  if warning_msg then
    local choice = vim.fn.confirm(
      warning_msg .. "\nПродолжить удаление?",
      "&Yes\n&Нет", 2
    )

    if choice ~= 1 then
      notify("❌ Удаление отменено")
      return
    end
  end

  -- Получаем имя файла для подтверждения
  local filename = vim.fn.fnamemodify(file_path, ":t")

  -- Запрос подтверждения
  local choice = vim.fn.confirm(
    string.format("Удалить файл '%s' безвозвратно?", filename),
    "&Yes\n&No", 2
  )

  if choice ~= 1 then
    notify("❌ Удаление отменено")
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()

  -- Удаляем файл с диска
  local success = os.remove(file_path)

  if success then
    notify(string.format("✅ Файл '%s' удален", filename))

    -- Удаляем буфер если он еще существует
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end
  else
    notify(string.format("❌ Не удалось удалить файл '%s'", filename), vim.log.levels.ERROR)
  end

  -- Закрываем все окна, использующие этот буфер
  local windows = vim.api.nvim_list_wins()
  for _, win_id in ipairs(windows) do
    if vim.api.nvim_win_get_buf(win_id) == bufnr then
      vim.api.nvim_win_close(win_id, true)
    end
  end
end

-- Настройка команд и маппингов -----------------------------------------------
function M.setup(user_config)
  if user_config then
    config = vim.tbl_extend("force", config, user_config)
  end

  -- Стандартизированные команды
  vim.api.nvim_create_user_command('NoteCapture', M.capture_to_inbox, {
    desc = 'Capture note to Inbox'
  })

  vim.api.nvim_create_user_command('NoteReview', M.review_inbox, {
    desc = 'Review notes in Inbox'
  })

  vim.api.nvim_create_user_command('NoteRefile', M.refine_heading, {
    desc = 'Refile current heading to another note'
  })

  vim.api.nvim_create_user_command('NoteArchive', M.archive_heading, {
    desc = 'Archive current heading to daily note'
  })

  vim.api.nvim_create_user_command('NoteRemoveFile', M.remove_current_file, {
    desc = 'Delete current note file from disk'
  })

  -- Маппинги (можно настраивать через конфиг)
  vim.keymap.set('n', '<leader>nc', '<cmd>NoteCapture<CR>', {
    desc = 'Capture to Inbox'
  })

  vim.keymap.set('n', '<leader>ni', '<cmd>NoteReview<CR>', {
    desc = 'Review Inbox'
  })

  vim.keymap.set('n', '<leader>nr', '<cmd>NoteRefile<CR>', {
    desc = 'Refile current heading'
  })

  vim.keymap.set('n', '<leader>na', '<cmd>NoteArchive<CR>', {
    desc = 'Archive heading to daily'
  })

  vim.keymap.set('n', '<leader>nd', '<cmd>NoteRemoveFile<CR>', {
    desc = 'Delete current note file'
  })

  -- Plugins mappings
  -- Основные маппинги для Obsidian
  vim.keymap.set('n', '<leader>nf', '<cmd>Obsidian quick_switch<cr>', {
    desc = 'Find (or create) note'
  })

  vim.keymap.set('n', '<leader>fn', '<cmd>Obsidian quick_switch<cr>', {
    desc = 'Find note'
  })

  vim.keymap.set('n', '<leader>n/', '<cmd>Obsidian search<cr>', {
    desc = 'Grep in notes'
  })

  vim.keymap.set('n', '<leader>nl', '<cmd>Obsidian links<cr>', {
    desc = 'Show links'
  })

  -- vim.keymap.set('n', '<leader>nb', '<cmd>Obsidian backlinks<cr>', {
  --   desc = 'Show backlinks'
  -- })

  vim.keymap.set('n', '<leader>nb', '<cmd>ZkBacklinks<cr>', {
    desc = 'Show backlinks'
  })

  vim.keymap.set('n', '<leader>nI', '<cmd>e ~/Nextcloud/Notes/Inbox.md<cr>', {
    desc = 'Open Inbox'
  })

  -- Визуальный режим для извлечения заметки
  vim.keymap.set('v', '<leader>ne', function()
    vim.ui.input({ prompt = "Extract Note" }, function(str)
      if str and #str > 0 then
        require("obsidian.api").extract_note(str)
      end
    end)
  end, {
    desc = 'Extract selection to new note'
  })


  -- zk-nvim
  -- vim.keymap.set('n', '<leader>nc', function()
  --   local params = {
  --     template = "todo.md",
  --     insertContentAtLocation = {
  --       uri = "~/Nextcloud/Notes/Inbox.md",
  --       range = {
  --         start = { line = vim.fn.line('.') - 1, character = 0 },
  --         ['end'] = { line = vim.fn.line('.') - 1, character = 0 }
  --       }
  --     }
  --   }
  --   vim.cmd("ZkNew " .. vim.fn.shellescape(vim.fn.json_encode(params)))
  -- end, { desc = "Insert zk template content at cursor" })
end

-- Автоматическая настройка при загрузке
M.setup()

return M
