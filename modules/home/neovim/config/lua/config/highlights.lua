---@diagnostic disable-next-line: unused-function
local function hl(group, properties)
  vim.api.nvim_set_hl(0, group, properties)
end

local utils = require 'utils'

-- Ling RenderMarkdownCode to none
hl('RenderMarkdownCode', { bg = utils.color.get_hl_color('NormalFloat', 'bg') })
