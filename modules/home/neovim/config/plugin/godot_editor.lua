-- NEOVIM server configuration for integration with godot editor
-- There you need to set the following values:
-- Enable Use External Editor.
-- Set Exec Path to the Neovim path.
-- Set Exec Flags to the following line: 'server {project}/server.pipe --remote-send "<C-\><C-N>:e {file}<CR>:call cursor({line}+1,{col})<CR>"'
--  or '--server {project}/server.pipe --remote-send "<C-\><C-N>:e {file}<CR>{line}G,{col}|"'

-- paths to check for project.godot file
local paths_to_check = { '/', '/../' }
local is_godot_project = false
local godot_project_path = ''
local cwd = vim.fn.getcwd()

-- iterate over paths and check
-- print("searching for project.godot in " .. cwd)
for key, value in pairs(paths_to_check) do
  if vim.uv.fs_stat(cwd .. value .. 'project.godot') then
    is_godot_project = true
    godot_project_path = cwd .. value
    -- print("found project.godot in " .. godot_project_path)
    break
  end
end

-- check if server is already running in godot project path
local is_server_running = vim.uv.fs_stat(godot_project_path .. '/server.pipe')
-- start server, if not already running
if is_godot_project and not is_server_running then
  vim.fn.serverstart(godot_project_path .. '/server.pipe')
end


-- LSP CONFIGURATION
-- For the best experience, I recommend running the LSP in it's own thread.
-- It can be done by setting Editor Settings > Network > Language Server >
-- Use Thread to true. This reduces the need to restart the LSP a lot.
--
-- NOTE: settings provided ther for possibly disabled lspconfig plugin

local port = os.getenv 'GDScript_Port' or '6005'
local cmd = vim.lsp.rpc.connect('127.0.0.1', tonumber(port))

---@type vim.lsp.Config
local gdscript_config = {
  cmd = cmd,
  filetypes = { 'gd', 'gdscript', 'gdscript3' },
  root_markers = { 'project.godot', '.git' },
}

vim.lsp.config("gdscript", gdscript_config)
vim.lsp.enable("gdscript")

-- TODO: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#gdshader_lsp
