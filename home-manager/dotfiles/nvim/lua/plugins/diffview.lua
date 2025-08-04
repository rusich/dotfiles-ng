vim.g.diffview_opened = false

local function FocusDiffview()
  vim.cmd 'wincmd k'
  vim.cmd 'wincmd l'
  vim.cmd 'wincmd l'
end

local function ToggleDiffview(cmd)
  if vim.g.diffview_opened == false then
    vim.cmd(cmd)
    FocusDiffview()
    vim.g.diffview_opened = cmd
  elseif vim.g.diffview_opened == cmd then
    vim.cmd 'DiffviewClose'
    vim.g.diffview_opened = false
  else
    vim.cmd 'DiffviewClose'
    vim.cmd(cmd)
    FocusDiffview()
    vim.g.diffview_opened = cmd
  end
end

local function DiffviewOpen()
  ToggleDiffview 'DiffviewOpen'
end

local function ToggleDiffviewFileHistory()
  ToggleDiffview 'DiffviewFileHistory'
end

local function ToggleDiffviewCurrentFileHistory()
  ToggleDiffview 'DiffviewFileHistory %'
end

---@type LazyPluginSpec
local spec = {
  'sindrets/diffview.nvim',
  lazy = false,
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
  },
  cmd = {
    'DiffviewOpen',
    'DiffviewClose',
    'DiffviewFileHistory',
  },
  opts = {
    view = {
      -- For more info, see ':h diffview-config-view.x.layout'.
      default = {
        -- Config for changed files, and staged files in diff views.
        layout = 'diff2_horizontal',
        winbar_info = true, -- See ':h diffview-config-view.x.winbar_info'
      },
      merge_tool = {
        -- Config for conflicted files in diff views during a merge or rebase.
        -- layout = "diff3_mixed",
        layout = 'diff3_mixed',
        disable_diagnostics = true, -- Temporarily disable diagnostics for conflict buffers while in the view.
        winbar_info = true, -- See ':h diffview-config-view.x.winbar_info'
      },
      file_history = {
        -- Config for changed files in file history views.
        layout = 'diff2_horizontal',
        winbar_info = false, -- See ':h diffview-config-view.x.winbar_info'
      },
    },
    keymaps = {
      file_panel = {
        {
          'n',
          'cc',
          function()
            vim.ui.input({ prompt = 'Commit message: ' }, function(msg)
              if not msg then
                return
              end
              local results = vim.system({ 'git', 'commit', '-m', msg }, { text = true }):wait()

              if results.code ~= 0 then
                vim.notify(
                  'Commit failed with the message: \n' .. vim.trim(results.stdout .. '\n' .. results.stderr),
                  vim.log.levels.ERROR,
                  { title = 'Commit' }
                )
              else
                vim.notify(results.stdout, vim.log.levels.INFO, { title = 'Commit' })
              end
            end)
          end,
        },
      },
    },
  },
  keys = {
    { '<leader>gd', DiffviewOpen, desc = 'DiffView' },
    -- { '<leader>gf', ToggleDiffviewCurrentFileHistory, desc = 'Current file History' },
    { '<leader>gF', ToggleDiffviewFileHistory, desc = 'All files History' },
  },
}

return spec
