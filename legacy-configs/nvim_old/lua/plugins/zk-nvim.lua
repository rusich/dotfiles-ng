return {
  "zk-org/zk-nvim",
  config = function()
    vim.env.ZK_NOTEBOOK_DIR = vim.env.HOME .. "/Nextcloud/Notes/"

    require("zk").setup({
      -- Can be "telescope", "fzf", "fzf_lua", "minipick", "snacks_picker",
      -- or select" (`vim.ui.select`).
      picker = "snacks_picker",
      picker_options = {
        snacks_picker = {
          layout = {
            preset = "ivy",
          }
        },
      },

      lsp = {
        config = {
          on_attach = function(client, bufnr)
            -- Disable all capabilities except diagnostics
            client.server_capabilities.completionProvider = false
            client.server_capabilities.hoverProvider = true
            client.server_capabilities.definitionProvider = false
            client.server_capabilities.referencesProvider = false
            client.server_capabilities.codeActionProvider = false
            -- Keep diagnostics enabled (this is usually on by default)
          end
        },
        auto_attach = {
          enabled = true,
          filetypes = { "markdown" },
        },
      },

    })

    local zk = require("zk")
    local commands = require("zk.commands")

    local function make_edit_fn(defaults, picker_options)
      return function(options)
        options = vim.tbl_extend("force", defaults, options or {})
        zk.edit(options, picker_options)
      end
    end

    commands.add("ZkOrphans", make_edit_fn({ orphan = true }, { title = "Zk Orphans" }))
    commands.add("ZkRecents", make_edit_fn({ createdAfter = "2 weeks ago" }, { title = "Zk Recents" }))

    vim.keymap.set('n', '<leader>nc', function()
      local params = {
        template = "todo.md",
        insertContentAtLocation = {
          uri = "~/Nextcloud/Notes/Inbox.md",
          range = {
            start = { line = vim.fn.line('.') - 1, character = 0 },
            ['end'] = { line = vim.fn.line('.') - 1, character = 0 }
          }
        }
      }
      vim.cmd("ZkNew " .. vim.fn.shellescape(vim.fn.json_encode(params)))
    end, { desc = "Insert zk template content at cursor" })
  end
}
