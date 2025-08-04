local prefix = "<leader>t"

local function has(name)
    return require("lazy.core.config").plugins[name] ~= nil
end

---@type NvPluginSpec
local spec = {
    "nvim-neotest/neotest",
    -- ft = { "rust", "python", "cs" },
    dependencies = {
        { "nvim-neotest/nvim-nio" },
        { "nvim-lua/plenary.nvim" },
        { "nvim-neotest/neotest-plenary" },
        { "nvim-neotest/neotest-python" },
        { "nvim-treesitter/nvim-treesitter" },
        { "Issafalcon/neotest-dotnet" },
        { "rouge8/neotest-rust" },
        { "klen/nvim-test" },
    },
    opts = {
        adapters = {
            ["neotest-python"] = {
                dap = { justMyCode = false },
            },
            ["neotest-dotnet"] = {},
            ["neotest-rust"] = {},
        },
        status = { virtual_text = true },
        output = { open_on_run = true },
        quickfix = {
            open = function()
                if has("trouble.nvim") then
                    require("trouble").open({ mode = "quickfix", focus = false })
                else
                    vim.cmd("copen")
                end
            end,
        },
        -- jump = {
        --     enabled = true,
        -- },
        diagnostic = {
            enabled = true,
        },
    },
    config = function(_, opts)
        local neotest_ns = vim.api.nvim_create_namespace("neotest")
        vim.diagnostic.config({
            virtual_text = {
                format = function(diagnostic)
                    -- Replace newline and tab characters with space for more compact diagnostics
                    local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
                    return message
                end,
            },
        }, neotest_ns)

        if has("trouble.nvim") then
            opts.consumers = opts.consumers or {}
            opts.consumers.trouble = function(client)
                client.listeners.results = function(adapter_id, results, partial)
                    if partial then
                        return
                    end
                    local tree = assert(client:get_position(nil, { adapter = adapter_id }))

                    local failed = 0
                    for pos_id, result in pairs(results) do
                        if result.status == "failed" and tree:get_key(pos_id) then
                            failed = failed + 1
                        end
                    end
                    vim.schedule(function()
                        local trouble = require("trouble")
                        if trouble.is_open() then
                            trouble.refresh()
                            if failed == 0 then
                                trouble.close()
                            end
                        end
                    end)
                    return {}
                end
            end
        end

        if opts.adapters then
            local adapters = {}
            for name, config in pairs(opts.adapters or {}) do
                if type(name) == "number" then
                    if type(config) == "string" then
                        config = require(config)
                    end
                    adapters[#adapters + 1] = config
                elseif config ~= false then
                    local adapter = require(name)
                    if type(config) == "table" and not vim.tbl_isempty(config) then
                        local meta = getmetatable(adapter)
                        if adapter.setup then
                            adapter.setup(config)
                        elseif meta and meta.__call then
                            adapter(config)
                        else
                            error("Adapter " .. name .. " does not support setup")
                        end
                    end
                    adapters[#adapters + 1] = adapter
                end
            end
            opts.adapters = adapters
        end
        require("neotest").setup(opts)
    end,
    --         default_strategy = "integrated",
    --         highlights = {
    --             adapter_name = "NeotestAdapterName",
    --             border = "NeotestBorder",
    --             dir = "NeotestDir",
    --             expand_marker = "NeotestExpandMarker",
    --             failed = "NeotestFailed",
    --             file = "NeotestFile",
    --             focused = "NeotestFocused",
    --             indent = "NeotestIndent",
    --             marked = "NeotestMarked",
    --             namespace = "NeotestNamespace",
    --             passed = "NeotestPassed",
    --             running = "NeotestRunning",
    --             select_win = "NeotestWinSelect",
    --             skipped = "NeotestSkipped",
    --             target = "NeotestTarget",
    --             test = "NeotestTest",
    --             unknown = "NeotestUnknown",
    --         },
    --         icons = {
    --             child_indent = "│",
    --             child_prefix = "├",
    --             collapsed = "─",
    --             expanded = "╮",
    --             failed = "✖",
    --             final_child_indent = " ",
    --             final_child_prefix = "╰",
    --             non_collapsible = "─",
    --             passed = "✔",
    --             running = "🗘",
    --             skipped = "ﰸ",
    --             unknown = "?",
    --         },
    keys = {
        { prefix, desc = "󰙨 Testing" },
        { prefix .. "a", "<cmd>lua require('neotest').run.attach()<cr>", desc = "Attach" },
        { prefix .. "f", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", desc = "Run File" },
        {
            prefix .. "F",
            "<cmd>lua require('neotest').run.run({vim.fn.expand('%'), strategy = 'dap'})<cr>",
            desc = "Debug File",
        },
        { prefix .. "l", "<cmd>lua require('neotest').run.run_last()<cr>", desc = "Run Last" },
        { prefix .. "L", "<cmd>lua require('neotest').run.run_last({ strategy = 'dap' })<cr>", desc = "Debug Last" },
        { prefix .. "r", "<cmd>lua require('neotest').run.run()<cr>", desc = "Run Nearest" },
        { prefix .. "d", "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>", desc = "Debug Nearest" },
        { prefix .. "o", "<cmd>lua require('neotest').output.open({ enter = true })<cr>", desc = "Output" },
        { prefix .. "S", "<cmd>lua require('neotest').run.stop()<cr>", desc = "Stop" },
        { prefix .. "s", "<cmd>lua require('neotest').summary.toggle()<cr>", desc = "Summary" },
        { prefix .. "m", "<cmd>lua require('neotest').summary.run_marked()<cr>", desc = "Run marked" },
        { prefix .. "n", "<cmd>lua require('neotest').jump.next()<cr>", desc = "Jump Next" },
        { prefix .. "p", "<cmd>lua require('neotest').jump.prev()<cr>", desc = "Jump Previous" },
        {
            prefix .. "N",
            "<cmd>lua require('neotest').jump.next({status = 'failed'})<cr>",
            desc = "Jump Next FAILED",
        },
        {
            prefix .. "P",
            "<cmd>lua require('neotest').jump.prev({status = 'failed'})<cr>",
            desc = "Jump Previous FAILED",
        },
        { prefix .. "e", "<Plug>PlenaryTestFile", desc = "PlenaryTestFile" },
        { prefix .. "v", "<cmd>TestVisit<cr>", desc = "Visit" },
        { prefix .. "x", "<cmd>TestSuite<cr>", desc = "Suite" },
    },
}

return spec
