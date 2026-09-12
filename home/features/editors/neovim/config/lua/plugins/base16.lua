-- base16-nvim применяет палитру noctalia (matugen.lua рендерится noctalia в
-- ~/.config/nvim/lua/matugen.lua и живёт вне git). Наличие строки "base16-nvim"
-- здесь заставляет noctalia apply.sh не создавать собственный lua/plugins/base16.lua.
return {
  'RRethy/base16-nvim',
  lazy = false,
  priority = 1000,
  enabled = vim.g.theme_engine == 'matugen',
  opts = {
    -- Сдвиг фона nvim относительно kitty, когда прозрачность выключена:
    -- +N = осветлить, -N = затемнить, 0 = выкл.
    bg_shift = -3,
  },
  config = function(_, opts)
    local shift = opts.bg_shift or 0
    local bg_groups = { 'Normal', 'NormalNC', 'NormalFloat', 'SignColumn', 'LineNr', 'CursorLineNr', 'FoldColumn' }

    if vim.g.theme_transparent or shift ~= 0 then
      local b16 = require('base16-colorscheme')
      local orig = b16.setup
      b16.setup = function(colors, cfg)
        orig(colors, cfg)
        local target
        if vim.g.theme_transparent then
          target = 'none'
        elseif shift ~= 0 then
          local c = tonumber((vim.g.base16_gui00 or ''):gsub('#', ''), 16)
          if c then
            local tgt = shift > 0 and 0xFFFFFF or 0x000000
            local t = math.abs(shift) / 100
            local function ch(a, b) return math.floor(a + (b - a) * t) end
            local function ch_rgb(v) return math.floor(v / 65536) % 256, math.floor(v / 256) % 256, v % 256 end
            local cr, cg, cb = ch_rgb(c)
            local tr, tg, tb = ch_rgb(tgt)
            target = string.format('#%06X', ch(cr, tr) * 65536 + ch(cg, tg) * 256 + ch(cb, tb))
          end
        end
        if target then
          for _, hl in ipairs(bg_groups) do
            local h = vim.api.nvim_get_hl(0, { name = hl })
            h.bg = target
            vim.api.nvim_set_hl(0, hl, h)
          end
        end
      end
    end

    local ok, matugen = pcall(require, 'matugen')
    if ok and type(matugen) == 'table' and matugen.setup then
      matugen.setup()
    end
  end,
}
