-- Debug Adapter Protocol client implementation for Neovim

---Starts debugging session for the current file
---Automatically handles Flutter/Dart projects by calling FlutterDebug
---before continuing with standard DAP debugging
local function dap_continue()
  local dap = require 'dap'

  if vim.bo.filetype == 'dart' and dap.session() == nil then
    vim.cmd 'FlutterDebug'
    vim.cmd 'FlutterOutlineToggle'
    vim.cmd 'FlutterOutlineOpen'
    return
  end

  dap.continue()
end

local function build_and_get_path(build_cmd)
  return function()
    print('> ' .. build_cmd)

    ---@diagnostic disable-next-line: unused-local
    local output = vim.fn.system(build_cmd)

    if vim.v.shell_error ~= 0 then
      vim.notify('Build failed!\n' .. output, vim.log.levels.ERROR)
      return nil
    end
    vim.notify 'Build success!'

    -- Return proper path to executable
    if build_cmd == 'cargo build' then
      return '${workspaceFolder}/target/debug/${workspaceFolderBasename}'
    elseif build_cmd == 'make' then
      return '${workspaceFolder}/${workspaceFolderBasename}'
    elseif build_cmd == 'dotnet build -c Debug' then
      return '${workspaceFolder}/bin/Debug/net10.0/${workspaceFolderBasename}.dll'
    end
  end
end

local function run_in_terminal()
  local ft = vim.bo.filetype

  local cmd = 'lua Snacks.terminal.open("'
  if ft == 'lua' then
    cmd = cmd .. 'lua %'
  elseif ft == 'cs' then
    cmd = cmd .. 'dotnet run'
  elseif ft == 'rust' then
    cmd = cmd .. 'cargo run'
  else
    cmd = cmd .. vim.fn.expand '%:p'
  end

  vim.cmd(cmd .. '&&echo Exited. Press any key to close. && read -n1")')

  vim.defer_fn(function()
    vim.cmd 'startinsert'
  end, 100)
  vim.defer_fn(function()
    vim.cmd 'stopinsert'
  end, 300)
end

local function setup_dap_highlights()
  vim.api.nvim_set_hl(0, 'DapBreakpoint', { bg = '#33111a' })
  vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef', bg = '#31353f' })
  vim.api.nvim_set_hl(0, 'DapStoppedBg', { bg = '#31353f' })
  vim.api.nvim_set_hl(0, 'DapStoppedFg', { fg = '#98c379', bg = '#31353f' })

  vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
  vim.fn.sign_define('DapBreakpointCondition', { text = '', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
  vim.fn.sign_define('DapBreakpointRejected', { text = '', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
  vim.fn.sign_define('DapLogPoint', { text = '', texthl = 'DapLogPoint', linehl = 'DapLogPoint', numhl = 'DapLogPoint' })
  vim.fn.sign_define('DapStopped', { text = '➟', texthl = 'DapStoppedFg', linehl = 'DapStoppedBg', numhl = 'DapStoppedBg' })
end

local spec = {
  'mfussenegger/nvim-dap',
  event = 'LspAttach',
  dependencies = {
    { 'theHamsta/nvim-dap-virtual-text', config = true },
    -- Installs the debug adapters for you
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    -- 'leoluz/nvim-dap-go',
    -- 'mfussenegger/nvim-dap-python',
    -- 'jbyuki/one-small-step-for-vimkind',

    -- Creates a beautiful debugger UI
    -- { 'rcarriga/nvim-dap-ui', dependencies = { 'nvim-neotest/nvim-nio' }, config = true, lazy = true },
    {
      'igorlfs/nvim-dap-view',
      -- let the plugin lazy load itself
      version = '1.*',
      ---@module 'dap-view'
      ---@type dapview.Config
      opts = {
        winbar = {
          sections = { 'console', 'watches', 'scopes', 'exceptions', 'breakpoints', 'threads', 'repl', 'disassembly' },
          default_section = 'console',
          controls = { enabled = false },
        },
      },
    },
    -- Disassembly support
    { url = 'https://codeberg.org/Jorenar/nvim-dap-disasm.git', dependencies = 'igorlfs/nvim-dap-view', config = true },
  },

  keys = {
    {
      '<leader>dB',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Breakpoint Condition (F9)',
    },
    {
      '<F9>',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Debug: Breakpoint Condition',
    },
    {
      '<leader>db',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Toggle Breakpoint (F8)',
    },
    {
      '<F8>',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<leader>dc',
      function()
        dap_continue()
      end,
      desc = 'Start/Continue (F5)',
    },
    {
      '<F5>',
      function()
        dap_continue()
      end,
      desc = 'Debug: Start/Continue',
    },

    {
      '<leader>da',
      function()
        local dap = require 'dap'

        local args = {}
        local str = vim.fn.input 'Args: '
        str:gsub('.+', function(c)
          table.insert(args, c)
        end)
        print(vim.inspect(args))
        for _, configs in pairs(dap.configurations) do
          for _, config in ipairs(configs) do
            config.args = args
          end
        end
        dap.continue()
      end,
      desc = 'Debug: Start with args',
    },
    {
      '<leader>dC',
      function()
        require('dap').run_to_cursor()
      end,
      desc = 'Run to Cursor (F7)',
    },
    {
      '<F7>',
      function()
        require('dap').run_to_cursor()
      end,
      desc = 'Debug: Run to Cursor',
    },
    {
      '<leader>dg',
      function()
        require('dap').goto_()
      end,
      desc = 'Go to line (no execute)',
    },
    {
      '<leader>di',
      function()
        require('dap').step_into()
      end,
      desc = 'Step Into (F11)',
    },
    {
      '<F11>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<leader>dj',
      function()
        require('dap').down()
      end,
      desc = 'Stack Down',
    },
    {
      '<leader>dk',
      function()
        require('dap').up()
      end,
      desc = 'Stack Up',
    },
    {
      '<leader>dl',
      function()
        require('dap').run_last()
      end,
      desc = 'Run Last',
    },
    {
      '<leader>dO',
      function()
        require('dap').step_out()
      end,
      desc = 'Step Out (F12)',
    },
    {
      '<F12>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>do',
      function()
        require('dap').step_over()
      end,
      desc = 'Step Over (F10)',
    },
    {
      '<F10>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<leader>dp',
      function()
        require('dap').pause()
      end,
      desc = 'Pause',
    },
    {
      '<leader>dr',
      '<cmd>DapViewJump repl<cr>',
      desc = 'Open REPL',
    },
    {
      '<leader>ds',
      function()
        require('dap').session()
      end,
      desc = 'Session',
    },
    {
      '<leader>dt',
      function()
        require('dap').terminate()
      end,
      desc = 'Terminate (F6)',
    },
    {
      '<F6>',
      function()
        require('dap').terminate()
      end,
      desc = 'Debug: Terminate',
    },
    {
      '<leader>dw',
      '<cmd>DapViewWatch<cr>',
      desc = 'Add to watchlist',
      mode = { 'n', 'v' },
    },
    {
      -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
      '<leader>du',
      '<cmd>DapViewToggle<cr>',
      desc = 'Toggle UI',
    },
    {
      '<leader>dE',
      run_in_terminal,
      desc = 'Run in terminal (F4)',
    },
    {
      '<F4>',
      run_in_terminal,
      desc = 'Run in terminal',
    },

    {
      '<leader>de',
      function()
        require('dap.ui.widgets').hover()
      end,
      desc = 'Eval (F3)',
      mode = { 'n', 'v' },
    },
    {
      '<F3>',
      function()
        require('dap.ui.widgets').hover()
      end,
      desc = 'DAP Eval',
      mode = { 'n', 'v' },
    },
  },
  config = function()
    local dap = require 'dap'

    require('mason-nvim-dap').setup {
      automatic_installation = true,

      ensure_installed = {
        'coreclr',
        'codelldb',
        'python',
      },

      handlers = {
        function(config)
          -- all sources with no handler get passed here
          -- Keep original functionality
          require('mason-nvim-dap').default_setup(config)
        end,
        codelldb = function()
          dap.adapters.codelldb = {
            type = 'server',
            port = '${port}',
            executable = {
              command = vim.fn.exepath 'codelldb',
              args = { '--port', '${port}' },
            },
          }
          dap.configurations.cpp = {
            {
              name = 'C++ Debug',
              type = 'codelldb',
              adapters = { 'codelldb' },
              request = 'launch',
              -- via Overseer
              -- program = '${workspaceFolder}/${workspaceFolderBasename}',
              -- preLaunchTask = 'Compile',
              -- postLaunchTask = 'Clean',
              -- expressions = 'native',
              program = build_and_get_path 'make',
              cwd = '${workspaceFolder}',
              stopOnEntry = false,
            },
          }
          dap.configurations.rust = {
            {
              name = 'Rust debug',
              type = 'codelldb',
              adapters = { 'codelldb' },
              request = 'launch',
              program = build_and_get_path 'cargo build',
              cwd = '${workspaceFolder}',
              stopOnEntry = false,
              initCommands = function()
                -- Find out where to look for the pretty printer Python module
                local rustc_sysroot = vim.fn.trim(vim.fn.system 'rustc --print sysroot')

                local script_import = 'command script import "' .. rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py"'
                local commands_file = rustc_sysroot .. '/lib/rustlib/etc/lldb_commands'

                local commands = {}
                local file = io.open(commands_file, 'r')
                if file then
                  for line in file:lines() do
                    table.insert(commands, line)
                  end
                  file:close()
                end
                table.insert(commands, 1, script_import)

                return commands
              end,
            },
          }
        end,
        coreclr = function()
          dap.configurations.cs = {
            {
              type = 'coreclr',
              name = 'NetCoreDbg: Launch My',
              request = 'launch',
              program = build_and_get_path 'dotnet build -c Debug',
              -- stopOnEntry = false,
            },
          }
          dap.adapters.coreclr = {
            type = 'executable',
            command = vim.fn.exepath 'netcoredbg',
            args = { '--interpreter=vscode' },
          }
        end,
      },
    }

    -- CUSTOM DAP ADAPTERS

    -- Godot4
    dap.adapters.godot = {
      type = 'server',
      host = '127.0.0.1',
      port = '6006',
      debugServer = '6007',
    }
    dap.configurations.gdscript = {
      {
        type = 'godot',
        request = 'launch',
        name = 'Launch scene',
        -- project = "${workspaceFolder}", -- попробуйте явный путь
        -- project = "/home/rusich/Nextcloud/Devel/tutorials/Godot/first-game", -- попробуйте явный путь
        -- project = vim.fn.getcwd(),
        project = function()
          local current_file = vim.fn.expand '%:p'
          if current_file == '' then
            current_file = vim.fn.getcwd()
          end

          local dir = vim.fn.fnamemodify(current_file, ':h')
          while dir ~= '/' do
            local project_file = dir .. '/project.godot'
            if vim.fn.filereadable(project_file) == 1 then
              return dir
            end
            dir = vim.fn.fnamemodify(dir, ':h')
          end
          return vim.fn.getcwd()
        end,
        launch_scene = true,
      },
    }

    -- LUA
    dap.configurations.lua = {
      {
        name = 'Current file (local-lua-dbg, nlua)',
        type = 'local-lua',
        request = 'launch',
        cwd = '${workspaceFolder}',
        program = {
          lua = 'nlua',
          file = '${file}',
        },
        verbose = true,
        args = {},
      },
    }
    dap.adapters['local-lua'] = {
      type = 'executable',
      command = 'node',
      args = {
        vim.fn.expand '$HOME/.local/share/nvim/mason/packages/local-lua-debugger-vscode/extension/extension/debugAdapter.js',
      },
      enrich_config = function(config, on_config)
        if not config['extensionPath'] then
          local c = vim.deepcopy(config)
          -- 💀 If this is missing or wrong you'll see
          -- "module 'lldebugger' not found" errors in the dap-repl when trying to launch a debug session
          c.extensionPath = vim.fn.expand '$HOME/.local/share/nvim/mason/packages/local-lua-debugger-vscode/extension/', on_config(c)
        else
          on_config(config)
        end
      end,
    }

    setup_dap_highlights()

    -- Dap View setup
    local dapview = require 'dap-view'
    dap.listeners.after.event_initialized['dapui_config'] = dapview.open
    dap.listeners.after.disconnect['dapui_config'] = dapview.close
    dap.listeners.before.event_terminated['dapui_config'] = dapview.close
    dap.listeners.before.event_exited['dapui_config'] = dapview.close
  end,
}

return spec
