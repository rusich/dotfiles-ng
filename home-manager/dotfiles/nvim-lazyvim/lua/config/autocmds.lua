-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

local autocmd = vim.api.nvim_create_autocmd
local function augroup(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

-- Persistent Folds
local save_fold = augroup("Persistent Folds")
autocmd("BufWinLeave", {
  pattern = "?*",
  callback = function()
    vim.cmd.mkview({ mods = { emsg_silent = true } })
  end,
  group = save_fold,
})

autocmd("BufWinEnter", {
  pattern = "?*",
  callback = function()
    -- vim.opt.foldmethod = "manual"
    vim.cmd.loadview({ mods = { emsg_silent = true } })
  end,
  group = save_fold,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q_extended"),
  pattern = {
    "chatgpt-input",
    "toggleterm",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})
