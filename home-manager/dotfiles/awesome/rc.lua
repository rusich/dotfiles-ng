--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------
--
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
local HOME_DIR = os.getenv("HOME")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi
-- Notification library
--local naughty = require("naughty") -- using XFCE4 notify daemon
local io = require("io")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")
local lain = require("lain")
local custom_widgets = require("custom-widgets")

--------------------------------------------------------------------------------
-- Utils
--------------------------------------------------------------------------------
local function print_stderr(s)
    io.stderr:write(s .. "\n")
end

--test
-- print_stderr("\nTest from rc.lua!\n")

---Send DBUS notification
---@param title string Must be a string
---@param text string Must be a string
function notify_send(title, text)
    local icon = "/usr/share/awesome/themes/sky/awesome-icon.png"
    awful.spawn("notify-send -u critical -t 30000 -i " .. icon .. " '" .. title .. "' '" .. text .. "'")
end

--------------------------------------------------------------------------------
-- Error handling
--------------------------------------------------------------------------------

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors,
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then
            return
        end
        in_error = true

        --naughty.notify({ preset = naughty.config.presets.critical,
        --                 title = "Oops, an error happened!",
        --                 text = tostring(err) })
        notify_send("Awesome error happened!", tostring(err))
        in_error = false
    end)
end

-- {{{ Variable definitions
local gap_size = 10
local client_corner_radius = 8

-- Themes define colours, icons, font and wallpapers.
-- beautiful.init(gears.filesystem.get_themes_dir() .. "gtk/theme.lua")
-- beautiful.init(gears.filesystem.get_configuration_dir() .. "themes/gtk/theme.lua")
beautiful.init(gears.filesystem.get_configuration_dir() .. "themes/default/theme.lua")
-- beautiful.bg_systray = "#ff0000AA"
beautiful.useless_gap = gap_size
beautiful.gap_single_client = true

-- Terminal and editor
-- This is used later as the default terminal and editor to run.
-- terminal = "alacritty"
local terminal = "kitty"
local editor = os.getenv("EDITOR") or "nano"
local editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
local modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom, -- master on top, slaves on bottom
    awful.layout.suit.tile.top, -- master on bottom, slaves on top
    -- awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    awful.layout.suit.fair, -- grid
    awful.layout.suit.magnifier,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.floating,
    lain.layout.centerwork,
    -- awful.layout.suit.corner.nw,
    --awful.layout.suit.corner.ne,
    --awful.layout.suit.corner.sw,
    --awful.layout.suit.corner.se,
    -- TESTING
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
local myawesomemenu = {
    {
        "hotkeys",
        function()
            hotkeys_popup.show_help(nil, awful.screen.focused())
        end,
    },
    { "manual",      terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart",     awesome.restart },
    {
        "quit",
        function()
            awesome.quit()
        end,
    },
}
-- }}}

local mymainmenu = awful.menu({
    items = {
        { "awesome",       myawesomemenu, beautiful.awesome_icon },
        { "open terminal", terminal },
    },
})

local mylauncher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu = mymainmenu,
    -- clip_shape = gears.shape.circle,
    resize = false,
    forced_height = 10,
    forced_width = 10,
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({}, 3, function()
        mymainmenu:toggle()
    end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings

globalkeys = gears.table.join(
-- launcher
    awful.key({ modkey }, "x", function()
        awful.spawn("rofi -show combi")
    end, { description = "Run program or switch to window", group = "launcher" }),

    -- awful.key({}, "Super_L", function()
    --     notify_send("Super_L", "Pressed")
    --     -- awful.spawn("rofi -show combi")
    --     root.fake_input("key_release", "Super_L")
    -- end),
    -- awful.key({ modkey }, "Super_L", nil, function()
    --     notify_send("Super_L", "Released")
    -- end),

    awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
    awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
    awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
    awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),
    -- Menu
    --awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
    --          {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey }, "g", function()
        if beautiful.useless_gap == gap_size then
            beautiful.useless_gap = 0
        else
            beautiful.useless_gap = gap_size
        end
        awful.client.focus.byidx(1)
        awful.client.focus.byidx(-1)
    end, { description = "Toggle useless gaps", group = "awesome" }),
    awful.key({ modkey }, "j", function()
        awful.client.focus.byidx(1)
        -- awful.client.focus.bydirection("down")
    end, { description = "focus next by index", group = "client" }),
    awful.key({ modkey }, "k", function()
        awful.client.focus.byidx(-1)
        -- awful.client.focus.bydirection("up")
    end, { description = "focus previous by index", group = "client" }),
    awful.key({ modkey }, "h", function()
        awful.client.focus.bydirection("left")
    end, { description = "focus left", group = "client" }),
    awful.key({ modkey }, "l", function()
        awful.client.focus.bydirection("right")
    end, { description = "focus right", group = "client" }),
    awful.key({ modkey, "Shift" }, "j", function()
        awful.client.swap.byidx(1)
    end, { description = "swap with next client by index", group = "client" }),
    awful.key({ modkey, "Shift" }, "k", function()
        awful.client.swap.byidx(-1)
    end, { description = "swap with previous client by index", group = "client" }),
    awful.key({ modkey, "Shift" }, "h", function()
        awful.client.swap.bydirection("left")
    end, { description = "swap with left client", group = "client" }),
    awful.key({ modkey, "Shift" }, "l", function()
        awful.client.swap.bydirection("right")
    end, { description = "swap with right client", group = "client" }),
    -- awful.key({ modkey }, "j", function()
    --     awful.client.focus.byidx(1)
    -- end, { description = "focus next by index", group = "client" }),
    -- awful.key({ modkey }, "k", function()
    --     awful.client.focus.byidx(-1)
    -- end, { description = "focus previous by index", group = "client" }),
    -- awful.key({ modkey, "Shift" }, "j", function()
    --     awful.client.swap.byidx(1)
    -- end, { description = "swap with next client by index", group = "client" }),
    -- awful.key({ modkey, "Shift" }, "k", function()
    --     awful.client.swap.byidx(-1)
    -- end, { description = "swap with previous client by index", group = "client" }),
    awful.key({ modkey, "Control" }, "j", function()
        awful.screen.focus_relative(1)
    end, { description = "focus the next screen", group = "screen" }),
    awful.key({ modkey, "Control" }, "k", function()
        awful.screen.focus_relative(-1)
    end, { description = "focus the previous screen", group = "screen" }),
    awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
    awful.key({ modkey }, "Tab", function()
        awful.client.focus.history.previous()
        if client.focus then
            client.focus:raise()
        end
    end, { description = "History go back", group = "client" }),
    awful.key({ modkey, "Control" }, "t", function()
        awful.titlebar.toggle(client.focus)
    end, { description = "Toggle title bar", group = "client" }),

    -- Programs shortcuts
    awful.key({ modkey }, "Return", function()
        awful.spawn(terminal)
    end, { description = "open a terminal", group = "launcher" }),
    awful.key({ modkey }, "e", function()
        awful.spawn(terminal .. " -e nvim")
    end, { description = "nvim", group = "launcher" }),
    awful.key({ modkey, "Shift" }, "p", function()
        awful.spawn("sh /home/rusich/.config/rofi/scripts/get_pass.sh")
    end, { description = "Get password", group = "launcher" }),
    awful.key({ modkey }, "c", function()
        awful.spawn("sh /home/rusich/.config/rofi/scripts/edit_config.sh")
    end, { description = "Edit config file", group = "launcher" }),
    awful.key({ modkey }, "b", function()
        awful.spawn("yandex-browser-stable")
    end, { description = "open a web-browser", group = "launcher" }),
    awful.key({ modkey }, "n", function()
        awful.spawn(HOME_DIR .. "/Nextcloud/AppImages/Joplin.AppImage")
    end, { description = "Joplin notes", group = "launcher" }),
    awful.key({ modkey }, "t", function()
        awful.spawn("translate.sh")
    end, { description = "Translate selection", group = "launcher" }),
    awful.key({ modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
    -- awful.key({ modkey, "Control" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),

    -- Layout modifications
    awful.key({ modkey }, "=", function()
        awful.tag.incmwfact(0.05)
    end, { description = "increase master width factor", group = "layout" }),
    awful.key({ modkey }, "-", function()
        awful.tag.incmwfact(-0.05)
    end, { description = "decrease master width factor", group = "layout" }),
    -- awful.key({ modkey }, "l", function()
    --     awful.tag.incmwfact(0.05)
    -- end, { description = "increase master width factor", group = "layout" }),
    -- awful.key({ modkey }, "h", function()
    --     awful.tag.incmwfact(-0.05)
    -- end, { description = "decrease master width factor", group = "layout" }),
    awful.key({ modkey, "Shift" }, "=", function()
        awful.tag.incnmaster(1, nil, true)
    end, { description = "increase the number of master clients", group = "layout" }),
    awful.key({ modkey, "Shift" }, "-", function()
        awful.tag.incnmaster(-1, nil, true)
    end, { description = "decrease the number of master clients", group = "layout" }),
    -- awful.key({ modkey, "Shift" }, "h", function()
    --     awful.tag.incnmaster(1, nil, true)
    -- end, { description = "increase the number of master clients", group = "layout" }),
    -- awful.key({ modkey, "Shift" }, "l", function()
    --     awful.tag.incnmaster(-1, nil, true)
    -- end, { description = "decrease the number of master clients", group = "layout" }),
    awful.key({ modkey, "Control" }, "=", function()
        awful.tag.incncol(1, nil, true)
    end, { description = "increase the number of columns", group = "layout" }),
    awful.key({ modkey, "Control" }, "-", function()
        awful.tag.incncol(-1, nil, true)
    end, { description = "decrease the number of columns", group = "layout" }),
    -- awful.key({ modkey, "Control" }, "h", function()
    --     awful.tag.incncol(1, nil, true)
    -- end, { description = "increase the number of columns", group = "layout" }),
    -- awful.key({ modkey, "Control" }, "l", function()
    --     awful.tag.incncol(-1, nil, true)
    -- end, { description = "decrease the number of columns", group = "layout" }),
    awful.key({ modkey, "Control" }, "space", function()
        awful.layout.inc(1)
    end, { description = "select next", group = "layout" }),
    awful.key({ modkey, "Control", "Shift" }, "space", function()
        awful.layout.inc(-1)
    end, { description = "select previous", group = "layout" }),

    awful.key({ modkey, "Control" }, "n", function()
        local c = awful.client.restore()
        -- Focus restored client
        if c then
            c:emit_signal("request::activate", "key.unminimize", { raise = true })
        end
    end, { description = "restore minimized", group = "client" }),

    -- Prompt
    awful.key({ modkey }, "r", function()
        awful.screen.focused().mypromptbox:run()
    end, { description = "run prompt", group = "launcher" }),
    awful.key({ modkey, "Mod1" }, "x", function()
        awful.prompt.run({
            prompt = "Run Lua code: ",
            textbox = awful.screen.focused().mypromptbox.widget,
            exe_callback = awful.util.eval,
            history_path = awful.util.get_cache_dir() .. "/history_eval",
        })
    end, { description = "lua execute prompt", group = "awesome" }),
    awful.key({ modkey, "Control" }, "q", function()
        awful.spawn("archlinux-logout")
    end, { description = "Logout", group = "awesome" }),
    -- ,
    -- Menubar
    -- awful.key({ modkey }, "p", function()
    --     menubar.show()
    -- end, { description = "show the menubar", group = "launcher" })
    --
    -- Multimedia
    awful.key({}, "XF86AudioPlay", function()
        awful.util.spawn("playerctl play-pause")
    end),
    awful.key({}, "XF86AudioNext", function()
        awful.util.spawn("playerctl next")
    end),
    awful.key({}, "XF86AudioPrev", function()
        awful.util.spawn("playerctl previous")
    end),
    awful.key({}, "XF86AudioRaiseVolume", function()
        awful.util.spawn("changevolume up")
    end),
    awful.key({}, "XF86AudioLowerVolume", function()
        awful.util.spawn("changevolume down")
    end),
    awful.key({}, "XF86AudioMute", function()
        awful.util.spawn("changevolume mute")
    end),
    awful.key({}, "Print", function()
        awful.util.spawn("gnome-screenshot --interactive")
    end)
)

clientkeys = gears.table.join(
    awful.key({ modkey }, "f", function(c)
        c.fullscreen = not c.fullscreen
        if c.fullscreen then
            c.shape = function(cr, w, h)
                gears.shape.rounded_rect(cr, w, h, 0)
            end
        else
            c.shape = function(cr, w, h)
                gears.shape.rounded_rect(cr, w, h, client_corner_radius)
            end
        end
        c:raise()
    end, { description = "toggle fullscreen", group = "client" }),
    -- awful.key({ modkey, "Control" }, "c", function(c)
    awful.key({ modkey }, "w", function(c)
        c:kill()
    end, { description = "close", group = "client" }),
    awful.key({ modkey }, "z", function(c)
        c.floating = not c.floating
        c.ontop = c.floating
    end, { description = "toggle floating", group = "client" }),
    awful.key({ modkey, "Control" }, "Return", function(c)
        c:swap(awful.client.getmaster())
    end, { description = "move to master", group = "client" }),
    awful.key({ modkey }, "o", function(c)
        c:move_to_screen()
    end, { description = "move to screen", group = "client" }),
    awful.key({ modkey, "Shift" }, "t", function(c)
        c.ontop = not c.ontop
    end, { description = "toggle keep on top", group = "client" }),
    -- awful.key({ modkey }, "n", function(c)
    --     -- The client currently has the input focus, so it cannot be
    --     -- minimized, since minimized clients can't have the focus.
    --     c.minimized = true
    -- end, { description = "minimize", group = "client" }),
    awful.key({ modkey }, "m", function(c)
        c.maximized = not c.maximized
        c:raise()
    end, { description = "(un)maximize", group = "client" }),
    awful.key({ modkey, "Control" }, "m", function(c)
        c.maximized_vertical = not c.maximized_vertical
        c:raise()
    end, { description = "(un)maximize vertically", group = "client" }),
    awful.key({ modkey, "Shift" }, "m", function(c)
        c.maximized_horizontal = not c.maximized_horizontal
        c:raise()
    end, { description = "(un)maximize horizontally", group = "client" })
)

-- NEW TAG MANAGEMENT
local tag_names = {
    main = " 󰆍 ",
    web = "  ",
    devel = "  ",
    reference = "  ",
    vm = " 󱫋 ",
    -- vm = "  ",
    graphics = "  ",
    games = " 󰓓 ",
}
-- local tag_names = {
--     main = "MAIN",
--     web = "WEB",
--     devel = "DEV",
--     reference = "REF",
--     vm = "WM",
--     graphics = "PIC",
--     games = "GAM",
-- }
awful.tag({
    tag_names.main,
    tag_names.web,
    tag_names.devel,
    tag_names.reference,
    tag_names.vm,
    tag_names.graphics,
    tag_names.games,
}, 1, awful.layout.layouts[1])

sharedtaglist = screen[1].tags

local tags_count = #sharedtaglist

function shared_tag_index(tag)
    for i = 1, tags_count do
        if tag.name == sharedtaglist[i].name then
            return i
        end
    end
    return 1
end

for i = 1, tags_count do
    globalkeys = awful.util.table.join(
        globalkeys,
        -- View tag only.
        -- awful.key({ modkey }, "#" .. i + tags_count, function()
        awful.key({ modkey }, i, function()
            local newscreen = awful.screen.focused()
            local tag = sharedtaglist[i]
            local swapscreen

            -- Check if tag currently selected on other screen
            if tag.screen.selected_tag and tag.selected then
                swapscreen = tag.screen
            end

            local swaptag

            for i = 1, tags_count do
                if newscreen.selected_tag then
                    if sharedtaglist[i].name == newscreen.selected_tag.name then
                        swaptag = sharedtaglist[i]
                    end
                end
            end

            if swaptag and swapscreen then
                --awful.tag.setscreen(swapscreen, swaptag) --deprecated
                swaptag.screen = swapscreen
                swaptag:view_only()
            end

            --awful.tag.setscreen(newscreen, tag) --deprecated
            tag.screen = newscreen
            tag:view_only()

            -- Also sort the tag in the taglist, by reapplying the index. This is just a nicety.

            --for i = 1, screen:count() do
            --    io.stderr:write("screen: " .. i .."\n")
            --    for j,v in ipairs(screen[i].tags) do
            --        io.stderr:write("-> [" .. v.index .. "]" .. v.name .."\n")
            --    end
            --end
            -- Also sort the tag in the taglist, by reapplying the index. This is just a nicety.
            local unpack = unpack or table.unpack
            for _, s in ipairs({ newscreen, swapscreen or { tags = {} } }) do
                local tags = { unpack(s.tags) } -- Copy
                table.sort(tags, function(a, b)
                    return shared_tag_index(a) < shared_tag_index(b)
                end)
                for i, t in ipairs(tags) do
                    t.index = i
                end
            end

            --for j,v in ipairs(sharedtaglist) do
            --    io.stderr:write("shared-> [" .. v.index .. "]" .. v.name .."\n")
            --end
            --
            --io.stderr:write("\n===SHARED SORTED===\n")
            --for j,v in ipairs(sharedtaglist) do
            --    io.stderr:write("shared-> [" .. v.index .. "]" .. v.name .."\n")
            --end
            ----for j,v in ipairs(sharedtaglist) do
            ----    io.stderr:write("shared-> [" .. v.index .. "]" .. v.name .."\n")
            ----end
            --io.stderr:write("\n\n")
        end, { description = "view tag #" .. i, group = "tag" }),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, i, function()
            -- awful.key({ modkey, "Control" }, "#" .. i + 9, function()
            -- local screen = awful.screen.focused()
            local tag = sharedtaglist[i]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end, { description = "toggle tag #" .. i, group = "tag" }),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, i, function()
            -- awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
            if client.focus then
                local tag = sharedtaglist[i] --client.focus.screen.tags[i]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end, { description = "move focused client to tag #" .. i, group = "tag" }),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, i, function()
            -- awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
            if client.focus then
                local tag = sharedtaglist[i] --client.focus.screen.tags[i]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end, { description = "toggle focused client on tag #" .. i, group = "tag" })
    )
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

-- {{{ Wibar
-- Create buttons for taglist, tasklist, etc
local taglist_buttons = gears.table.join(
    awful.button({}, 1, function(t)
        t:view_only()
    end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({}, 4, function(t)
        awful.tag.viewnext(t.screen)
    end),
    awful.button({}, 5, function(t)
        awful.tag.viewprev(t.screen)
    end)
)

local tasklist_buttons = gears.table.join(
    awful.button({}, 1, function(c)
        -- -- Minimize active client
        -- if c == client.focus then
        --     c.minimized = true
        -- else
        c:emit_signal("request::activate", "tasklist", { raise = true })
        -- end
    end),
    awful.button({}, 3, function()
        awful.menu.client_list({ theme = { width = 250 } })
    end),
    awful.button({}, 4, function()
        awful.client.focus.byidx(1)
    end),
    awful.button({}, 5, function()
        awful.client.focus.byidx(-1)
    end)
)

local layout_buttons = gears.table.join(
    awful.button({}, 1, function()
        awful.layout.inc(1)
    end),
    awful.button({}, 3, function()
        awful.layout.inc(-1)
    end),
    awful.button({}, 4, function()
        awful.layout.inc(1)
    end),
    awful.button({}, 5, function()
        awful.layout.inc(-1)
    end)
)

-- Builtin widgets. Shared on all screens
-- Keyboard map indicator and switcher
local mykeyboardlayout = awful.widget.keyboardlayout()
-- Keyboard Layout
awful.key({ modkey }, "space", function()
    mykeyboardlayout.next_layout()
end, { description = "Toggle keyboard layout", group = "awesome" })

-- Create a textclock widget
-- local calendar_widget = require("awesome-wm-widgets.calendar-widget.calendar")
-- ...
-- Create a textclock widget
local mytextclock = wibox.widget.textclock()
-- default
-- local cw = calendar_widget()
-- or customized
-- local cw = calendar_widget({
-- 	theme = "outrun",
-- 	placement = "top_right",
-- 	start_sunday = false,
-- 	radius = 8,
-- 	-- with customized next/previous (see table above)
-- 	previous_month_button = 4,
-- 	next_month_button = 5,
-- })
-- mytextclock:connect_signal("button::press", function(_, _, _, button)
-- 	if button == 1 then
-- 		cw.toggle()
-- 	end
-- end)
--

awful.screen.connect_for_each_screen(function(s)
    local default_tag = sharedtaglist[s.index]
    default_tag.screen = s
    default_tag:view_only()

    -- not primary screens config
    if s ~= screen.primary then
        s.mypromptbox = awful.widget.prompt()
        -- Create an imagebox widget which will contain an icon indicating which layout we're using.
        s.mylayoutbox = awful.widget.layoutbox(s)
        s.mylayoutbox:buttons(gears.table.join(layout_buttons))
        -- Create a taglist widget
        -- s.mytaglist = awful.widget.taglist(gears.table.join(beautiful.taglist_template, {
        --     screen = s,
        -- filter = awful.widget.taglist.filter.all,
        --     buttons = taglist_buttons,
        -- }))
        -- s.mytaglist = custom_widgets.underlined_taglist({
        s.mytaglist = custom_widgets.underlined_taglist({
            screen = s,
            buttons = taglist_buttons,
            filter = awful.widget.taglist.filter.all,
        })

        -- Create a tasklist widget
        s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.focused, tasklist_buttons)
        -- s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

        -- Create the wibox
        s.mywibar = awful.wibar({
            position = "top",
            screen = s,
        })

        -- Add widgets to the wibox
        s.mywibar:setup({
            layout = wibox.layout.align.horizontal,
            expand = "none",
            {
                -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                mylauncher,
                {
                    widget = wibox.container.margin,
                    left = 10,
                },
                s.mytaglist,
                {
                    widget = wibox.container.margin,
                    right = 20,
                },
                s.mytasklist,
                s.mypromptbox,
            },
            mytextclock, -- Middle widget
            {
                layout = wibox.layout.fixed.horizontal,
                mykeyboardlayout,
                s.mylayoutbox,
            },
        })
        return
    end

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(layout_buttons))
    -- Create a taglist widget
    s.mytaglist = custom_widgets.underlined_taglist({
        screen = s,
        buttons = taglist_buttons,
        filter = awful.widget.taglist.filter.all,
    })
    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist({
        screen = s,
        -- filter = awful.widget.tasklist.filter.currenttags,
        filter = awful.widget.tasklist.filter.focused,
        buttons = tasklist_buttons,
    })

    -- Create the wibox
    s.mywibar = awful.wibar({ position = "top", screen = s })

    -- Custom widgets
    local separator = wibox.widget({
        {
            forced_width = 5,
            forced_height = beautiful.wibar_height - dpi(4),
            thickness = 1,
            color = beautiful.fg_normal,
            widget = wibox.widget.separator,
        },
        valign = "center",
        halign = "center",
        widget = wibox.container.place,
    })
    local colon = wibox.widget({
        text = ":",
        widget = wibox.widget.textbox,
    })

    -- local pacman_widget = require("awesome-wm-widgets.pacman-widget.pacman")
    -- local cpu_widget = require("awesome-wm-widgets.cpu-widget.cpu-widget")
    -- local ram_widget = require("awesome-wm-widgets.ram-widget.ram-widget")
    -- local fs_widget = require("awesome-wm-widgets.fs-widget.fs-widget")
    -- local net_speed_widget = require("awesome-wm-widgets.net-speed-widget.net-speed")
    -- local weather_widget = require("awesome-wm-widgets.weather-widget.weather")
    -- Add widgets to the wibox
    s.mywibar:setup({
        layout = wibox.layout.align.horizontal,
        expand = "none",
        {
            -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            {
                widget = wibox.container.margin,
                left = 10,
            },
            s.mytaglist,
            {
                widget = wibox.container.margin,
                right = 20,
            },
            s.mytasklist,
            s.mypromptbox,
        },
        mytextclock, -- Middle widget
        {
            -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            -- net_speed_widget(),
            separator,
            wibox.widget({
                text = "󰻠",
                font = "FiraCode 25",
                widget = wibox.widget.textbox,
            }),
            colon,
            -- cpu_widget({
            -- 	enable_kill_button = true,
            -- 	width = 40,
            -- 	step_width = 2,
            -- 	step_spacing = 1,
            -- 	color = "#434c5e",
            -- }),
            separator,
            wibox.widget({
                markup = "󰍛",
                font = "FiraCode 25",
                widget = wibox.widget.textbox,
            }),
            colon,
            -- ram_widget(),
            separator,
            wibox.widget({
                markup = "󰋊",
                font = "FiraCode 25",
                widget = wibox.widget.textbox,
            }),
            colon,
            -- fs_widget({ mounts = { "/", "/home" } }),
            separator,
            -- pacman_widget({
            -- 	interval = 600, -- Refresh every 10 minutes
            -- 	popup_bg_color = "#222222",
            -- 	popup_border_width = 1,
            -- 	popup_border_color = "#7e7e7e",
            -- 	popup_height = 10, -- 10 packages shown in scrollable window
            -- 	popup_width = 300,
            -- 	polkit_agent_path = "/usr/bin/lxqt-policykit-agent",
            -- }),
            separator,
            separator,
            -- weather_widget({
            -- 	coordinates = { 62.0861, 129.7376 },
            -- 	time_format_12h = false,
            -- 	units = "metric",
            -- 	both_units_widget = false,
            -- 	font_name = "FiraCode",
            -- 	icons = "VitalyGorbachev",
            -- 	icons_extension = ".svg",
            -- 	show_hourly_forecast = true,
            -- 	show_daily_forecast = true,
            -- }),
            custom_widgets.todo_widget(),
            separator,
            mykeyboardlayout,
            wibox.widget.systray({
                forced_height = 5,
            }),
            s.mylayoutbox,
        },
    })
end)
-- }}}

clientbuttons = gears.table.join(
    awful.button({}, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
    end),
    awful.button({ modkey }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            -- placement = awful.placement.no_overlap + awful.placement.no_offscreen,
            -- placement = awful.placement.centered,
            maximized_vertical = false,
            maximized_horizontal = false,
            -- floating = false,
            maximized = false,
        },
    },
    {
        -- center normal floating windows
        rule_any = { type = { "normal" } },
        properties = {
            placement = awful.placement.centered,
        },
    },

    -- Floating clients.
    {
        rule_any = {
            instance = {
                "DTA",   -- Firefox addon DownThemAll.
                "copyq", -- Includes session name in class.
                "pinentry",
                "joplin",
            },
            class = {
                "Arandr",
                "Blueman-manager",
                "Gpick",
                "Kruler",
                "MessageWin",  -- kalarm.
                "Sxiv",
                "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
                "Wpa_gui",
                "veromix",
                "xtightvncviewer",
                "KeePassXC",
                "gnome-screenshot",
                " ",
            },
            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name = {
                "Event Tester", -- xev.
                "win0",         -- Jetbrains IDE logo
                "Unity",        -- Unity Editor
                "galculator",
            },
            role = {
                "AlarmWindow",   -- Thunderbird's calendar.
                "ConfigManager", -- Thunderbird's about:config.
                "pop-up",        -- e.g. Google Chrome's (detached) Developer Tools.
            },
            type = { "dialog" },
        },
        properties = { floating = true, ontop = true },
    },
    {
        rule = { name = "ArchLinux Logout" },
        properties = {
            fullscreen = true,
            y = 0,
        },
    },

    -- Add titlebars to normal clients and dialogs
    --{ rule_any = { type = { "normal", "dialog" }
    --}, properties = { titlebars_enabled = true }
    --},

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
    --   properties = { tag = tags[2] } },

    -- Pin apps to particular tabs
    -- { rule = { class = "Vmware" }, properties = { tag = "4:VM" } },
    -- { rule = { class = "Lutris" }, properties = { tag = "5:Games" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then
        awful.client.setslave(c)
    end

    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end

    c.shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, beautiful.client_corner_radius)
    end
    -- Center dialogs over parent
    if c.transient_for then
        awful.placement.centered(c, {
            parent = c.transient_for,
        })
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({}, 1, function()
            c:emit_signal("request::activate", "titlebar", { raise = true })
            awful.mouse.client.move(c)
        end),
        awful.button({}, 3, function()
            c:emit_signal("request::activate", "titlebar", { raise = true })
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c):setup({
        {
            -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout = wibox.layout.fixed.horizontal,
        },
        {
            -- Middle
            {
                -- Title
                align = "center",
                widget = awful.titlebar.widget.titlewidget(c),
            },
            buttons = buttons,
            layout = wibox.layout.flex.horizontal,
        },
        {
            -- Right
            awful.titlebar.widget.titlewidget(c),
            awful.titlebar.widget.floatingbutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton(c),
            awful.titlebar.widget.ontopbutton(c),
            awful.titlebar.widget.closebutton(c),
            layout = wibox.layout.fixed.horizontal(),
        },
        layout = wibox.layout.align.horizontal,
    })
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    --c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
end)

-- Autostart script run only on first startup
local is_restart
do
    local restart_detected
    is_restart = function()
        -- If we already did restart detection: Just return the result
        if restart_detected ~= nil then
            return restart_detected
        end

        -- Register a new boolean
        awesome.register_xproperty("awesome_restart_check", "boolean")
        -- Check if this boolean is already set
        restart_detected = awesome.get_xproperty("awesome_restart_check") ~= nil
        -- Set it to true
        awesome.set_xproperty("awesome_restart_check", true)
        -- Return the result
        return restart_detected
    end
end

if not is_restart() then
    awful.util.spawn("/home/rusich/.config/rusich/autostart.sh")
end
awful.util.spawn("nitrogen --restore")
-- }}}

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=4:textwidth=80
