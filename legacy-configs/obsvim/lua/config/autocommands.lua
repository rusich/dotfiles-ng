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

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd('FileType', {
  group = augroup 'wrap_spell',
  pattern = { 'text', 'plaintex', 'typst', 'gitcommit', 'markdown', 'org' },
  callback = function()
    vim.opt_local.wrap = true
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

-- Wh

-- vim: ts=2 sts=2 sw=2 et
