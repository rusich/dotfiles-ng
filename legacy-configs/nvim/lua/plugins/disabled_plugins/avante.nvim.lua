---@type LazyPluginSpec

local my_openai_endpoint = vim.fn.system 'secret-tool lookup short OPENAI_API_HOST' .. '/v1/'

local spec = {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  lazy = false,
  version = false, -- set this if you want to always pull the latest change
  opts = {
    ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
    -- provider = 'groq', -- Recommend using Claude
    -- provider = 'copilot',
    -- provider = 'my_openai', -- Recommend using Claude
    provider = 'deepseek',

    -- auto_suggestions_provider = 'my_openai',
    -- provider = 'deepseek',
    providers = {
      my_openai = {
        __inherited_from = 'openai',
        api_key_name = 'cmd:secret-tool lookup short OPENAI_API_KEY',
        endpoint = my_openai_endpoint,
        model = 'llama-3.1-405b',
      },
      deepseek = {
        __inherited_from = 'openai',
        api_key_name = 'cmd:secret-tool lookup short DEEPSEEK_API_KEY',
        endpoint = 'https://api.deepseek.com',
        model = 'deepseek-coder',
        disable_tools = true,
      },
      groq = {
        __inherited_from = 'openai',
        api_key_name = 'cmd:secret-tool lookup short GROQ_API_KEY',
        endpoint = 'https://api.groq.com/openai/v1/',
        model = 'deepseek-r1-distill-llama-70b',
        -- model = 'llama-3.3-70b-versatile',
      },
    },
    --   openai = {
    --     api_key_name = 'cmd:secret-tool lookup short DEEPSEEK_API_KEY',
    --     endpoint = vim.fn.system 'secret-tool lookup short DEEPSEEK_API_HOST' .. '/v1',
    --     model = 'deepseek-chat',
    --     temperature = 0,
    --     max_tokens = 4096,
    --   },
    -- },
    behaviour = {
      auto_suggestions = false, -- Experimental stage
      use_cwd_as_project_root = true,
    },
    mappings = {
      --- @class AvanteConflictMappings
      suggestion = {
        accept = '<M-\\>',
      },
      submit = {
        insert = '<C-CR>',
      },
    },
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = 'make',
  dependencies = {
    'stevearc/dressing.nvim',
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'HakonHarnes/img-clip.nvim',
    'MeanderingProgrammer/render-markdown.nvim',
  },
}

return spec
