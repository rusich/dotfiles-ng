-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- local Util = require("lazyvim.util")
local map = vim.keymap.set
local unmap = vim.keymap.del

map("n", "<C-q>", "<cmd>qa!<cr>", { desc = "Force quit" })

-- floating terminal
-- local lazyterm = function()
--   Util.terminal(nil, { cwd = Util.root() })
-- end
unmap("n", "<C-/>")
unmap("t", "<C-/>")
-- map("n", "<c-'>", lazyterm, { desc = "Terminal (root dir)" })
map(
  "n",
  "<c-'>",
  "<cmd>ToggleTerm direction=horizontal size=20 go_back=0 start_in_insert=true<cr>",
  { desc = "Terminal (root dir)" }
)
map("t", "<C-'>", "<cmd>close<cr>", { desc = "Hide Terminal" })

-- comment
map("n", "<c-/>", "gcc", { desc = "Comment current line", remap = true })
map("v", "<c-/>", "gc", { desc = "Comment selection", remap = true })

-- window management
map("n", "<C-c>", function()
  local function close_window()
    vim.api.nvim_win_close(0, false)
  end

  if pcall(cloce_window) ~= true then
    local bufs = vim.fn.getbufinfo({ buflisted = true })
    vim.api.nvim_buf_delete(0, {})

    if not bufs[2] then
      vim.cmd("Dashboard")
    end
  end
end, { desc = "Close window/buffer" })

unmap("n", "<leader>-")
unmap("n", "<leader>|")
map("n", "-", "<C-W>s", { desc = "Split window below", remap = true })
map("n", "\\", "<C-W>v", { desc = "Split window right", remap = true })

map(
  "n",
  "<M-K>",
  -- "<esc><cmd>lua vim.lsp.buf.hover()<cr><cmd>sleep 100m<cr><C-W>w<C-W>v<cmd>vert res 60<cr><C-W>h",
  "<esc><cmd>lua vim.lsp.buf.hover()<cr><cmd>sleep 100m<cr><C-W>w<C-W>v<cmd>vert res 60<cr>",
  { desc = "Hover doc to vertical split" }
)

map("n", "<leader>cL", vim.lsp.codelens.run, { desc = "Run CodeLens" })

-- Git

map("n", "<leader>gb", "<cmd>Telescope git_branches<cr>", { desc = "Branches" })
map("n", "<leader>gS", "<cmd>Telescope git_stash<cr>", { desc = "Stash" })
map("n", "<leader>gC", "<cmd>Telescope git_bcommits<cr>", { desc = "Buffer commits" })
map("n", "<leader>gc", "<cmd>Telescope git_commits<cr>", { desc = "Commits" })

-- Git

local function DiffviewToggle()
  if vim.g.diffview_opened == false then
    vim.cmd("DiffviewOpen")
    vim.g.diffview_opened = true
  else
    vim.cmd("DiffviewClose")
    vim.g.diffview_opened = false
  end
end

map("n", "<leader>gd", DiffviewToggle, { desc = "DiffView" })
map("n", "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", { desc = "File History" })
map("n", "<leader>gF", "<cmd>DiffviewFileHistory<cr>", { desc = "All Files History" })
map("n", "<leader>gl", "<cmd>Flogsplit<cr>", { desc = "Log" })
