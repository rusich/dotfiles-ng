return {
  "bngarren/checkmate.nvim",
  ft = "markdown", -- Lazy loads for Markdown files matching patterns in 'files'
  opts = {
    -- files = { "*.md" }, -- any .md file (instead of defaults)
    --
    files = {
      "*.md",
    },
    -- checkmate.Config
    -- todo_states = {
    --   unchecked = {
    --     marker = "[ ]",
    --   },
    --   checked = {
    --     marker = "[x]",
    --   }
    -- },

    todo_count_formatter = function(completed, total)
      if total > 4 then
        local percent = completed / total * 100
        local bar_length = 10
        local filled = math.floor(bar_length * percent / 100)
        local bar = string.rep("◼︎", filled) .. string.rep("◻︎", bar_length - filled)
        return string.format("%s", bar)
      else
        return string.format("[%d/%d]", completed, total)
      end
    end
  }
}
