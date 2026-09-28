-- ~/.config/nvim/plugin/notes.lua
-- Единый модуль для работы с заметками.
--
-- После рефакторинга опирается на публичные API obsidian.nvim:
--   obsidian.section, obsidian.daily, obsidian.date, obsidian.picker,
--   obsidian.actions.delete_note, obsidian.api, Note:backlinks().

local M = {}

-- Конфигурация ---------------------------------------------------------------

local config = {
  notes_dir = '~/Nextcloud/Notes',
  inbox_file = 'Inbox.md',
  daily_dir = 'daily',
}

-- Утилиты --------------------------------------------------------------------

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO)
end

local function expand_path(path)
  return vim.fn.expand(path)
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
  return os.date(format or '%Y-%m-%d')
end

local function get_current_datetime()
  return os.date '%Y-%m-%d %H:%M'
end

local function get_inbox_path()
  return expand_path(config.notes_dir .. '/' .. config.inbox_file)
end

local function write_buffer(bufnr)
  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd 'write'
  end)
end

-- Секции заметок -------------------------------------------------------------
-- obsidian.section парсит markdown на секции (preamble + заголовки).
-- Все диапазоны Range — 0-based, end-exclusive.

--- Секция текущей заметки, содержащая курсор.
---@return table|nil heading_data
---@return string|nil error_msg
local function get_current_section(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local note = require('obsidian.api').current_note(bufnr)
  if not note then
    return nil, '❌ Файл не находится в директории заметок'
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local sections = require('obsidian.section').parse(lines, {
    start_row = note.frontmatter_end_line or 0,
  })

  -- Ближайший заголовок на уровне курсора или выше.
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local current_idx
  for i, section in ipairs(sections) do
    if section.header and section.heading_range.start_row <= row then
      current_idx = i
    end
  end

  if not current_idx then
    return nil, '❌ Не на заголовке или файл не является заметкой'
  end

  local section = sections[current_idx]

  -- Конец секции: следующий заголовок того же или более высокого уровня.
  local end_excl = #lines
  for j = current_idx + 1, #sections do
    local next_section = sections[j]
    if next_section.level and next_section.level <= section.level then
      end_excl = next_section.heading_range.start_row
      break
    end
  end

  local start_row = section.heading_range.start_row

  return {
    bufnr = bufnr,
    lines = lines,
    heading = lines[start_row + 1] or '',
    heading_text = section.header or '',
    level = section.level,
    start_line = start_row + 1, -- 1-based, первая строка секции
    end_line = end_excl, -- 1-based, последняя строка секции (включительно)
    content_lines = vim.list_slice(lines, start_row + 1, end_excl),
  }
end

--- Удалить секцию из буфера и сохранить файл.
local function remove_block_from_buffer(heading_data)
  vim.api.nvim_buf_set_lines(heading_data.bufnr, heading_data.start_line - 1, heading_data.end_line, false, {})

  local line_count = vim.api.nvim_buf_line_count(heading_data.bufnr)
  local new_cursor = math.max(1, math.min(heading_data.start_line - 1, line_count))
  vim.api.nvim_win_set_cursor(0, { new_cursor, 0 })

  write_buffer(heading_data.bufnr)
end

local function validate_heading_operation()
  local heading_data, error_msg = get_current_section()
  if not heading_data then
    return nil, error_msg
  end
  return heading_data, nil
end

-- Временное окно для ввода ---------------------------------------------------

local function create_temp_window(options)
  local defaults = {
    height_ratio = 0.2,
    filetype = 'markdown',
    template = {},
    on_save = nil,
    on_cancel = nil,
  }

  local opts = vim.tbl_extend('force', defaults, options or {})

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
      pcall(vim.api.nvim_win_close, win_id, true)
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
    callback = cleanup,
  })

  return {
    bufnr = bufnr,
    win_id = win_id,
    cleanup = cleanup,
  }
end

-- Inbox Capture --------------------------------------------------------------

function M.capture_to_inbox()
  local template = {
    '<!-- Введите заметку ниже -->',
    '<!-- Ctrl+S сохранить, Ctrl+C отменить -->',
    '',
    '# TODO:  ',
    '- Captured: `' .. get_current_datetime() .. '`',
  }

  local win = create_temp_window {
    template = template,
    on_save = function(bufnr)
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      local cleaned_lines = {}

      for _, line in ipairs(lines) do
        if not line:match '^<!%-%-' then
          table.insert(cleaned_lines, line)
        end
      end

      local inbox_path = get_inbox_path()
      local existing_lines = read_file(inbox_path)

      for _, line in ipairs(cleaned_lines) do
        table.insert(existing_lines, line)
      end

      write_file(inbox_path, existing_lines)
      notify '✅ Добавлено в Inbox'
    end,
  }

  -- Устанавливаем курсор на строку "# TODO: " (строка 4)
  vim.api.nvim_win_set_cursor(win.win_id, { 4, 9 })
  vim.cmd 'startinsert'
end

-- Review Inbox ---------------------------------------------------------------

function M.review_inbox()
  local Snacks = require 'snacks'
  local inbox_path = get_inbox_path()

  if not file_exists(inbox_path) then
    notify('❌ Файл Inbox.md не найден', vim.log.levels.ERROR)
    return
  end

  local lines = read_file(inbox_path)
  local headers = {}

  for i, line in ipairs(lines) do
    local title = line:match '^#+ %s*(.+)$'
    if title then
      local timestamp = ''
      for j = i + 1, math.min(i + 5, #lines) do
        local ts = lines[j]:match '^- Captured: `([^`]+)`'
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
    notify('📭 В Inbox.md нет заголовков TODO', vim.log.levels.INFO)
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

  return Snacks.picker {
    items = items,
    format = function(item)
      local ret = {}
      local display_width = math.min(longest_text, 91)

      local formatted_text =
        string.format('%-' .. display_width .. 's', #item.text > display_width and item.text:sub(1, display_width - 3) .. '...' or item.text)
      ret[#ret + 1] = { formatted_text, 'SnacksPickerLabel' }

      if item.timestamp and item.timestamp ~= '' then
        ret[#ret + 1] = { '  [' .. item.timestamp .. ']', 'SnacksPickerComment' }
      end

      return ret
    end,
    preview = 'file',
    confirm = function(picker, item)
      picker:close()

      vim.cmd('edit ' .. vim.fn.fnameescape(item.file))
      vim.api.nvim_win_set_cursor(0, { item.line, 0 })
      vim.cmd 'normal! zz'

      notify('📝 Перешли к: ' .. item.text)
    end,
    prompt = 'Inbox: ',
  }
end

-- Refile Heading -------------------------------------------------------------

function M.refile_heading()
  local heading_data, error_msg = validate_heading_operation()
  if not heading_data then
    notify(error_msg, vim.log.levels.ERROR)
    return
  end

  local source_path = vim.api.nvim_buf_get_name(heading_data.bufnr)
  local inbox_path = get_inbox_path()

  require('obsidian.picker').find_notes {
    prompt_title = "Куда переместить '" .. heading_data.heading_text .. "'?",
    no_default_mappings = true,
    callback = function(paths)
      local target_path = paths and paths[1]
      if not target_path then
        notify '❌ Отменено'
        return
      end

      if target_path == source_path or target_path == inbox_path then
        notify('❌ Нельзя переместить в эту же заметку или в Inbox', vim.log.levels.WARN)
        return
      end

      local target = require('obsidian.note').from_file(target_path)
      local target_name = target:display_name()

      local choice =
        vim.fn.confirm(string.format("Переместить '%s' в заметку '%s'?", heading_data.heading_text, target_name), '&Yes\n&No', 2)
      if choice ~= 1 then
        notify '❌ Отменено'
        return
      end

      target:save {
        update_content = function(lines)
          if #lines > 0 and lines[#lines] ~= '' then
            table.insert(lines, '')
          end
          vim.list_extend(lines, vim.deepcopy(heading_data.content_lines))
          return lines
        end,
      }

      remove_block_from_buffer(heading_data)

      notify(string.format('✅ Перемещено в: %s', target_name))
    end,
  }
end

-- Archive Heading ------------------------------------------------------------

function M.archive_heading()
  local heading_data, error_msg = validate_heading_operation()
  if not heading_data then
    notify(error_msg, vim.log.levels.ERROR)
    return
  end

  -- Дата выполнения из метки `- Completion:`
  local completion_date
  for _, line in ipairs(heading_data.content_lines) do
    local match = line:match '^- Completion: `([^`]+)`'
    if match then
      completion_date = match
      break
    end
  end

  local archive_date = completion_date or get_current_date()
  local archive_date_clean = archive_date:match '(%d%d%d%d%-%d%d%-%d%d)' or get_current_date()

  -- Метка об архивации (если её ещё нет).
  local marker_done = false
  for _, line in ipairs(heading_data.content_lines) do
    if line:match '^- Archived from:' or line:match '^- Архивировано:' then
      marker_done = true
      break
    end
  end

  local source_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(heading_data.bufnr), ':t:r')
  local archive_marker = '- Archived from: [[' .. source_name .. ']] on `' .. get_current_datetime() .. '`'

  local archived_content = {}
  for _, line in ipairs(heading_data.content_lines) do
    table.insert(archived_content, line)
    if not marker_done and line:match '^#+ ' then
      table.insert(archived_content, archive_marker)
      marker_done = true
    end
  end

  local parsed_date = require('obsidian.date').parse(archive_date_clean)
  if not parsed_date then
    notify('❌ Не удалось разобрать дату: ' .. archive_date_clean, vim.log.levels.ERROR)
    return
  end

  local daily = require('obsidian.daily').daily { date = os.time(parsed_date) }
  local date_heading = '# ' .. archive_date_clean

  daily:write {
    update_content = function(lines)
      if not vim.list_contains(lines, date_heading) then
        table.insert(lines, 1, date_heading)
        table.insert(lines, 2, '')
      end
      if #lines > 0 and lines[#lines] ~= '' then
        table.insert(lines, '')
      end
      vim.list_extend(lines, archived_content)
      return lines
    end,
  }

  remove_block_from_buffer(heading_data)

  local message = '📦 Архивировано в daily/' .. archive_date_clean .. '.md'
  if completion_date then
    message = message .. ' (дата выполнения: ' .. completion_date .. ')'
  end
  notify(message)
end

-- Generate HUB page ----------------------------------------------------------

--- Сгенерировать секцию "## Заметки" с обратными ссылками на текущий hub.
---@param opts? { bufnr?: integer, silent?: boolean }
function M.generate_hub_page(opts)
  opts = opts or {}
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()

  local note = require('obsidian.note').from_buffer(bufnr)
  if not note or not note:has_tag 'hub' then
    if not opts.silent then
      notify("❌ Этот файл не помечен как hub (нет тега 'hub' в frontmatter)", vim.log.levels.WARN)
    end
    return
  end

  local api = require 'obsidian.api'
  local notes_dir = tostring(api.resolve_workspace_dir())
  local daily_dir = vim.fs.joinpath(notes_dir, config.daily_dir)
  local hub_path = vim.api.nvim_buf_get_name(bufnr)
  local hub_name = vim.fn.fnamemodify(hub_path, ':t:r')

  -- Обратные ссылки на заметку (id/алиасы/путь), включая markdown-ссылки.
  local matches = note:backlinks()

  local lines_by_file = {}
  for _, match in ipairs(matches) do
    local path = tostring(match.path)
    if path ~= hub_path and not vim.startswith(path, daily_dir) then
      lines_by_file[path] = lines_by_file[path] or {}
      table.insert(lines_by_file[path], match.line)
    end
  end

  local Section = require 'obsidian.section'

  -- Оставляем только файлы, где ссылка встречается вне авто-секции "## Заметки"
  -- (иначе хабы начинают ссылаться друг на друга каскадом).
  local files = {}
  for path, match_lines in pairs(lines_by_file) do
    local handle = io.open(path, 'r')
    if handle then
      local file_lines = {}
      for line in handle:lines() do
        file_lines[#file_lines + 1] = line
      end
      handle:close()

      local notes_section
      for _, section in ipairs(Section.parse(file_lines)) do
        if section.header and section.header:match '^Заметки' then
          notes_section = section
          break
        end
      end

      for _, lnum in ipairs(match_lines) do
        local row = lnum - 1
        if not (notes_section and notes_section.range.start_row <= row and row < notes_section.range.end_row) then
          files[#files + 1] = path
          break
        end
      end
    end
  end

  table.sort(files, function(a, b)
    return vim.fn.fnamemodify(a, ':t:r') < vim.fn.fnamemodify(b, ':t:r')
  end)

  local new_section = { string.format('## Заметки (%d)', #files), '' }
  if #files > 0 then
    for _, path in ipairs(files) do
      table.insert(new_section, string.format('- [[%s]]', vim.fn.fnamemodify(path, ':t:r')))
    end
  else
    table.insert(new_section, '*Пока нет заметок в этом хабе*')
  end
  table.insert(new_section, '')

  local current_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local existing_section
  for _, section in ipairs(Section.parse(current_lines)) do
    if section.header and section.header:match '^Заметки' then
      existing_section = section
      break
    end
  end

  local new_lines = {}
  if existing_section then
    local replace_start = existing_section.range.start_row
    local replace_end = existing_section.range.end_row
    -- Поглощаем пустые строки после секции, чтобы замена была идемпотентной.
    while replace_end < #current_lines and current_lines[replace_end + 1] == '' do
      replace_end = replace_end + 1
    end

    if replace_start > 0 then
      vim.list_extend(new_lines, current_lines, 1, replace_start)
    end
    vim.list_extend(new_lines, new_section)
    if replace_end < #current_lines then
      vim.list_extend(new_lines, current_lines, replace_end + 1, #current_lines)
    end
  else
    vim.list_extend(new_lines, current_lines)
    if #new_lines > 0 and new_lines[#new_lines] ~= '' then
      table.insert(new_lines, '')
    end
    vim.list_extend(new_lines, new_section)
  end

  if vim.deep_equal(new_lines, current_lines) then
    if not opts.silent then
      notify(string.format("✅ Хаб '%s' актуален (%d заметок)", hub_name, #files))
    end
    return
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
  write_buffer(bufnr)

  if not opts.silent then
    notify(string.format("🔄 Хаб '%s' обновлён (%d заметок)", hub_name, #files))
  end
end

--- Авто-обновление hub-заметок при входе в буфер.
local function setup_hub_autocommand()
  vim.api.nvim_create_autocmd('User', {
    pattern = 'ObsidianNoteEnter',
    callback = function(ev)
      if not vim.api.nvim_buf_is_valid(ev.buf) or vim.bo[ev.buf].modified then
        return
      end

      local ok, note = pcall(function()
        return require('obsidian.note').from_buffer(ev.buf)
      end)
      if not ok or not note or not note:has_tag 'hub' then
        return
      end

      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(ev.buf) and not vim.bo[ev.buf].modified then
          local ok, err = pcall(M.generate_hub_page, { bufnr = ev.buf, silent = true })
          if not ok then
            require('obsidian.log').warn('hub auto-update failed for %s: %s', vim.api.nvim_buf_get_name(ev.buf), err)
          end
        end
      end)
    end,
  })
end

-- Настройка команд и маппингов -----------------------------------------------

function M.setup(user_config)
  if user_config then
    config = vim.tbl_extend('force', config, user_config)
  end

  setup_hub_autocommand()

  -- Стандартизированные команды
  vim.api.nvim_create_user_command('NoteCapture', M.capture_to_inbox, {
    desc = 'Capture note to Inbox',
  })

  vim.api.nvim_create_user_command('NoteReview', M.review_inbox, {
    desc = 'Review notes in Inbox',
  })

  vim.api.nvim_create_user_command('NoteRefile', M.refile_heading, {
    desc = 'Refile current heading to another note',
  })

  vim.api.nvim_create_user_command('NoteArchive', M.archive_heading, {
    desc = 'Archive current heading to daily note',
  })

  vim.api.nvim_create_user_command('NoteRemoveFile', function()
    require('obsidian.actions').delete_note()
  end, {
    desc = 'Delete current note file from disk',
  })

  vim.api.nvim_create_user_command('NoteHub', function()
    M.generate_hub_page()
  end, {
    desc = 'Generate hub page',
  })

  -- Маппинги (можно настраивать через конфиг)
  vim.keymap.set('n', '<leader>nc', '<cmd>NoteCapture<CR>', {
    desc = 'Capture to Inbox',
  })

  vim.keymap.set('n', '<leader>ni', '<cmd>NoteReview<CR>', {
    desc = 'Review Inbox',
  })

  vim.keymap.set('n', '<leader>nr', '<cmd>NoteRefile<CR>', {
    desc = 'Refile current heading',
  })

  vim.keymap.set('n', '<leader>na', '<cmd>NoteArchive<CR>', {
    desc = 'Archive heading to daily',
  })

  vim.keymap.set('n', '<leader>nd', '<cmd>NoteRemoveFile<CR>', {
    desc = 'Delete current note file',
  })

  vim.keymap.set('n', '<leader>nh', '<cmd>NoteHub<CR>', {
    desc = 'Generate hub page',
  })

  -- Obsidian mappings --------------------------------------------------------

  -- Новая заметка из шаблона
  vim.keymap.set('n', '<leader>nn', '<cmd>Obsidian new_from_template<cr>', {
    desc = 'New note from template',
  })
  vim.keymap.set('n', '<leader>nf', '<cmd>Obsidian quick_switch<cr>', {
    desc = 'Find(or create) note',
  })

  vim.keymap.set('n', '<leader>fn', '<cmd>Obsidian quick_switch<cr>', {
    desc = 'Find note',
  })

  vim.keymap.set('n', '<leader>n/', '<cmd>Obsidian search<cr>', {
    desc = 'Grep in notes',
  })

  vim.keymap.set('n', '<leader>nl', '<cmd>Obsidian links<cr>', {
    desc = 'Show links',
  })

  vim.keymap.set('n', '<leader>nb', '<cmd>Obsidian backlinks<cr>', {
    desc = 'Show backlinks',
  })

  vim.keymap.set('n', '<leader>nI', '<cmd>e ~/Nextcloud/Notes/Inbox.md<cr>', {
    desc = 'Open Inbox',
  })

  -- Визуальный режим для извлечения заметки
  vim.keymap.set('v', '<leader>ne', function()
    vim.ui.input({ prompt = 'Extract Note' }, function(str)
      if str and #str > 0 then
        require('obsidian.api').extract_note(str)
      end
    end)
  end, {
    desc = 'Extract selection to new note',
  })
end

-- Автоматическая настройка при загрузке
M.setup()

return M
