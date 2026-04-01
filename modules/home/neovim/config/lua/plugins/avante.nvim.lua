return {
  'yetone/avante.nvim',
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  -- ⚠️ must add this setting! ! !
  build = vim.fn.has 'win32' ~= 0 and 'powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false' or 'make',
  event = 'VeryLazy',
  version = false, -- Never set this value to "*"! Never!
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    provider = 'deepseek',
    -- provider = 'openai',
    providers = {
      openai = {
        api_key_name = 'cmd:secret-tool lookup short OPENAI_API_KEY',
        -- endpoint = 'https://api.deepseek.com',
        -- model = 'deepseek-coder',
      },
      deepseek = {
        __inherited_from = 'openai',
        api_key_name = 'cmd:secret-tool lookup short DEEPSEEK_API_KEY',
        endpoint = 'https://api.deepseek.com',
        model = 'deepseek-coder',
      },
      moonshot = {
        endpoint = 'https://api.moonshot.ai/v1',
        model = 'kimi-k2-0711-preview',
        timeout = 30000, -- Timeout in milliseconds
        extra_request_body = {
          temperature = 0.75,
          max_tokens = 32768,
        },
      },
    },
    -- add any opts here
    -- this file can contain specific instructions for your project
    behaviour = {
      auto_apply_diff_after_generation = false,
      enable_fastapply = false,
      auto_approve_tool_permissions = false,
      ---@type "popup" | "inline_buttons"
      confirmation_ui_style = 'popup',
    },

    instructions_file = 'avante.md',

    input = {
      provider = 'snacks',
      provider_opts = {
        -- Additional snacks.input options
        title = 'Avante Input',
        icon = ' ',
      },
    },
    -- blink.cmp
    selector = {
      --- @alias avante.SelectorProvider "native" | "fzf_lua" | "mini_pick" | "snacks" | "telescope" | fun(selector: avante.ui.Selector): nil
      --- @type avante.SelectorProvider
      provider = 'snacks',
      -- Options override for custom providers
      provider_opts = {},
    },
    -- for example
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    {
      'saghen/blink.cmp',
      lazy = true,
      dependencies = {
        'Kaiser-Yang/blink-cmp-avante',
        -- ... Other dependencies
      },
      opts = {
        sources = {
          -- Add 'avante' to the list
          default = { 'avante', 'snippets', 'lsp', 'path', 'buffer' },
          providers = {
            avante = {
              module = 'blink-cmp-avante',
              name = 'Avante',
              opts = {
                -- options for blink-cmp-avante
              },
            },
          },
        },
      },
    },
    --- The below dependencies are optional,
    -- 'nvim-mini/mini.pick', -- for file_selector provider mini.pick
    -- 'nvim-telescope/telescope.nvim', -- for file_selector provider telescope
    -- 'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
    -- 'ibhagwan/fzf-lua', -- for file_selector provider fzf
    -- 'stevearc/dressing.nvim', -- for input provider dressing
    'folke/snacks.nvim', -- for input provider snacks
    -- 'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
    -- 'zbirenbaum/copilot.lua', -- for providers='copilot'
    -- {
    --   -- support for image pasting
    --   'HakonHarnes/img-clip.nvim',
    --   event = 'VeryLazy',
    --   opts = {
    --     -- recommended settings
    --     default = {
    --       embed_image_as_base64 = false,
    --       prompt_for_file_name = false,
    --       drag_and_drop = {
    --         insert_mode = true,
    --       },
    --       -- required for Windows users
    --       use_absolute_path = true,
    --     },
    --   },
    -- },
    -- {
    --   -- Make sure to set this up properly if you have lazy=true
    --   'MeanderingProgrammer/render-markdown.nvim',
    --   opts = {
    --     file_types = { 'markdown', 'Avante' },
    --   },
    --   ft = { 'markdown', 'Avante' },
    -- },
  },
}
