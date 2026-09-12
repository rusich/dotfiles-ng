vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- Theme engine: 'matugen' (noctalia) | 'theme-hub'
vim.g.theme_engine = vim.g.theme_engine or 'matugen'

-- Transparent background: true = bg=none (настоящая прозрачность), false = сдвиг фона (bg_shift)
vim.g.theme_transparent = true

require 'config.lazy-bootstrap'
require 'config.options'
require 'config.lsp'
require 'config.keymaps'
require 'config.autocommands'
require 'config.highlights'
