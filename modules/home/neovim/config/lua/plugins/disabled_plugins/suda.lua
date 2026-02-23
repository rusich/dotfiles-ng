-- plugin to read or write files with sudo command.

---@type LazyPluginSpec
local spec = {
  'lambdalisue/suda.vim',
  cmd = { 'SudaRead', 'SudaWrite' },
}

return spec
