-- Integration with Godot Editor
-- There you need to set the following values in Godot:
-- 1. Enable Use External Editor.
-- 2. Set Exec Path to the Neovim path.
-- 3. Set Exec Flags to the following line: 'server {project}/server.pipe --remote-send "<C-\><C-N>:e {file}<CR>:call cursor({line}+1,{col})<CR>"'
--  or '--server {project}/server.pipe --remote-send "<C-\><C-N>:e {file}<CR>{line}G,{col}|"'

-- paths to check for project.godot file
local paths_to_check = { '/', '/../' }
local is_godot_project = false
local godot_project_path = ''
local cwd = vim.fn.getcwd()

-- iterate over paths and check
-- print("searching for project.godot in " .. cwd)
for _, value in pairs(paths_to_check) do
  if vim.uv.fs_stat(cwd .. value .. 'project.godot') then
    is_godot_project = true
    godot_project_path = cwd .. value
    break
  end
end

-- check if server is already running in godot project path
local is_server_running = vim.uv.fs_stat(godot_project_path .. '/server.pipe')
-- start server, if not already running
if is_godot_project and not is_server_running then
  vim.fn.serverstart(godot_project_path .. '/server.pipe')
end

local function set_buffer_keymaps()
  -- создаем группу для автокоманд
  local godot_group = vim.api.nvim_create_augroup('GodotKeymaps', { clear = true })

  -- автокоманда для установки маппинга при открытии .gd файлов
  vim.api.nvim_create_autocmd('FileType', {
    group = godot_group,
    pattern = 'gdscript',
    desc = 'Setup Godot keymaps',
    callback = function()
      local prefix = 'Godot: '
      vim.keymap.set('n', '<leader>cd', function()
        vim.cmd.GodotDocs()
      end, {
        silent = true,
        buffer = true,
        desc = prefix .. 'Open docs',
      })

      vim.keymap.set('n', '<leader>cD', function()
        vim.cmd.GodotDocsBrowser()
      end, {
        silent = true,
        buffer = true,
        desc = prefix .. 'Open docs in Browser',
      })

      vim.keymap.set('n', '<leader>ct', function()
        vim.cmd.GodotSceneTree()
      end, {
        silent = true,
        buffer = true,
        desc = prefix .. 'Scene tree',
      })

      vim.keymap.set('n', '<leader>cr', function()
        vim.cmd.GodotRunCurrentScene()
      end, {
        silent = true,
        buffer = true,
        desc = prefix .. 'Run current scene',
      })
    end,
  })
end

return {
  'Mathijs-Bakker/godotdev.nvim',
  dependencies = { 'igorlfs/nvim-dap-view' },
  ft = { 'gdscript', 'tscn', 'gdshader' },
  -- cond = function()
  --   local files = vim.fn.glob('*.godot', false, true)
  --   return #files > 0
  -- end,
  init = function()
    local dap_view = require 'dap-view'
    -- Создаём фиктивный модуль dapui
    package.preload['dapui'] = function()
      return {
        setup = function() end, -- Ничего не делаем
        open = function()
          dap_view.open()
        end,
        close = function()
          dap_view.close()
        end,
      }
    end
  end,
  opts = {
    inline_hints = {
      enabled = true, -- enable Neovim inlay hints when the attached server supports them
    },
  },
  config = function(opts)
    require('godotdev').setup(opts)

    set_buffer_keymaps()
  end,
}
