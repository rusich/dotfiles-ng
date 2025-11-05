-- Integrate nvim with tmux

local spec = {
  'knubie/vim-kitty-navigator',
  build = 'cp ./*.py ~/.config/kitty/',
}

return spec
