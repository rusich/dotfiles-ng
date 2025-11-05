local M = {}

M.color = {
  get_hl_color = function(group, attr)
    return vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(group)), attr)
  end,

  get_highlight = function(name)
    return vim.api.nvim_get_hl(0, { name = name, link = false, create = false })
  end,
}

return M
