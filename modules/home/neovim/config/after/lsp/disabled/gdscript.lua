-- For the best experience, I recommend running the LSP in it's own thread.
-- It can be done by setting Editor Settings > Network > Language Server >
-- Use Thread to true. This reduces the need to restart the LSP a lot.
-- Godot editor integreation is writed in ../../plugin/godot_editor.lua

local port = os.getenv 'GDScript_Port' or '6005'
local cmd = vim.lsp.rpc.connect('127.0.0.1', tonumber(port))

-- TODO: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#gdshader_lsp
---@type vim.lsp.Config
return {
  cmd = cmd,
  filetypes = { 'gd', 'gdscript', 'gdscript3' },
  root_markers = { 'project.godot', '.git' },
}
