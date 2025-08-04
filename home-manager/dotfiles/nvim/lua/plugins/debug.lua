-- Debug Adapter Protocol client implementation for Neovim

---Starts debugging session for the current file
---Automatically handles Flutter/Dart projects by calling FlutterDebug
---before continuing with standard DAP debugging
local function continue_debugging()
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
      return '${workspaceFolder}/bin/Debug/net9.0/${workspaceFolderBasename}.dll'
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

local function setup_dap_hilights()
  -- vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#ffffff", bg = "#4a1717" })
  vim.api.nvim_set_hl(0, 'DapBreakpoint', { bg = '#33111a' })
  vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef', bg = '#31353f' })
  vim.api.nvim_set_hl(0, 'DapStoppedBg', { bg = '#31353f' })
  vim.api.nvim_set_hl(0, 'DapStoppedFg', { fg = '#98c379', bg = '#31353f' })

  vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
  vim.fn.sign_define('DapBreakpointCondition', { text = '', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
  vim.fn.sign_define('DapBreakpointRejected', { text = '', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
  vim.fn.sign_define('DapLogPoint', { text = '', texthl = 'DapLogPoint', linehl = 'DapLogPoint', numhl = 'DapLogPoint' })
  vim.fn.sign_define('DapStopped', { text = '', texthl = 'DapStoppedFg', linehl = 'DapStoppedBg', numhl = 'DapStoppedBg' })
end

---@type LazyPluginSpec
local spec = {
  'mfussenegger/nvim-dap',
  event = 'LspAttach',
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',
    { 'theHamsta/nvim-dap-virtual-text', config = true },

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    -- 'leoluz/nvim-dap-go',
    -- 'mfussenegger/nvim-dap-python',
    -- 'jbyuki/one-small-step-for-vimkind',
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
        continue_debugging()
      end,
      desc = 'Start/Continue (F5)',
    },
    {
      '<F5>',
      function()
        continue_debugging()
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
      function()
        require('dap').repl.toggle()
      end,
      desc = 'Toggle REPL',
    },
    {
      '<leader>dI',
      "<Cmd>lua vim.ui.input('Input: ', function (input) local pid = vim.fn.system(\"pidof -s dotnet | tr -d '\\n' \"); vim.fn.system('echo ' .. input .. ' > /proc/'..pid.. '/fd/0') end)<cr>",
      desc = 'Netcoredbg STDIN',
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
      "\"wyiw<cmd>lua require('dapui').elements.watches.add(vim.fn.getreg('w'))<cr>",
      desc = 'Add to watchlist',
    },
    {
      -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
      '<leader>du',
      "<cmd>lua require('dapui').toggle()<cr>",
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
        ---@diagnostic disable-next-line: missing-fields
        require('dapui').eval(nil, { enter = true })
      end,
      desc = 'Eval (F3)',
      mode = { 'n', 'v' },
    },
    {
      '<F3>',
      function()
        ---@diagnostic disable-next-line: missing-fields
        require('dapui').eval(nil, { enter = true })
      end,
      desc = 'DAP Eval',
      mode = { 'n', 'v' },
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

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

    -- LUA
    -- dap.configurations.lua = {
    --   {
    --     type = 'nlua',
    --     request = 'attach',
    --     name = 'Attach to running Neovim instance',
    --   },
    -- }
    --
    -- dap.adapters.nlua = function(callback, config)
    --   callback { type = 'server', host = config.host or '127.0.0.1', port = config.port or 8086 }
    -- end

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

    setup_dap_hilights()

    -- Dap UI setup
    ---@diagnostic disable-next-line: missing-fields
    dapui.setup {
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      ---@diagnostic disable-next-line: missing-fields
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.after.disconnect['dapui_config'] = dapui.close
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close
  end,
}

return spec
