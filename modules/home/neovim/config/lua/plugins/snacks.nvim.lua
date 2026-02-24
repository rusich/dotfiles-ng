-- 🍿 A colleceion of QoL plugins for Neovim

---@type LazyPluginSpec
local spec = {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    toggle = {
      which_key = true, -- integrate with which-key to show enabled/disabled icons and colors
    },
    picker = {
      enabled = true,
      -- set ivy to default
      layout = {
        preset = "ivy",
      }
    },
    image = {
      debug = {
        convert = false,   -- Shows LaTeX conversion commands
        request = false,   -- Shows image display requests
        placement = false, -- Shows image placement operations
      },
      enabled = true,
      math = {
        enabled = true,
        latex = {
          font_size = "Small",
          tpl = [[
      \documentclass[preview,border=0pt,varwidth,12pt]{standalone}
      \usepackage{${packages}}
      \begin{document}
      ${header}
      { \${font_size} \selectfont
        \color[HTML]{${color}}
      ${content}}
      \end{document}]]
        }
      },
      convert = {
        magick = {
          math = { "-density", 192, "{src}[{page}]", "-trim", "-transparent", "white" }
        }
      }
    },
    bigfile = { enabled = true },
    dashboard = {
      enabled = false,
      example = 'compact_files',
      preset = {
        header = [[
███  ██ ▄▄▄▄▄  ▄▄▄  ██  ██ ▄▄ ▄▄   ▄▄
██ ▀▄██ ██▄▄  ██▀██ ██▄▄██ ██ ██▀▄▀██
██   ██ ██▄▄▄ ▀███▀  ▀██▀  ██ ██   ██
]],
        keys = {
          { icon = ' ', key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
          { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
          { icon = ' ', key = 'g', desc = 'Find Text', action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = ' ', key = 'r', desc = 'Recent Files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = ' ', key = 'c', desc = 'Config', action = ":lua Snacks.picker('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = ' ', key = 's', desc = 'Restore Session', action = ':lua MiniSessions.select()' },
          { icon = '󰒲 ', key = 'L', desc = 'Lazy', action = ':Lazy', enabled = package.loaded.lazy ~= nil },
          { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
        },
      },
    },
    debug = { enabled = true },
    git = { enabled = true },
    input = {
      enabled = true,
      win = {
        relative = 'cursor',
        -- wo = {
        --   winhighlight = 'NormalFloat:Normal',
        -- },
        keys = {
          i_tab = { '<tab>', { 'cmp_select_next', 'cmp' }, mode = 'i', expr = true },
          i_ctrl_n = { '<c-n>', { 'cmp_select_next', 'cmp' }, mode = 'i', expr = true },
          i_ctrl_space = { '<c-space>', { 'cmp_select_next', 'cmp' }, mode = 'i', expr = true },
        },
      },
    },
    notifier = { enabled = true, timeout = 5000 },
    statuscolumn = {
      enabled = true,
      folds = {
        open = true,
        git_hl = true,
      },
    },
    quickfile = { enabled = true },
  },

  keys = {
    {
      '<leader>z',
      function()
        Snacks.zen()
      end,
      desc = 'Zen Mode',
    },
    {
      '<leader>Z',
      function()
        Snacks.zen.zoom()
      end,
      desc = 'Zen Zoom',
    },
    {
      '<leader>un',
      function()
        Snacks.notifier.show_history()
      end,
      desc = 'Notification History',
    },
    {
      '<leader>cR',
      function()
        Snacks.rename.rename_file()
      end,
      desc = 'Rename File',
    },
    {
      '<leader>gB',
      function()
        Snacks.picker.git_log_line()
      end,
      desc = 'Git Blame Line',
    },
    {
      '<leader>gf',
      function()
        Snacks.lazygit.log_file()
      end,
      desc = 'Lazygit Current File History',
    },
    {
      '<leader>gg',
      function()
        Snacks.lazygit()
      end,
      desc = 'Open Lazygit',
    },
    {
      '<leader>gl',
      function()
        Snacks.lazygit.log()
      end,
      desc = 'Lazygit Log (cwd)',
    },
    {
      '<c-`>',
      function()
        Snacks.terminal()
      end,
      mode = { 'n', 'v', 'i', 't' },
      desc = 'Toggle Terminal',
    },
    {
      '<leader>D',
      function()
        -- if Snacks.dashboard.status.opened == false then
        Snacks.dashboard.open { example = 'compact_files' }
        -- end
      end,
      mode = { 'n' },
      desc = 'Open Dashboard',
    },
    -- Picker
    --
    -- {lua Snacks.picker('files', {cwd = vim.fn.stdpath('config')})" },
    {
      '<leader>s.',
      function()
        Snacks.picker('files', { cwd = vim.fn.expand '~/.config/' })
      end,
      desc = 'Dotfiles',
    },
    {
      '<leader>s?',
      function()
        Snacks.picker()
      end,
      desc = 'Builtin Pickers',
    },
    {
      '<leader><space>',
      function()
        Snacks.picker.smart()
      end,
      desc = 'Smart Find Files',
    },
    {
      '<leader>,',
      function()
        Snacks.picker.buffers()
      end,
      desc = 'Buffers',
    },
    {
      '<leader>/',
      function()
        Snacks.picker.grep()
      end,
      desc = 'Grep',
    },
    {
      '<leader>:',
      function()
        Snacks.picker.command_history()
      end,
      desc = 'Command History',
    },
    -- find
    {
      '<leader>fb',
      function()
        Snacks.picker.buffers()
      end,
      desc = 'Buffers',
    },
    {
      '<leader>fc',
      function()
        Snacks.picker.files { cwd = vim.fn.stdpath 'config' }
      end,
      desc = 'Find Config File',
    },
    {
      '<leader>ff',
      function()
        Snacks.picker.files()
      end,
      desc = 'Find Files',
    },
    {
      '<leader>fg',
      function()
        Snacks.picker.git_files()
      end,
      desc = 'Find Git Files',
    },
    {
      '<leader>fp',
      function()
        Snacks.picker.projects()
      end,
      desc = 'Projects',
    },
    {
      '<leader>fr',
      function()
        Snacks.picker.recent()
      end,
      desc = 'Recent',
    },
    -- git
    {
      '<leader>gb',
      function()
        Snacks.picker.git_branches()
      end,
      desc = 'Git Branches',
    },
    {
      '<leader>gl',
      function()
        Snacks.picker.git_log()
      end,
      desc = 'Git Log',
    },
    {
      '<leader>gL',
      function()
        Snacks.picker.git_log_line()
      end,
      desc = 'Git Log Line',
    },
    {
      '<leader>gs',
      function()
        Snacks.picker.git_status()
      end,
      desc = 'Git Status',
    },
    {
      '<leader>gS',
      function()
        Snacks.picker.git_stash()
      end,
      desc = 'Git Stash',
    },
    {
      '<leader>gd',
      function()
        Snacks.picker.git_diff()
      end,
      desc = 'Git Diff (Hunks)',
    },
    {
      '<leader>gf',
      function()
        Snacks.picker.git_log_file()
      end,
      desc = 'Git Log File',
    },
    -- Grep
    {
      '<leader>sb',
      function()
        Snacks.picker.lines()
      end,
      desc = 'Buffer Lines',
    },
    {
      '<leader>sB',
      function()
        Snacks.picker.grep_buffers()
      end,
      desc = 'Grep Open Buffers',
    },
    {
      '<leader>sg',
      function()
        Snacks.picker.grep()
      end,
      desc = 'Grep',
    },
    {
      '<leader>sw',
      function()
        Snacks.picker.grep_word()
      end,
      desc = 'Visual selection or word',
      mode = { 'n', 'x' },
    },
    -- search
    {
      '<leader>s"',
      function()
        Snacks.picker.registers()
      end,
      desc = 'Registers',
    },
    {
      '<leader>s/',
      function()
        Snacks.picker.search_history()
      end,
      desc = 'Search History',
    },
    {
      '<leader>sa',
      function()
        Snacks.picker.autocmds()
      end,
      desc = 'Autocmds',
    },
    {
      '<leader>sb',
      function()
        Snacks.picker.lines()
      end,
      desc = 'Buffer Lines',
    },
    {
      '<leader>sc',
      function()
        Snacks.picker.command_history()
      end,
      desc = 'Command History',
    },
    {
      '<leader>sC',
      function()
        Snacks.picker.commands()
      end,
      desc = 'Commands',
    },
    {
      '<leader>sd',
      function()
        Snacks.picker.diagnostics()
      end,
      desc = 'Diagnostics',
    },
    {
      '<leader>sD',
      function()
        Snacks.picker.diagnostics_buffer()
      end,
      desc = 'Buffer Diagnostics',
    },
    {
      '<leader>sh',
      function()
        Snacks.picker.help()
      end,
      desc = 'Help Pages',
    },
    {
      '<leader>sH',
      function()
        Snacks.picker.highlights()
      end,
      desc = 'Highlights',
    },
    {
      '<leader>si',
      function()
        Snacks.picker.icons()
      end,
      desc = 'Icons',
    },
    {
      '<leader>sj',
      function()
        Snacks.picker.jumps()
      end,
      desc = 'Jumps',
    },
    {
      '<leader>sk',
      function()
        Snacks.picker.keymaps()
      end,
      desc = 'Keymaps',
    },
    {
      '<leader>sl',
      function()
        Snacks.picker.loclist()
      end,
      desc = 'Location List',
    },
    {
      '<leader>sm',
      function()
        Snacks.picker.marks()
      end,
      desc = 'Marks',
    },
    {
      '<leader>sM',
      function()
        Snacks.picker.man()
      end,
      desc = 'Man Pages',
    },
    {
      '<leader>sp',
      function()
        Snacks.picker.lazy()
      end,
      desc = 'Search for Plugin Spec',
    },
    {
      '<leader>sq',
      function()
        Snacks.picker.qflist()
      end,
      desc = 'Quickfix List',
    },
    {
      '<leader>sR',
      function()
        Snacks.picker.resume()
      end,
      desc = 'Resume',
    },
    {
      '<leader>su',
      function()
        Snacks.picker.undo()
      end,
      desc = 'Undo History',
    },
    {
      '<leader>uC',
      function()
        Snacks.picker.colorschemes()
      end,
      desc = 'Colorschemes',
    },
  },
}

return spec
