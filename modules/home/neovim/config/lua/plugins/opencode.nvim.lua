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
