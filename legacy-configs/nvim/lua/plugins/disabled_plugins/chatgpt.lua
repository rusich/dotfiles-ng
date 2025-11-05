-- Effortless Natural Language Generation with OpenAI's ChatGPT API

-- Lazy
---@type LazyPluginSpec
local spec = {
  'jackMort/ChatGPT.nvim',
  config = function()
    -- local model = "gpt-3.5-turbo-1106" -- proxyapi
    -- local model = "gpt-4-0613" -- slow
    -- local gpt_max_tokens = 4096 -- gpt-4-0613
    -- local model = 'gpt-3.5-turbo' -- GOOD and FAST
    -- local model = 'gpt-4o'
    -- local model = 'claude-3.5-sonnet'
    -- local model = 'deepseek-chat'
    -- local gpt_max_tokens = 2048 -- gpt-3.5.turbo-16k-0613
    local model = 'llama-3.3-70b-versatile'

    -- local key = vim.fn.system 'secret-tool lookup short DEEPSEEK_API_KEY'
    -- local host = vim.fn.system 'secret-tool lookup short DEEPSEEK_API_HOST'
    local key = vim.fn.system 'secret-tool lookup short GROQ_API_KEY'
    local host = vim.fn.system 'secret-tool lookup short GROQ_API_HOST'

    vim.fn.setenv('OPENAI_API_KEY', key)
    vim.fn.setenv('OPENAI_API_HOST', host)

    require('chatgpt').setup {
      popup_layout = {
        default = 'right',
      },
      openai_params = {
        model = model,
        frequency_penalty = 0,
        presence_penalty = 0,
        max_tokens = 4095,
        temperature = 0.2,
        top_p = 0.1,
        n = 1,
      },
      openai_edit_params = {
        model = model,
        frequency_penalty = 0,
        presence_penalty = 0,
        max_tokens = 4095,
        temperature = 0.2,
        top_p = 0.1,
        n = 1,
      },
    }
  end,
  dependencies = {
    'MunifTanjim/nui.nvim',
    'nvim-lua/plenary.nvim',
    -- 'nvim-telescope/telescope.nvim',
    'folke/trouble.nvim', -- optional
  },

  keys = {
    { '<leader>aC', '<cmd>ChatGPT<CR>', 'ChatGPT' },
  },
}

return spec
