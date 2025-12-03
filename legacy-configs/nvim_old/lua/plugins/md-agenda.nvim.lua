return {
  "zenarvus/md-agenda.nvim",
  config = function()
    require("md-agenda").setup({
      --- REQUIRED ---
      agendaFiles = {
        -- "~/notes/agenda.md", "~/notes/habits.md", -- Single Files
        "~/Nextcloud/Notes/", -- Folders
      },

      --- OPTIONAL ---
      -- Number of days to display on one agenda view page.
      -- Default: 10
      agendaViewPageItems = 10,
      -- Number of days before the deadline to show a reminder for the task in the agenda view.
      -- Default: 30
      remindDeadlineInDays = 30,
      -- Number of days before the scheduled time to show a reminder for the task in the agenda view.
      -- Default: 10
      remindScheduledInDays = 10,
      -- "vertical" or "horizontal"
      -- Default: "horizontal"
      agendaViewSplitOrientation = "horizontal",

      -----

      -- Number of past days to show in the habit view.
      -- Default: 24
      habitViewPastItems = 24,
      -- Number of future days to show in the habit view.
      -- Default: 3
      habitViewFutureItems = 3,
      -- "vertical" or "horizontal"
      -- Default: "horizontal"
      habitViewSplitOrientation = "horizontal",

      -- Custom types that you can use instead of TODO.
      -- Default: {}
      -- The plugin will give an error if you use RGB colors (e.g. #ffffff)
      customTodoTypes = { PAYMENT = "magenta" }, -- A map of item type and its color

      -- "vertical" or "horizontal"
      -- Default: "horizontal"
      dashboardSplitOrientation = "horizontal",
      -- Set the dashboard view.
      dashboard = {
        { "All TODO Items", -- Group name
          {
            -- Item types, e.g., {"TODO", "INFO"}.
            -- Gets the items that match one of the given types. Ignored if empty.
            type = { "TODO", "INFO" },

            -- List of tags to filter. Use AND/OR conditions.
            -- e.g., {AND = {"tag1", "tag2"}, OR = {"tag1", "tag2"}}. Ignored if empty.
            -- tags = {},

            -- Both, deadline and scheduled filters can take the same parameters.
            -- "none", "today", "past", "nearFuture", "before-yyyy-mm-dd", "after-yyyy-mm-dd".
            -- Ignored if empty.
            -- deadline = "",
            -- scheduled = "",
          },
          -- {...}, Additional filter maps can be added in the same group.
        },
        -- {"Other Group", {...}, ...}
        -- ...
      },

      --   -- Optional: Change agenda colors.
      --   tagColor = "blue",
      --   titleColor = "yellow",
      --
      todoTypeColor = "red",
      --   habitTypeColor = "cyan",
      --   infoTypeColor = "lightgreen",
      --   dueTypeColor = "red",
      --   doneTypeColor = "green",
      --   cancelledTypeColor = "red",
      --
      --   completionColor = "lightgreen",
      --   scheduledTimeColor = "cyan",
      --   deadlineTimeColor = "red",
      --
      --   habitScheduledColor = "yellow",
      --   habitDoneColor = "green",
      --   habitProgressColor = "lightgreen",
      --   habitPastScheduledColor = "darkyellow",
      --   habitFreeTimeColor = "blue",
      --   habitNotDoneColor = "red",
      --   habitDeadlineColor = "gray",
      foldmarker = "}}},{{{",
    })

    -- Optional: Set keymaps for commands
    vim.keymap.set('n', '<A-t>', ":CheckTask<CR>")
    vim.keymap.set('n', '<A-c>', ":CancelTask<CR>")

    vim.keymap.set('n', '<A-h>', ":HabitView<CR>")
    vim.keymap.set('n', '<A-o>', ":AgendaDashboard<CR>")
    vim.keymap.set('n', '<A-a>', ":AgendaView<CR>")

    vim.keymap.set('n', '<A-s>', ":TaskScheduled<CR>")
    vim.keymap.set('n', '<A-d>', ":TaskDeadline<CR>")

    -- Optional: Set a foldmethod to use when folding the logbook entries.
    -- The plugin tries to respect to the user default.
    -- vim.o.foldmethod = "marker" -- "marker", "syntax" or "expr"
    -- vim.o.foldmethod = "expr" -- "marker", "syntax" or "expr"
    -- vim.o.foldmethod = "marker" -- "marker", "syntax" or "expr"
    -- foldexpr=getline(v:lnum)=~'^#\\+\\s'?'>'.matchend(getline(v:lnum),'^#\\+'):'='
    -- Note: When navigating to the buffers with Telescope, "syntax" and "expr" options may not work properly.
    -- Reset foldexpr to my own
    --
    -- vim.o.foldmethod = "none"

    -- restore my original foldexpr
    vim.api.nvim_create_autocmd({ 'BufReadPost', }, {
      pattern = { '*.md' },
      callback = function(ev)
        vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      end
    })

    -- Optional: Create a custom agenda view command to only show the tasks with specific tags
    vim.api.nvim_create_user_command("WorkAgenda", function()
      vim.cmd("AgendaViewWTF work companyA") -- Run the agenda view with tag filters
    end, {})
  end
}
