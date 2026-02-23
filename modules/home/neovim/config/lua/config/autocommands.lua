-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

local function augroup(name)
  return vim.api.nvim_create_augroup('mynvim_' .. name, { clear = true })
end

-- Save/Resotre folds between sessions
vim.api.nvim_create_autocmd({ 'BufWinLeave' }, {
  pattern = { '*.*' },
  desc = 'save view (folds), when closing file',
  callback = function()
    -- vim.cmd 'set foldmethod=manual'
    vim.cmd 'mkview'
    -- vim.cmd 'set foldmethod=expr'
  end,
})
vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
  pattern = { '*.*' },
  desc = 'load view (folds), when opening file',
  callback = function()
    vim.cmd 'silent! loadview'
    -- vim.cmd 'set foldmethod=manual'
    -- vim.cmd 'set foldmethod=expr'
  end,
})

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Auto reload plugin config
vim.api.nvim_create_autocmd('BufWritePost', {
  desc = 'Auto reload nvim/plugin config',
  pattern = '*/nvim/*.lua',
  group = vim.api.nvim_create_augroup('auto-reload-nvim-config', { clear = true }),
  callback = function()
    local file = vim.fn.expand '%'

    if string.find(file, 'plugins') or string.find(file, 'themes') then
      local plugin_name = file:match '^.*/(.*).lua$'
      local timer = assert(vim.uv.new_timer())
      timer:start(3000, 0, function()
        -- print('Reloading plugin: ' .. plugin_name .. 'time: ' .. os.time())
        vim.schedule(function()
          vim.cmd('Lazy reload ' .. plugin_name)
        end)
      end)
      -- sleep(3)
      -- print 'Reloaded!'
    elseif not string.find(file, 'disabled_plugins') then
      vim.cmd 'source %'
      -- without this indent lines looks ugly
      -- vim.cmd 'IBLDisable'
      -- vim.cmd 'IBLEnable'

      print('Config reloaded: ' .. vim.fn.expand '%')
    end
  end,
})

-- -- resize splits if window got resized
-- vim.api.nvim_create_autocmd({ 'VimResized' }, {
--   group = vim.api.nvim_create_augroup('autoresize', { clear = true }),
--   callback = function()
--     local current_tab = vim.fn.tabpagenr()
--     vim.cmd 'tabdo wincmd ='
--     vim.cmd('tabnext ' .. current_tab)
--   end,
-- })

-- close some filetypes with <q>
vim.api.nvim_create_autocmd('FileType', {
  group = augroup 'close_with_q',
  pattern = {
    'PlenaryTestPopup',
    'checkhealth',
    'dbout',
    'gitsigns-blame',
    'grug-far',
    'help',
    'lspinfo',
    'neotest-output',
    'neotest-output-panel',
    'neotest-summary',
    'notify',
    'qf',
    'spectre_panel',
    'startuptime',
    'tsplayground',
    'codecompanion',
  },

  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set('n', 'q', function()
        vim.cmd 'close'
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = 'Quit buffer',
      })
    end)
  end,
})

-- check for spell in text filetypes
vim.api.nvim_create_autocmd('FileType', {
  group = augroup 'auto_check_spell',
  pattern = { 'text', 'plaintex', 'typst', 'gitcommit', 'markdown', 'markdown_inline', 'org' },
  callback = function()
    vim.opt_local.spell = true
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  group = augroup 'auto_create_dir',
  callback = function(event)
    if event.match:match '^%w%w+:[\\/][\\/]' then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- Автоматическое продолжение списков в markdown
-- Общая функция для продолжения списков
local function continue_list()
  local line = vim.api.nvim_get_current_line()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local indent = line:match("^(%s*)") or ""

  -- Проверяем разные типы списков
  local patterns = {
    -- Checkbox: "- [ ] текст" или "* [ ] текст"
    {
      pattern = "^%s*([-*])%s+%[(%s)%]%s+(.*)$",
      handler = function(bullet, checked)
        local next_checked = checked == "x" and "x" or " "
        return indent .. bullet .. " [" .. next_checked .. "] "
      end
    },
    -- Обычный маркированный список: "- текст" или "* текст"
    {
      pattern = "^%s*([-*])%s+(.*)$",
      handler = function(bullet)
        return indent .. bullet .. " "
      end
    },
    -- Нумерованный список: "1. текст"
    {
      pattern = "^%s*(%d+)%.%s+(.*)$",
      handler = function(num)
        local next_num = tonumber(num) + 1
        return indent .. tostring(next_num) .. ". "
      end
    }
  }

  for _, p in ipairs(patterns) do
    local match = { line:match(p.pattern) }
    if #match > 0 then
      return p.handler(unpack(match))
    end
  end

  return nil -- не список
end

-- Автоматическое продолжение списков
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()

    -- INSERT MODE: Ctrl+Enter для продолжения списка
    vim.keymap.set("i", "<C-CR>", function()
      local continuation = continue_list()
      if continuation then
        -- В insert mode: перейти на новую строку и вставить продолжение
        return "<CR>" .. continuation
      else
        -- Если не список - обычный новый абзац
        return "<CR><CR>"
      end
    end, { expr = true, buffer = bufnr })

    -- NORMAL MODE: Ctrl+Enter для добавления нового элемента списка
    vim.keymap.set("n", "<C-CR>", function()
      local continuation = continue_list()
      if continuation then
        -- В normal mode: перейти на новую строку ниже и вставить продолжение
        vim.api.nvim_feedkeys("o" .. continuation, "n", false)
      else
        -- Если не список - просто новая строка
        vim.api.nvim_feedkeys("o", "n", false)
      end
    end, { buffer = bufnr })

    -- Опционально: можно оставить обычный Enter умным для списков
    vim.keymap.set("i", "<CR>", function()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2] + 1

      -- Если курсор не в конце строки
      if col <= #line then
        return "<CR>"
      end

      -- Если строка пустая или содержит только пробелы
      if line:match("^%s*$") then
        return "<CR>"
      end

      -- Проверяем, пустой ли элемент списка
      if line:match("^%s*[-*]%s+%[%s%]%s*$") or
          line:match("^%s*[-*]%s*$") or
          line:match("^%s*%d+%.%s*$") then
        -- На пустом элементе списка - выйти из списка
        return "<CR><C-u>"
      end

      -- Обычный Enter
      return "<CR>"
    end, { expr = true, buffer = bufnr })
  end
})

-- vim: ts=2 sts=2 sw=2 et
