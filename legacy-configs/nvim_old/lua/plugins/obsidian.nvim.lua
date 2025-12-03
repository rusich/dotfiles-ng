return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = false,
  -- ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  keys = {
    { '<leader>nf', "<cmd>Obsidian quick_switch<cr>", desc = 'Find (or create)' },
    { '<leader>fn', "<cmd>Obsidian quick_switch<cr>", desc = 'Notes' },
    { '<leader>n/', "<cmd>Obsidian search<cr>",       desc = 'Grep' },
    { '<leader>nl', "<cmd>Obsidian links<cr>",        desc = 'Show links' },
    { '<leader>nb', "<cmd>Obsidian backlinks<cr>",    desc = 'Show backlinks' },
  },
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    legacy_commands = false, -- this will be removed in the next major release
    note_id_func = function(title)
      return title
    end,
    frontmatter = {
      sort = { "title", "created", "updated", "aliases", "tags" },
      func = function(note)
        -- Берем существующие метаданные или создаем новые
        local existing = note.frontmatter(note) or {}
        local now = os.date("%Y-%m-%d %H:%M")
        local out = {
          title = note.title,
          updated = now,
          created = existing.created or now
        }

        -- Копируем все существующие поля
        for k, v in pairs(existing) do
          -- Пропускаем поля, которые будем обрабатывать отдельно
          if k ~= "id" and k ~= "title" and k ~= "tags" and k ~= "aliases" and k ~= "updated" then
            out[k] = v
          end
        end

        if note.tags and #note.tags > 0 then out.tags = note.tags end
        if note.aliases and #note.aliases > 0 then out.aliases = note.aliases end

        return out
      end
    },
    workspaces = {
      {
        name = "default",
        path = "~/Nextcloud/Notes/",
      },
    },
    picker = {
      name = "telescope.nvim",
      -- name = "snacks.pick",
      -- layout = { preset = "ivy" },

    },
    -- see below for full list of options 👇
    ui = {
      enable = false,
    },
    attachments = {
      img_folder = "/media",
      img_text_func = function(path)
        local name = vim.fs.basename(tostring(path))
        local encoded_name = require("obsidian.util").urlencode(name)
        return string.format("![%s](%s)", name, encoded_name)
      end,
      img_name_func = function()
        local name = "image-" .. os.time()
        return name
      end
    },
    checkbox = {
      enabled = true,
      create_new = false,
      order = { " ", "x", "-", "/" },
    }
  },
}
