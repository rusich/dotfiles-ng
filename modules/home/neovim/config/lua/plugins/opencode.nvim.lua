-- 🤖 Neovim + OpenCode: контекст/промпты из редактора в opencode TUI
-- Подключается к постоянному хабу `opencode web` (systemd user service
-- opencode-web, см. modules/home/opencode.nix). Сессии общие с TUI и web.
-- https://github.com/nickjvandyke/opencode.nvim

--- Команда TUI, подключённого к хабу. Проект = текущий cwd neovim,
--- поэтому считаем в момент вызова (поддержка нескольких проектов на одном хабе).
local function tui_cmd()
  return ('opencode attach http://localhost:4096 --dir %s'):format(vim.fn.getcwd())
end

---@type snacks.terminal.Opts
local tui_opts = {
  win = { position = 'right', enter = false },
}

--- opencode отдаёт `metadata.diff` = trimDiff(createTwoFilesPatch(...)), где
--- trimDiff срезает общий минимальный отступ у строк ` ` / `-` / `+`. Такой
--- патч не накладывается `diffpatch`'ем на реальный файл (контекст не совпадает
--- по отступам), и вкладка диффа показывает две одинаковые панели. Функция
--- восстанавливает срезанный отступ, сопоставив контекстные строки патча с
--- содержимым файла, и возвращает валидный unified diff.
local function untrim_diff(diff, filepath)
  local fp = vim.fn.fnamemodify(filepath, ':p')
  if vim.fn.filereadable(fp) ~= 1 and vim.env.HOME and vim.env.HOME ~= '' then
    fp = vim.fs.normalize(vim.fs.joinpath(vim.env.HOME, filepath))
  end
  if vim.fn.filereadable(fp) ~= 1 then
    return diff
  end

  local file_lines = vim.fn.readfile(fp)
  local lines = vim.split(diff, '\n')

  local delta
  local prefix_ws
  local i = 1
  while i <= #lines and not delta do
    local start = lines[i]:match('^@@ %-(%d+)')
    if start then
      local old_idx = tonumber(start)
      i = i + 1
      while i <= #lines and not lines[i]:match('^@@') do
        local ln = lines[i]
        local p = ln:sub(1, 1)
        if p == ' ' or p == '-' then
          local fl = file_lines[old_idx]
          if fl then
            local _, e = fl:find('^%s*')
            local file_indent = e or 0
            local _, ce = ln:sub(2):find('^%s*')
            local diff_indent = ce or 0
            local d = file_indent - diff_indent
            if d > 0 then
              delta = d
              prefix_ws = fl:sub(1, d)
              break
            end
          end
          old_idx = old_idx + 1
        elseif p == '+' or ln == '' or p == '\\' then
          -- no old advance
        else
          old_idx = old_idx + 1
        end
        i = i + 1
      end
    else
      i = i + 1
    end
  end

  if not delta or delta == 0 then
    return diff
  end

  local out = {}
  for _, line in ipairs(lines) do
    local p = line:sub(1, 1)
    if (p == ' ' or p == '-' or p == '+') and not line:match('^%-%-%-') and not line:match('^%+%+%+') then
      out[#out + 1] = p .. prefix_ws .. line:sub(2)
    else
      out[#out + 1] = line
    end
  end
  return table.concat(out, '\n')
end

---@type LazyPluginSpec
local spec = {
  'nickjvandyke/opencode.nvim',
  version = '*', -- последний стабильный релиз
  lazy = false, -- постоянный коннект к хабу: события, autoread, permission-диффы

  init = function()
    -- Пароль и имя пользователя basic auth хаба — из KeePassXC (Secret Service)
    -- в рантайме. Плагин сам читает OPENCODE_SERVER_PASSWORD/OPENCODE_SERVER_USERNAME из env.
    if not vim.env.OPENCODE_SERVER_PASSWORD then
      local pass = vim.fn.system({ 'secret-tool', 'lookup', 'short', 'OPENCODE_SERVER_PASSWORD' }):gsub('%s+$', '')
      if pass ~= '' then
        vim.env.OPENCODE_SERVER_PASSWORD = pass
      end
    end

    if not vim.env.OPENCODE_SERVER_USERNAME then
      local user = vim.fn.system({ 'secret-tool', 'lookup', 'short', 'OPENCODE_SERVER_USERNAME' }):gsub('%s+$', '')
      if user ~= '' then
        vim.env.OPENCODE_SERVER_USERNAME = user
      end
    end

    ---@type opencode.Opts
    vim.g.opencode_opts = {
      server = {
        url = 'http://localhost:4096',
        -- Фолбэк, если хаб не найден: открыть TUI-панель справа.
        -- (Если хаб лежит, attach в терминале честно покажет ошибку.)
        start = function()
          Snacks.terminal.open(tui_cmd(), tui_opts)
        end,
      },
    }
  end,

  -- FIX: opencode 1.18 скоупит SSE-поток `/event` (и прочие запросы) по
  -- каталогу. Без этого запросы плагина наследуют ambient-каталог хаба
  -- (/home/rusich, где запущен `opencode serve`), и события
  -- permission.asked / file.edited для проекта (cwd neovim, напр.
  -- ~/.dotfiles) не доходят — в итоге нет ни vimdiff-подтверждения правок,
  -- ни авто-перечитывания буфера. Добавляем `directory=` ко всем запросам.
  -- См. https://github.com/nickjvandyke/opencode.nvim/issues/239
  config = function()
    local server = require('opencode.server')

    -- FIX (scope): opencode 1.18+ скоупит `/event` строго по directory. Запросы
    -- плагина наследуют ambient-каталог хаба (/home/rusich), но правки могут
    -- идти в сессиях и каталога cwd nvim (напр. ~/.dotfiles), и наоборот.
    -- Поэтому добавляем `directory=` ко всем запросам (чтобы get_path/get_sessions
    -- были про cwd), но SSE подписываем на ДВА потока: амбиент и cwd — иначе
    -- permission.asked / file.edited из «чужого» каталога не доходят, и дифф
    -- не открывается.
    local orig_curl = server.curl
    server.curl = function(self, path, method, body, on_success, on_error, opts)
      local sep = path:find('?', 1, true) and '&' or '?'
      path = path .. sep .. 'directory=' .. vim.uri_encode(vim.fn.getcwd())
      return orig_curl(self, path, method, body, on_success, on_error, opts)
    end
    server.sse_subscribe = function(self, on_success, on_error)
      local job_ambient = orig_curl(self, '/event', 'GET', nil, on_success, on_error, { persistent = true })
      local job_cwd = self:curl('/event', 'GET', nil, on_success, on_error, { persistent = true })
      self.subscription_jobs = { job_ambient, job_cwd }
      self.subscription_job_id = job_ambient
      return job_ambient
    end
    local orig_disconnect = server.disconnect
    server.disconnect = function(self)
      if self.subscription_jobs then
        for _, job in ipairs(self.subscription_jobs) do
          vim.fn.jobstop(job)
        end
        self.subscription_jobs = nil
        self.subscription_job_id = nil
      end
      return orig_disconnect(self)
    end

    -- FIX: чиним trimDiff-дифф (см. untrim_diff выше), иначе `diffpatch`
    -- показывает две одинаковые панели. Оборачиваем оригинальный обработчик,
    -- не трогая его логику (keymaps `da`/`dr`/`dp`/`do`, Promise, reply).
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
  end,

  keys = {
    {
      '<C-a>',
      function()
        require('opencode').ask '@this: '
      end,
      mode = { 'n', 'x' },
      desc = 'Ask OpenCode…',
    },
    {
      '<C-x>',
      function()
        require('opencode').select()
      end,
      mode = { 'n', 'x' },
      desc = 'Select OpenCode action…',
    },
    {
      'go',
      function()
        return require('opencode').operator '@this '
      end,
      mode = { 'n', 'x' },
      expr = true,
      desc = 'Append range to OpenCode',
    },
    {
      'goo',
      function()
        return require('opencode').operator '@this ' .. '_'
      end,
      expr = true,
      desc = 'Append line to OpenCode',
    },
    {
      '<S-C-u>',
      function()
        require('opencode').command 'session.half.page.up'
      end,
      desc = 'Scroll OpenCode up',
    },
    {
      '<S-C-d>',
      function()
        require('opencode').command 'session.half.page.down'
      end,
      desc = 'Scroll OpenCode down',
    },
    {
      '<C-.>',
      function()
        Snacks.terminal.toggle(tui_cmd(), tui_opts)
      end,
      mode = { 'n', 't' },
      desc = 'Toggle OpenCode TUI',
    },
  },
}

return spec
