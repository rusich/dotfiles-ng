return {
  settings = {
    ['rust-analyzer'] = {
      check = {
        command = 'clippy',
        extraArgs = { '--', '--no-deps', '-Dclippy::pedantic' },
      },
      diagnostics = {
        enable = true,
      },
    },
  },
}
