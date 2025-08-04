local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local taglist_config = {}

local taglist_fg_colors = {
    ["1:Main"] = "#FF0000",
    ["4:VM"] = "#0000FF",
    ["5:Games"] = "#00FF00",
    default = beautiful.bg_normal,
}

function highlight_taglist_item(self, c3, index, objects)
    -- fg_color
    -- Underline color
    local tag_has_urgent_client = false
    local tag_clients = c3:clients()
    if tag_clients ~= nil then
        for _, client in ipairs(tag_clients) do
            if client.urgent == true then
                tag_has_urgent_client = true
                break
            end
        end
    end

    -- self:get_children_by_id("underline")[1].bg = "#ff4453"
    if tag_has_urgent_client then
        self:get_children_by_id("underline")[1].bg = "#ff4453"
    elseif c3.selected then
        self:get_children_by_id("underline")[1].bg = beautiful.bg_focus
    elseif #c3:clients() ~= 0 then
        self:get_children_by_id("underline")[1].bg = beautiful.fg_normal
    else
        self:get_children_by_id("underline")[1].bg = beautiful.bg_normal
    end
end

taglist_config = {
    filter = awful.widget.taglist.filter.all,
    -- buttons = taglist_buttons,
    -- layout = wibox.layout.fixed.horizontal,
    layout = {
        spacing = dpi(4),
        -- spacing_widget = {
        --     color = "#dddddd",
        --     shape = gears.shape.powerline,
        --     widget = wibox.widget.separator,
        -- },
        layout = wibox.layout.fixed.horizontal,
    },
    style = {
        font = "Hack Nerd Bold " .. string.format("%d", dpi(15)),
    },
    widget_template = {
        {
            {
                {
                    {
                        id = "text_role",
                        widget = wibox.widget.textbox,
                        fg = "#FF0000",
                    },
                    left = dpi(-4),
                    right = dpi(2),
                    top = dpi(-3),      -- vertical asignmetn
                    bottom = dpi(-3.5), -- positon of underline
                    -- margins = 4,
                    widget = wibox.container.margin,
                },
                {
                    {
                        left = dpi(0),
                        right = dpi(0),
                        top = dpi(0),
                        bottom = dpi(3), -- height of underline
                        widget = wibox.container.margin,
                    },
                    id = "underline",
                    bg = "#ffffff",
                    shape = gears.shape.rectangle,
                    widget = wibox.container.background,
                },
                layout = wibox.layout.fixed.vertical,
            },
            left = dpi(0),
            right = dpi(0),
            top = dpi(0),
            widget = wibox.container.margin,
        },
        id = "background_role",
        widget = wibox.container.background,
        shape = gears.shape.rectangle,
        create_callback = highlight_taglist_item,
        update_callback = highlight_taglist_item,
        -- font = "Hack Nerd " .. string.format("%d", 26),
    },
}
local function worker(user_args)
    local args = user_args or {}

    return awful.widget.taglist(gears.table.join(taglist_config, args))
end

return setmetatable(taglist_config, {
    __call = function(_, ...)
        return worker(...)
    end,
})
