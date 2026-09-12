-- function _G.P(v)
--   print(vim.inspect(v))
-- end
--
-- function _G.RELOAD(...)
--   return require('plenary.reload').reload_module(...)
-- end
--
-- function _G.R(name)
--   RELOAD(name)
--   return require(name)
-- end
_G.dd = function(...)
  Snacks.debug.inspect(...)
end
_G.bt = function()
  Snacks.debug.backtrace()
end
vim.print = _G.dd
