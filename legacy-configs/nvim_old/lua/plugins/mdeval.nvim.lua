-- Execute code blocks in Markdown and Org files

---@type LazyPluginSpec
return {
  'jubnzv/mdeval.nvim',
  lazy = true,
  cmd = { 'MdEval', 'MdEvaLlean' },
  opts = {
    -- Don't ask before executing code blocks
    require_confirmation = false,
    -- Change code blocks evaluation options.
    eval_options = {
      -- Set custom configuration for C++
      cpp = {
        command = { 'clang++', '-std=c++20', '-O0' },
        default_header = [[
    #include <iostream>
    #include <vector>
    using namespace std;
      ]],
      },
      -- Add new configuration for Racket
      -- racket = {
      --   command = { 'cargo run' }, -- Command to run interpreter
      --   language_code = 'rust', -- Markdown language code
      --   exec_type = 'compiled', -- compiled or interpreted
      --   extension = 'rs', -- File extension for temporary files
      -- },
    },
  },
}
