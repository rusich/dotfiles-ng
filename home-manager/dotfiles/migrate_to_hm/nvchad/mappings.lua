---@type MappingsTable
local M = {}

M.disabled = {
    i = { -- {{{
        ["<C-b>"] = "", -- { "<ESC>^i", "Beginning of line" },
        ["<C-e>"] = "", -- { "<End>", "End of line" },
        ["<leader>/"] = "", -- { "<End>", "End of line" },
    }, -- }}}
    n = {
        ["<C-c>"] = "", -- copy buffer
        ["<tab>"] = "",
        ["<S-tab>"] = "",
        ["<leader>b"] = "", -- { "<cmd> enew <CR>", "New buffer" },
        ["x"] = "",
        ["<leader>n"] = "", -- { "<cmd> set nu! <CR>", "Toggle line number" },
        ["<leader>rn"] = "", -- { "<cmd> set rnu! <CR>", "Toggle relative number" },
        ["<leader>ch"] = "", --{ "<cmd> NvCheatsheet <CR>", "Mapping cheatsheet" },
        ["<leader>fm"] = "", --{ function() vim.lsp.buf.format { async = true } end, "LSP formatting", },
        ["<leader>ls"] = "", -- { function() vim.lsp.buf.signature_help() end, "LSP signature help", },
        ["<leader>D"] = "", -- { "<cmd>Telescope lsp_type_definitions<cr>", "LSP definition type", },
        ["<leader>ra"] = "", -- { function() require("nvchad.renamer").open() end, "LSP rename", },
        ["<leader>lf"] = "", -- { function() vim.diagnostic.open_float({ border = "rounded" }) end, "Floating diagnostic", },
        ["<leader>q"] = "", -- { function() vim.diagnostic.setloclist() end, "Diagnostic setloclist", },
        ["<C-n>"] = "", -- { "<cmd> NvimTreeToggle <CR>", "Toggle nvimtree" },
        ["<leader>e"] = "", --{ "<cmd> NvimTreeFocus <CR>", "Focus nvimtree" },
        ["<leader>fo"] = "", -- { "<cmd> Telescope oldfiles <CR>", "Find oldfiles" },
        ["<leader>fh"] = "", -- { "<cmd> Telescope help_tags <CR>", "Help page" },
        ["<leader>cm"] = "", -- { "<cmd> Telescope git_commits <CR>", "Git commits" },
        ["<leader>gt"] = "", -- { "<cmd> Telescope git_status <CR>", "Git status" },
        ["<leader>pt"] = "", -- { "<cmd> Telescope terms <CR>", "Pick hidden term" },
        ["<leader>ma"] = "", --  { "<cmd> Telescope marks <CR>", "telescope bookmarks" },
        ["<leader>th"] = "", -- { "<cmd> Telescope themes <CR>", "Nvchad themes" },/
        ["<leader>wK"] = "",
        ["<leader>wk"] = "",
        ["<leader>rh"] = "",
        ["<leader>ph"] = "",
        ["<leader>gb"] = "",
        ["]c"] = "",
        ["]C"] = "",
        ["[c"] = "",
        ["[C"] = "",
        ["<leader>td"] = "", -- git toggle deleted
        ["<leader>/"] = "", -- git toggle deleted
    },
}

M.general = {
    i = {
        ["<C-a>"] = { "<ESC>^i", "Beginning of line" },
        ["<C-e>"] = { "<End>", "End of line" },
        ["<C-s>"] = { "<cmd>w!<cr>", "Save file" },
    },
    n = {
        ["gx"] = { "<cmd>silent !xdg-open <cWORD><cr>", "Open URL" },
        -- [";"] = { ":", "enter command mode", opts = { nowait = true } },
        ["<C-q>"] = { "<cmd>qa<cr>", "Quit Neovim" },
        --
        -- WINDOW MANAGEMENT
        --
        -- Close window/buffer
        ["<C-c>"] = {
            function()
                local function close_window()
                    vim.api.nvim_win_close(0, false)
                end

                if pcall(close_window) ~= true then
                    local bufs = vim.fn.getbufinfo({ buflisted = true })
                    vim.api.nvim_buf_delete(0, {})

                    if not bufs[2] then
                        vim.cmd("Nvdash")
                        require("nvchad.tabufline").closeOtherBufs()
                        vim.cmd("setlocal foldcolumn=0")
                    end
                end
            end,
            "Close window/buffer",
            opts = { nowait = true },
        },
        ["<leader>bn"] = { "<cmd> enew <CR>", "New buffer" },
        ["<leader>un"] = { "<cmd> set nu! <CR>", "Toggle line number" },
        ["<leader>ur"] = { "<cmd> set rnu! <CR>", "Toggle relative number" },

        -- Resize window using <ctrl> arrow keys
        ["<C-Up>"] = { "<cmd>resize +2<cr>", "Increase window height" },
        ["<C-Down>"] = { "<cmd>resize -2<cr>", "Decrease window height" },
        ["<C-Left>"] = { "<cmd>vertical resize -2<cr>", "Decrease window width" },
        ["<C-Right>"] = { "<cmd>vertical resize +2<cr>", "Increase window width" },

        -- Folding
        ["<C-Space>"] = { ":silent! norm za<CR>", "Toggle fold" },
        -- Move text up and down
        ["<A-j>"] = { ":m .+1<CR>==", "Move current line down" },
        ["<A-k>"] = { ":m .-2<CR>==", "Move current line up" },

        -- Splits
        ["\\"] = { "<cmd>vsp<cr>", "Vertical plit" },
        ["-"] = { "<cmd>sp<cr>", "Horizontal split" },

        ["<leader>uc"] = { "<cmd> NvCheatsheet <CR>", "Mapping cheatsheet" },
        ["<leader>us"] = { "<cmd> set spell! <CR>", "Toggle spell check" },
        ["<leader>uT"] = {
            function()
                require("base46").toggle_transparency()
            end,
            "Toggle transparency",
        },

        ["<leader>uf"] = {
            function()
                if vim.o.foldcolumn == "0" then
                    vim.o.foldcolumn = "auto"
                else
                    vim.o.foldcolumn = "0"
                end
            end,
            "Toggle folds",
        },
    },
    v = {
        [">"] = { ">gv", "indent" },

        -- Folding
        ["<C-Space>"] = { "zf", "Create fold from selection" },
        -- Move text up and down
        ["<A-j>"] = { ":move '>+1<CR>gv-gv", "Move selected lines down" },
        ["<A-k>"] = { ":move '<-2<CR>gv-gv", "Move selected lines up" },
    },
}

M.tabufline = {
    plugin = true,

    n = {
        -- cycle through buffers
        ["L"] = {
            function()
                require("nvchad.tabufline").tabuflineNext()
            end,
            "Goto next buffer",
        },

        ["H"] = {
            function()
                require("nvchad.tabufline").tabuflinePrev()
            end,
            "Goto prev buffer",
        },

        -- close buffer + hide terminal buffer
        ["<leader>bd"] = {
            function()
                require("nvchad.tabufline").close_buffer()
            end,
            "Close buffer",
        },
    },
}

M.comment = {
    plugin = true,

    -- toggle comment in both modes
    n = {
        ["<C-/>"] = {
            function()
                require("Comment.api").toggle.linewise.current()
            end,
            "Toggle comment",
        },
    },

    v = {
        ["<C-/>"] = {
            "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
            "Toggle comment",
        },
    },
}

M.lspconfig = {
    plugin = false,

    -- See `<cmd> :help vim.lsp.*` for documentation on any of the below functions

    n = {

        ["gE"] = { "<cmd>Telescope diagnostics severity_limit=ERROR<cr>", desc = "Show diagnostics ERRORS" },
        ["gW"] = { "<cmd>Telescope diagnostics<cr>", desc = "Show diagnostics WARNINGS, NOTICES" },
        ["<leader>cE"] = { "<cmd>Telescope diagnostics severity_limit=ERROR<cr>", desc = "Show diagnostics ERRORS" },
        ["<leader>cW"] = { "<cmd>Telescope diagnostics<cr>", desc = "Show diagnostics WARNINGS, NOTICES" },
        ["<leader>ui"] = {
            function()
                local ih = vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint
                if type(ih) == "table" and ih.enable then
                    local val = ih.is_enabled(0)
                    ih.enable(0, not val)
                end
            end,
            "Toggle Inlay Hints",
        },
        ["<leader>ud"] = {
            function()
                local d = vim.diagnostic.config().virtual_text

                if d == true then
                    vim.diagnostic.config({ virtual_text = false })
                else
                    vim.diagnostic.config({ virtual_text = true })
                end
            end,
            "Toggle Inline Diagnostics",
        },
        ["<leader>cf"] = {
            function()
                vim.lsp.buf.format({ async = true })
            end,
            "Format buffer",
        },
        ["<C-A-f>"] = {
            function()
                vim.lsp.buf.format({ async = true })
            end,
            "Format buffer",
        },

        ["gD"] = {
            function()
                vim.lsp.buf.declaration()
            end,
            "LSP declaration",
        },

        ["gd"] = {

            function()
                if vim.fn.expand("%:e") == "cs" then
                    require("omnisharp_extended").telescope_lsp_definitions()
                else
                    vim.cmd("Telescope lsp_definitions")
                end
            end,
            "LSP definition",
        },

        ["<M-K>"] = {
            "<esc><cmd>lua vim.lsp.buf.hover()<cr><cmd>sleep 100m<cr><C-W>w<C-W>v<cmd>vert res 80<cr><C-W>h",
            desc = "Hover doc to vertical split",
        },
        ["K"] = {

            function()
                if vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
                    require("crates").show_popup()
                else
                    vim.lsp.buf.hover()
                end
            end,
            "LSP hover",
        },

        ["gi"] = {
            "<cmd>Telescope lsp_implementations<cr>",
            "LSP implementation",
        },

        ["<leader>cs"] = {
            function()
                vim.lsp.buf.signature_help()
            end,
            "LSP signature help",
        },
        ["<C-k>"] = {
            function()
                vim.lsp.buf.signature_help()
            end,
            "LSP signature help",
        },

        ["<leader>cD"] = {
            "<cmd>Telescope lsp_type_definitions<cr>",
            "LSP type definition",
        },

        ["<leader>cr"] = {
            function()
                require("nvchad.renamer").open()
            end,
            "LSP rename",
        },

        ["<leader>ca"] = {
            function()
                vim.lsp.buf.code_action()
            end,
            "LSP code action",
        },

        ["gr"] = {
            "<cmd>Telescope lsp_references<cr>",
            "LSP references",
        },

        ["<leader>cd"] = {
            function()
                vim.diagnostic.open_float({ border = "rounded" })
            end,
            "Floating diagnostic",
        },

        ["[d"] = {
            function()
                vim.diagnostic.goto_prev({ float = { border = "rounded" } })
            end,
            "Goto prev",
        },

        ["]d"] = {
            function()
                vim.diagnostic.goto_next({ float = { border = "rounded" } })
            end,
            "Goto next",
        },

        ["<leader>cq"] = {
            function()
                vim.diagnostic.setloclist()
            end,
            "Diagnostic setloclist",
        },

        ["<leader>cL"] = { vim.lsp.codelens.run, "Run CodeLens" },
    },

    i = {

        ["<C-k>"] = {
            function()
                vim.lsp.buf.signature_help()
            end,
            "LSP signature help",
        },
    },
    v = {
        ["<leader>ca"] = {
            function()
                vim.lsp.buf.code_action()
            end,
            "LSP code action",
        },
    },
}

M.nvimtree = {
    plugin = true,

    n = {
        -- toggle
        ["<leader>e"] = { "<cmd> NvimTreeToggle <CR>", "Toggle nvimtree" },
    },
}

M.spectre = {
    plugin = true,
    n = {
        ["<leader>sr"] = {
            function()
                require("spectre").open()
            end,
            "Replace in files (Spectre)",
        },
    },
}

M.telescope = {
    plugin = true,

    n = {
        -- find
        ["<leader><space>"] = { "<cmd> Telescope find_files<cr>", "Find files" },
        ["<leader>/"] = { "<cmd> Telescope live_grep<CR>", "Live grep" },
        ["<leader>fc"] = { "<cmd> Telescope find_files cwd=~/.config/nvchad/<CR>", "Find config files" },
        ["<leader>fC"] = { "<cmd> Telescope find_files cwd=~/.config/nvim/<CR>", "Find default config files" },
        ["<leader>fW"] = { "<cmd> Telescope live_grep cwd=~/.config/nvchad/<CR>", "Live grep config files" },
        ["<leader>fr"] = { "<cmd> Telescope oldfiles <CR>", "Recent files" },
        ["<leader>fR"] = { "<cmd> Telescope oldfiles cwd=" .. vim.fn.expand("%:p:h") .. " <CR>", "Recent files (CWD)" },
        ["<leader>fz"] = { "<cmd> Telescope current_buffer_fuzzy_find <CR>", "Find in current buffer" },
        ["<leader>bb"] = { "<cmd> Telescope buffers <CR>", "Find buffers" },

        -- search
        ['<leader>s"'] = { "<cmd>Telescope registers<cr>", "Registers" },
        ["<leader>sa"] = { "<cmd>Telescope autocommands<cr>", "Auto Commands" },
        ["<leader>sb"] = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", "Buffer" },
        ["<leader>sc"] = { "<cmd>Telescope command_history<cr>", "Command History" },
        ["<leader>sC"] = { "<cmd>Telescope commands<cr>", "Commands" },
        ["<leader>sd"] = { "<cmd>Telescope diagnostics bufnr=0<cr>", "Document diagnostics" },
        ["<leader>sD"] = { "<cmd>Telescope diagnostics<cr>", "Workspace diagnostics" },
        ["<leader>sh"] = { "<cmd>Telescope help_tags<cr>", "Help Pages" },
        ["<leader>sH"] = { "<cmd>Telescope highlights<cr>", "Search Highlight Groups" },
        ["<leader>sk"] = { "<cmd>Telescope keymaps<cr>", "Key Maps" },
        ["<leader>sM"] = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
        ["<leader>sm"] = { "<cmd>Telescope marks<cr>", "Jump to Mark" },
        ["<leader>so"] = { "<cmd>Telescope vim_options<cr>", "Options" },
        ["<leader>sR"] = { "<cmd>Telescope resume<cr>", "Resume" },
        ["<leader>ss"] = { "<cmd>Telescope lsp_document_symbols<cr>", "Document symbols" },
        ["<leader>st"] = { "<cmd>Telescope treesitter", "Treesitter symbols" },
        ["<leader>sS"] = { "<cmd>Telescope lsp_workspace_symbols<cr>", "Workspace symbols" },
        ["<leader>uh"] = { "<cmd> Telescope terms <CR>", "Pick hidden term" },

        -- git
        ["<leader>gc"] = { "<cmd> Telescope git_commits <CR>", "Git commits" },
        ["<leader>gs"] = { "<cmd> Telescope git_status <CR>", "Git status" },
        ["<leader>gb"] = { "<cmd>Telescope git_branches<cr>", "Branches" },
        ["<leader>gt"] = { "<cmd>Telescope git_stash<cr>", "Stash" },
        ["<leader>gC"] = { "<cmd>Telescope git_bcommits<cr>", "Buffer commits" },
        -- theme switcher
        ["<leader>ut"] = { "<cmd> Telescope themes <CR>", "Nvchad themes" },
    },
}

M.whichkey = {
    plugin = true,

    n = {
        ["<leader>uwK"] = {
            function()
                vim.cmd("WhichKey")
            end,
            "Which-key all keymaps",
        },
        ["<leader>uwk"] = {
            function()
                local input = vim.fn.input("WhichKey: ")
                vim.cmd("WhichKey " .. input)
            end,
            "Which-key query lookup",
        },
    },
}

M.gitsigns = {
    plugin = true,

    n = {
        -- Navigation through hunks
        ["]h"] = {
            function()
                if vim.wo.diff then
                    return "]c"
                end
                vim.schedule(function()
                    require("gitsigns").next_hunk()
                end)
                return "<Ignore>"
            end,
            "Jump to next hunk",
            opts = { expr = true },
        },

        ["[h"] = {
            function()
                if vim.wo.diff then
                    return "[c"
                end
                vim.schedule(function()
                    require("gitsigns").prev_hunk()
                end)
                return "<Ignore>"
            end,
            "Jump to prev hunk",
            opts = { expr = true },
        },
    },
}

M.codeium = {
    plugin = true,
    i = { -- }}}
        ["<A-\\>"] = {
            function()
                return vim.fn["codeium#Accept"]()
            end,
            "Codeium accept",
        },
    },
}
vim.keymap.set("i", "<A-\\>", function()
    return vim.fn["codeium#Accept"]()
end, { expr = true })

M.flash = {
    plugin = true,

    n = {
        ["s"] = { -- {{{
            function()
                require("flash").jump()
            end,
            "Flash search",
        }, -- }}}
    },
}

-- more keybinds!

return M
