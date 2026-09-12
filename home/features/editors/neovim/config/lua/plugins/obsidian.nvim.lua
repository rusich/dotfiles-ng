return {
  'obsidian-nvim/obsidian.nvim',
  version = '*', -- recommended, use latest release instead of latest commit
  -- version = "3.14.7", -- Blink completion work!
  lazy = true,
  ft = 'markdown',
  cmd = 'Obsidian',
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    legacy_commands = false, -- this will be removed in the next major release
    note_id_func = function(title)
      return title
    end,

    frontmatter = {
      enabled = function(fname)
        return fname:match '^templates/' == nil -- and fname:match("daily/") == nil
      end,
      sort = { 'title', 'created', 'updated', 'aliases', 'tags' },
      func = function(note)
        -- Берем существующие метаданные или создаем новые
        local frontmatter = note.frontmatter(note) or {}
        local now = os.date '%Y-%m-%d %H:%M'
        local out = {
          title = note.id,
          updated = now,
          created = frontmatter.created or now,
        }

        -- Копируем все существующие поля
        for k, v in pairs(frontmatter) do
          -- Пропускаем поля, которые будем обрабатывать отдельно
          if k ~= 'id' and k ~= 'title' and k ~= 'tags' and k ~= 'updated' and k ~= 'aliases' then
            out[k] = v
          end
        end

        for i, v in ipairs(frontmatter.aliases) do
          if v == note.id then
            table.remove(frontmatter.aliases, i)
          end
        end

        if #frontmatter.aliases > 0 then
          out.aliases = frontmatter.aliases
        end

        if frontmatter.tags and #frontmatter.tags > 0 then
          out.tags = frontmatter.tags
        end

        return out
      end,
    },
    workspaces = {
      {
        name = 'default',
        path = '~/Nextcloud/Notes/',
      },
    },
    picker = {
      name = 'snacks.picker',
    },
    -- Obsidian hardcodes `layout.preset = "default"` in its snacks `select`,
    -- что перекрывает глобальный Ivy-лейаут из snacks.nvim. Патчим итоговый
    -- pick_opts, чтобы obsidian использовал предпочтительный лейаут (Ivy).
    callbacks = {
      post_setup = function(_)
        local snacks_picker = require 'obsidian.picker.snacks'
        local orig_select = snacks_picker.select
        local snacks_pick = require('snacks.picker').pick

        snacks_picker.select = function(values, opts, on_choice)
          local orig_pick = require('snacks.picker').pick
          require('snacks.picker').pick = function(pick_opts, ...)
            if type(pick_opts) == 'table' and pick_opts.layout then
              pick_opts.layout.preset = nil
            end
            return orig_pick(pick_opts, ...)
          end
          local ok, res = pcall(orig_select, values, opts, on_choice)
          require('snacks.picker').pick = orig_pick
          if not ok then
            error(res)
          end
          return res
        end
      end,
    },
    templates = {
      folder = 'templates',
    },
    ui = {
      enable = false,
    },
    attachments = {
      folder = '/media',
      img_text_func = function(path)
        local name = vim.fs.basename(tostring(path))
        local encoded_name = require('obsidian.util').urlencode(name)
        return string.format('![%s](%s)', name, encoded_name)
      end,
      img_name_func = function()
        local name = 'image-' .. os.time()
        return name
      end,
    },
    checkbox = {
      enabled = true,
      create_new = false,
      order = { ' ', 'x', '-', '/' },
    },
    daily_notes = {
      folder = 'daily',
      workdays_only = false,
      default_tags = { 'daily-note' },
    },
  },
}
