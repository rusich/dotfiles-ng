return {
  settings = {
    ['rust-analyzer'] = {
      check = {
        command = 'clippy',
        -- extraArgs = { '--', '--no-deps', '-Dclippy::pedantic' },
        extraArgs = {
          '--',
          '--no-deps',
          '-Aclippy::all',      -- сначала разрешаем всё
          '-Wclippy::pedantic', -- затем включаем pedantic как warnings
          '-Wclippy::nursery',  -- если нужно nursery как warnings
          '-Wclippy::cargo',    -- и т.д.
        },
      },
      diagnostics = {
        enable = true,
      },
    },
  },
}
