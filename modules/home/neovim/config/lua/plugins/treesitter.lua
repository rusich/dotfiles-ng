return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  branch = 'main',
  build = ':TSUpdate',
  init = function()
    local ensure_installed = {
      -- PROGRAMMING LANGS
      'bash',
      'c',
      'c_sharp',
      'fish',
      'javascript',
      'lua',
      'python',
      'ruby', -- used by `Brewfile`
      'rust',
      'typescript',
      'vim',
      'zsh',

      -- DATAFORMATS
      'json',
      'toml',
      'xml', -- also used by .plist and .svg files, since they are essentially xml
      'yaml',
      'bibtex',
      -- "csv", -- disabled, since bad highlighting

      -- CONTENT
      'css',
      'html',
      'markdown',
      'markdown_inline',
      'latex',
      'typst',

      -- SPECIAL FILETYPES
      'diff',
      'editorconfig',
      'git_config',
      'git_rebase',
      'gitattributes',
      'gitcommit',
      'gitignore',
      'just',
      'query', -- treesitter query files (.scm)
      'requirements', -- python's `requirements.txt`
      'vimdoc', -- `:help` files

      -- EMBEDDED LANGUAGES
      'comment',
      'graphql',
      'jsdoc',
      'luadoc',
      'luap', -- lua patterns
      'regex',
      'bash', -- embedded in GitHub Actions, etc.
    }

    vim.defer_fn(function()
      require('nvim-treesitter').install(ensure_installed)
    end, 1000)
    require('nvim-treesitter').update()

    -- auto-start highlights & indentation
    vim.api.nvim_create_autocmd('FileType', {
      desc = 'User: enable treesitter highlighting',
      callback = function(ctx)
        -- highlights
        local hasStarted = pcall(vim.treesitter.start) -- errors for filetypes with no parser

        -- indent
        local noIndent = {}
        if hasStarted and not vim.list_contains(noIndent, ctx.match) then
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
