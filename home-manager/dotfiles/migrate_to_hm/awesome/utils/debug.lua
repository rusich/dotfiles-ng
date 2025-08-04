local gears = require("gears")
local gfs = require("gears.filesystem")
local config_path = gfs.get_configuration_dir()
local M = {}

local d_c = 0

---comment
---@param msg string
---@param obj object
function M.print(msg, obj)
    -- Opens a file in append mode
    local file = io.open(config_path .. "/debug.log", "a")

    -- sets the default output file as test.lua
    ---@diagnostic disable-next-line: param-type-mismatch
    io.output(file)

    d_c = d_c + 1
    io.write(string.format("%d: ", d_c))
    -- appends a word test to the last line of the file
    io.write(msg)
    if obj ~= nil then
        io.write(gears.debug.dump_return(obj, nil, 1000))
    end
    io.write("\n")

    -- closes the open file
    io.close(file)
end

return M
