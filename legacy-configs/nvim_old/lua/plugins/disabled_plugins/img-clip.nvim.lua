-- support for image pasting
---@type LazyPluginSpec
local spec = {
  'HakonHarnes/img-clip.nvim',
  event = 'VeryLazy',
  opts = {
    default = {
      use_absolute_path = false, ---@type boolean
      -- make dir_path relative to current file rather than the cwd
      -- To see your current working directory run `:pwd`
      -- So if this is set to false, the image will be created in that cwd
      -- In my case, I want images to be where the file is, so I set it to true
      relative_to_current_file = true, ---@type boolean

      -- I want to save the images in a directory named after the current file,
      -- but I want the name of the dir to end with `-img`
      dir_path = function()
        -- return vim.fn.expand '%:t:r' .. '-img'
        return vim.fn.expand 'media'
      end,

      -- If you want to get prompted for the filename when pasting an image
      -- This is the actual name that the physical file will have
      -- If you set it to true, enter the name without spaces or extension `test-image-1`
      -- Remember we specified the extension above
      --
      -- I don't want to give my images a name, but instead autofill it using
      -- the date and time as shown on `file_name` below
      prompt_for_file_name = true, ---@type boolean
      file_name = function()
        return vim.fn.expand '%:t:r' .. '-img-%y%m%d-%H%M%S'
      end,
    },
  },
}

return spec
