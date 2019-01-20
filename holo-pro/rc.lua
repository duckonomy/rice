-- {{{ Required libraries
local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type

-- require("collision")()

local gears         = require("gears")
local awful         = require("awful")
require("awful.autofocus")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local lain          = require("lain")
local freedesktop   = require("freedesktop")

local hotkeys_popup = require("awful.hotkeys_popup").widget
require("awful.hotkeys_popup.keys")
local my_table      = awful.util.table or gears.table -- 4.{0,1} compatibility
-- }}}

naughty.config.defaults['icon_size'] = 100


-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
   naughty.notify({ preset = naughty.config.presets.critical,
                    title = "Oops, there were errors during startup!",
                    text = awesome.startup_errors })
end


-- Handle runtime errors after startup
do
   local in_error = false
   awesome.connect_signal("debug::error", function (err)
                             if in_error then return end
                             in_error = true

                             naughty.notify({ preset = naughty.config.presets.critical,
                                              title = "Oops, an error happened!",
                                              text = tostring(err) })
                             in_error = false
   end)
end
-- }}}

-- }}}

-- {{{ Variable definitions
local modkey       = "Mod4"
local altkey       = "Mod1"
local terminal     = "alacritty"
local guitaskman   = "lxtask"
local editor       = os.getenv("EDITOR") or "vim"
local browser      = "google-chrome-stable"
local guieditorc   = "emacsclient -c"
local guieditor    = "emacs"
local guifileman   = "pcmanfm"
local taskman      = terminal .. " -e tmux"
local fileman      = terminal .. " -e nnn"
local ncmpcpp      = terminal .. " -e ncmpcpp"
local weechat      = terminal .. " -e weechat"
local dmenu        = "$HOME/bin/launch/dmenu-launch"
local rofi         = "rofi -show run"
local monitor_layout = "$HOME/bin/rofi/monitor_layout"
local scrlocker    = "$HOME/bin/lock"

awful.util.terminal = terminal
awful.util.tagnames = { "1", "2", "3", "4", "5" }
awful.layout.layouts = {
   awful.layout.suit.tile,
   -- awful.layout.suit.tile
   -- awful.layout.suit.tile
   -- awful.layout.suit.tile
   -- awful.layout.suit.tile
   -- awful.layout.suit.tile.left,
   -- awful.layout.suit.floating,
   -- awful.layout.suit.tile.bottom,
   -- awful.layout.suit.tile.top,
   -- awful.layout.suit.fair,
   -- awful.layout.suit.spiral,
   -- awful.layout.suit.fair.horizontal,
   -- awful.layout.suit.spiral.dwindle,
   awful.layout.suit.max,
   -- awful.layout.suit.max.fullscreen,
   -- awful.layout.suit.magnifier,
   -- awful.layout.suit.corner.nw,
   -- awful.layout.suit.corner.ne,
   -- awful.layout.suit.corner.sw,
   -- awful.layout.suit.corner.se,
   -- lain.layout.cascade,
   -- lain.layout.cascade.tile,
   -- lain.layout.centerwork,
   -- lain.layout.centerwork.horizontal,
   -- lain.layout.termfair,
   -- lain.layout.termfair.center,
}

awful.util.taglist_buttons = my_table.join(
   awful.button({ }, 1, function(t) t:view_only() end),
   awful.button({ modkey }, 1, function(t)
         if client.focus then
            client.focus:move_to_tag(t)
         end
   end),
   awful.button({ }, 3, awful.tag.viewtoggle),
   awful.button({ modkey }, 3, function(t)
         if client.focus then
            client.focus:toggle_tag(t)
         end
   end),
   awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end),
   awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end)
)

awful.util.tasklist_buttons = my_table.join(
   awful.button({ }, 1, function (c)
         if c == client.focus then
            c.minimized = true
         else
            c.minimized = false
            if not c:isvisible() and c.first_tag then
               c.first_tag:view_only()
            end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
            c:raise()
         end
   end),
   awful.button({ }, 2, function (c) c:kill() end),
   awful.button({ }, 3, function ()
         local instance = nil

         return function ()
            if instance and instance.wibox.visible then
               instance:hide()
               instance = nil
            else
               instance = awful.menu.clients({theme = {width = 250}})
            end
         end
   end),
   awful.button({ }, 5, function () awful.client.focus.byidx(1) end),
   awful.button({ }, 4, function () awful.client.focus.byidx(-1) end)
)

lain.layout.termfair.nmaster           = 3
lain.layout.termfair.ncol              = 1
lain.layout.termfair.center.nmaster    = 3
lain.layout.termfair.center.ncol       = 1
lain.layout.cascade.tile.offset_x      = 2
lain.layout.cascade.tile.offset_y      = 32
lain.layout.cascade.tile.extra_padding = 5
lain.layout.cascade.tile.nmaster       = 5
lain.layout.cascade.tile.ncol          = 2

beautiful.init(string.format("%s/.config/awesome/theme/theme.lua", os.getenv("HOME")))
-- }}}

-- {{{ Menu
local myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", string.format("%s %s", guieditorc, awesome.conffile) },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end }
}
awful.util.mymainmenu = freedesktop.menu.build({
      icon_size = beautiful.menu_height or 32,
      before = {
         { "Awesome", myawesomemenu, beautiful.awesome_icon },
         -- other triads can be put here
      },
      after = {
         { "Open terminal", terminal },
         -- other triads can be put here
      }
})


-- {{{ Screen
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s)
                         -- Wallpaper
                         if beautiful.wallpaper then
                            local wallpaper = beautiful.wallpaper
                            -- If wallpaper is a function, call it with the screen
                            if type(wallpaper) == "function" then
                               wallpaper = wallpaper(s)
                            end
                            gears.wallpaper.maximized(wallpaper, s, true)
                         end
end)
-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s)
      s.systray = wibox.widget.systray()
      s.systray.visible = false
      beautiful.at_screen_connect(s) end)
-- }}}

-- {{{ Mouse bindings
root.buttons(my_table.join(
                awful.button({ }, 3, function () awful.util.mymainmenu:toggle() end),
                awful.button({ }, 5, awful.tag.viewnext),
                awful.button({ }, 4, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = my_table.join(
   -- Take a screenshot
   awful.key({ }, "Print", function() awful.spawn.with_shell("$HOME/bin/screenshot") end,
      {description = "take a screenshot", group = "hotkeys"}),

   -- X screen locker
   awful.key({ modkey,   }, "F4", function () awful.spawn(scrlocker) end,
      {description = "lock screen", group = "hotkeys"}),

   -- Hotkeys
   awful.key({ modkey,           }, "Escape",      hotkeys_popup.show_help,
      {description = "show help", group="awesome"}),

   awful.key({ modkey         }, "\\", function ()
         awful.screen.focused().systray.visible = not awful.screen.focused().systray.visible
                                       end, {description = "Toggle systray visibility", group = "custom"}),


   -- Tag browsing
   awful.key({ modkey,           }, "[",   awful.tag.viewprev,
      {description = "view previous", group = "tag"}),
   awful.key({ modkey,           }, "]",  awful.tag.viewnext,
      {description = "view next", group = "tag"}),
   awful.key({ modkey, "Shift"   }, "\\", awful.tag.history.restore,
      {description = "go back", group = "tag"}),

   -- Non-empty tag browsing
   awful.key({ modkey, "Shift"   }, "[", function () lain.util.tag_view_nonempty(-1) end,
      {description = "view  previous nonempty", group = "tag"}),
   awful.key({ modkey, "Shift"   }, "[", function () lain.util.tag_view_nonempty(1) end,
      {description = "view  previous nonempty", group = "tag"}),


   -- Default client focus
   awful.key({ modkey,           }, "n",
      function ()
         awful.client.focus.byidx( 1)
      end,
      {description = "focus next by index", group = "client"}
   ),
   awful.key({ modkey,           }, "p",
      function ()
         awful.client.focus.byidx(-1)
      end,
      {description = "focus previous by index", group = "client"}
   ),

   awful.key({ modkey,           }, "Tab",
      function ()
         awful.client.focus.byidx( 1)
      end,
      {description = "focus next by index", group = "client"}
   ),
   awful.key({ modkey,   "Shift" }, "Tab",
      function ()
         awful.client.focus.byidx(-1)
      end,
      {description = "focus previous by index", group = "client"}
   ),

   -- Layout manipulation
   awful.key({ modkey, "Shift"   }, "n", function () awful.client.swap.byidx(  1)    end,
      {description = "swap with next client by index", group = "client"}),
   awful.key({ modkey, "Shift"   }, "p", function () awful.client.swap.byidx( -1)    end,
      {description = "swap with previous client by index", group = "client"}),
   awful.key({ modkey,           }, "`", function () awful.screen.focus_relative( 1) end,
      {description = "focus the next screen", group = "screen"}),
   awful.key({ modkey,  altkey   }, "`", function () awful.screen.focus_relative(-1) end,
      {description = "focus the previous screen", group = "screen"}),
   awful.key({ modkey,           }, "F1", awful.client.urgent.jumpto,
      {description = "jump to urgent client", group = "client"}),

   -- Show/Hide Wibox
   awful.key({ modkey }, "b", function ()
         for s in screen do
            s.mywibox.visible = not s.mywibox.visible
            if s.mybottomwibox then
               s.mybottomwibox.visible = not s.mybottomwibox.visible
            end
         end
                              end,
      {description = "toggle wibox", group = "awesome"}),

   -- On the fly useless gaps change
   awful.key({ modkey,  "Shift"  }, "=", function () lain.util.useless_gaps_resize(1) end,
      {description = "increment useless gaps", group = "tag"}),
   awful.key({ modkey,  "Shift"  }, "-", function () lain.util.useless_gaps_resize(-1) end,
      {description = "decrement useless gaps", group = "tag"}),

   -- Dynamic tagging
   awful.key({ modkey, "Shift" }, "F1", function () lain.util.add_tag() end,
      {description = "add new tag", group = "tag"}),
   awful.key({ modkey, "Shift" }, "F2", function () lain.util.rename_tag() end,
      {description = "rename tag", group = "tag"}),
   awful.key({ modkey, "Shift" }, "F3", function () lain.util.delete_tag() end,
      {description = "delete tag", group = "tag"}),
   awful.key({ modkey,  altkey }, "[", function () lain.util.move_tag(-1) end,
      {description = "move tag to the left", group = "tag"}),
   awful.key({ modkey,  altkey }, "]", function () lain.util.move_tag(1) end,
      {description = "move tag to the right", group = "tag"}),

   -- Standard program
   awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
      {description = "open a terminal", group = "launcher"}),
   awful.key({ modkey, }, "F7", awesome.restart,
      {description = "reload awesome", group = "awesome"}),
   awful.key({ modkey, "Shift"   }, "Escape", awesome.quit,
      {description = "quit awesome", group = "awesome"}),

   awful.key({ modkey, altkey }, "=", function () awful.spawn("reboot") end,
      {description = "run browser", group = "launcher"}),

   awful.key({ modkey, altkey }, "-", function () awful.spawn("poweroff") end,
      {description = "run browser", group = "launcher"}),

   awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
      {description = "select next", group = "layout"}),
   awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
      {description = "select previous", group = "layout"}),
   awful.key({ modkey, "Control" }, "n",
      function ()
         local c = awful.client.restore()
         -- Focus restored client
         if c then
            client.focus = c
            c:raise()
         end
      end,
      {description = "restore minimized", group = "client"}),

   -- Widgets popups
   awful.key({ modkey, }, "F9", function () if beautiful.cal then beautiful.cal.show(7) end end,
         {description = "show calendar", group = "widgets"}),
   awful.key({ modkey, altkey }, "F9", function () if beautiful.fs then beautiful.fs.show(7) end end,
         {description = "show filesystem", group = "widgets"}),
   awful.key({ modkey, "Shift" }, "F9", function () if beautiful.weather then beautiful.weather.show(7) end end,
         {description = "show weather", group = "widgets"}),

   -- Brightness
   awful.key({ }, "XF86MonBrightnessUp", function () awful.spawn.with_shell("$HOME/bin/brightness/up") end,
      {description = "+10%", group = "hotkeys"}),
   awful.key({ }, "XF86MonBrightnessDown", function () awful.spawn.with_shell("$HOME/bin/brightness/down") end,
      {description = "-10%", group = "hotkeys"}),

   awful.key({modkey }, "=", function () awful.spawn.with_shell("$HOME/bin/brightness/up") end,
      {description = "+10%", group = "hotkeys"}),
   awful.key({modkey }, "-", function () awful.spawn.with_shell("$HOME/bin/brightness/down") end,
      {description = "-10%", group = "hotkeys"}),

   awful.key({modkey }, "F12", function () awful.spawn("networkmanager_dmenu") end,
      {description = "networkmanager", group = "hotkeys"}),

   awful.key({modkey }, "F11", function () awful.spawn("passmenu") end,
      {description = "passwords", group = "hotkeys"}),

   awful.key({modkey }, "F10", function () awful.spawn("restartemacs") end,
      {description = "restart emacs", group = "hotkeys"}),

   -- ALSA volume control
   awful.key({ modkey }, "0",
      function ()
         awful.spawn.with_shell("$HOME/bin/volume/up")
         -- beautiful.volume.update()
      end,
      {description = "volume up", group = "hotkeys"}),
   awful.key({ modkey }, "9",
      function ()
         awful.spawn.with_shell("$HOME/bin/volume/down")
         -- beautiful.volume.update()
      end,
      {description = "volume down", group = "hotkeys"}),
   awful.key({ modkey }, "8",
      function ()
         awful.spawn.with_shell("$HOME/bin/volume/mute")
         -- beautiful.volume.update()
      end,
      {description = "toggle mute", group = "hotkeys"}),

   awful.key({ }, "XF86AudioRaiseVolume",
      function ()
         awful.spawn.with_shell("$HOME/bin/volume/up")
         beautiful.volume.update()
      end,
      {description = "volume up", group = "hotkeys"}),
   awful.key({ }, "XF86AudioLowerVolume",
      function ()
         awful.spawn.with_shell("$HOME/bin/volume/down")
         beautiful.volume.update()
      end,
      {description = "volume down", group = "hotkeys"}),
   awful.key({ }, "XF86AudioMute",
      function ()
         awful.spawn.with_shell("$HOME/bin/volume/mute")
         beautiful.volume.update()
      end,
      {description = "toggle mute", group = "hotkeys"}),

   -- MPD control
   awful.key({ modkey,        }, "/",
      function ()
         awful.spawn("mpc toggle")
         beautiful.mpd.update()
      end,
      {description = "mpc toggle", group = "widgets"}),
   awful.key({ modkey,        }, "'",
      function ()
         awful.spawn("mpc stop")
         beautiful.mpd.update()
      end,
      {description = "mpc stop", group = "widgets"}),
   awful.key({ modkey,        }, ",",
      function ()
         awful.spawn("mpc prev")
         beautiful.mpd.update()
      end,
      {description = "mpc prev", group = "widgets"}),
   awful.key({ modkey,        }, ".",
      function ()
         awful.spawn("mpc next")
         beautiful.mpd.update()
      end,
      {description = "mpc next", group = "widgets"}),


   -- -- Copy primary to clipboard (terminals to gtk)
   awful.key({ modkey, altkey }, "c", function () awful.spawn.with_shell("xsel | xsel -i -b") end,
      {description = "copy terminal to gtk", group = "hotkeys"}),
   -- Copy clipboard to primary (gtk to terminals)
   awful.key({ modkey, altkey }, "v", function () awful.spawn.with_shell("xsel -b | xsel") end,
      {description = "copy gtk to terminal", group = "hotkeys"}),

   -- User programs
   awful.key({ modkey }, "w", function () awful.spawn(browser) end,
      {description = "run browser", group = "launcher"}),
   awful.key({ modkey }, "e", function () awful.spawn(guieditorc) end,
      {description = "run emacsclient", group = "launcher"}),
   awful.key({ modkey, "Shift" }, "e", function () awful.spawn(guieditor) end,
      {description = "run emacs", group = "launcher"}),
   awful.key({ modkey, "Shift" }, "d", function () awful.spawn(guifileman) end,
      {description = "run file manager", group = "launcher"}),
   awful.key({ modkey,         }, "d", function () awful.spawn(fileman) end,
      {description = "run nnn", group = "launcher"}),
   awful.key({ modkey,         }, ";", function () awful.spawn(ncmpcpp) end,
      {description = "run ncmpcpp", group = "launcher"}),
   awful.key({ modkey,         }, "x", function () awful.spawn(weechat) end,
      {description = "run weechat", group = "launcher"}),


   -- Prompt
   awful.key({ modkey, altkey }, "s", function ()
         awful.spawn(string.format("dmenu_run -i -p 'Run >' -l 9 -w 640 -h 32 -x 640 -y 400 -dim 0.4 -fn 'Roboto-10:Medium' \
          -nb '%s' -nf '%s' \
          -sb '%s' -sf '%s'", beautiful.bg_normal, beautiful.fg_normal, beautiful.bg_focus, beautiful.fg_focus)) end,
      {description = "show dmenu", group = "launcher"}),

   awful.key({ modkey          }, "r", function () awful.screen.focused().mypromptbox:run() end,
      {description = "run prompt", group = "launcher"}),

   awful.key({ modkey         }, "s", function () awful.spawn(rofi) end,
      {description = "run rofi", group = "launcher"}),


   awful.key({ modkey, "Shift" }, "s", function () awful.spawn.with_shell(monitor_layout) end,
      {description = "run monitor", group = "launcher"}),

   awful.key({ modkey, "Shift" }, "r",
      function ()
         awful.prompt.run {
            prompt       = "Run Lua code: ",
            textbox      = awful.screen.focused().mypromptbox.widget,
            exe_callback = awful.util.eval,
            history_path = awful.util.get_cache_dir() .. "/history_eval"
         }
      end,
      {description = "lua execute prompt", group = "awesome"})
)

clientkeys = my_table.join(
   awful.key({ modkey, "Shift"   }, "a",      lain.util.magnify_client,
      {description = "magnify client", group = "client"}),
   awful.key({ modkey,           }, "f",
      function (c)
         c.fullscreen = not c.fullscreen
         c:raise()
      end,
      {description = "toggle fullscreen", group = "client"}),
   awful.key({ modkey,           }, "c",      function (c) c:kill()                         end,
      {description = "close", group = "client"}),

   awful.key({ modkey, "Shift"   }, "c",    function (c)
         if c.pid then
            awful.spawn("kill -9 " .. c.pid)
         end
      end,
      {description = "close", group = "client"}),

   awful.key({ modkey,           }, "v",  awful.client.floating.toggle                     ,
      {description = "toggle floating", group = "client"}),
   awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
      {description = "move to master", group = "client"}),
   awful.key({ modkey,   "Shift"        }, "`",      function (c) c:move_to_screen()               end,
      {description = "move to screen", group = "client"}),
   awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
      {description = "toggle keep on top", group = "client"}),

   awful.key({ modkey }, "j",  function (c)
         if c.floating == true then
            c:relative_move(  0,  20,   0,   0)
         else
            awful.client.focus.global_bydirection("down")
            if client.focus then client.focus:raise() end
         end
   end),
   awful.key({ modkey }, "k",  function (c)
         if c.floating == true then
            c:relative_move(  0, -20,   0,   0)
         else
            awful.client.focus.global_bydirection("up")
            if client.focus then client.focus:raise() end
         end
   end),
   awful.key({ modkey }, "h",  function (c)
         if c.floating == true then
            c:relative_move(-20,   0,   0,   0)
         else
            awful.client.focus.global_bydirection("left")
            if client.focus then client.focus:raise() end
         end
   end),
   awful.key({ modkey }, "l",  function (c)
         if c.floating == true then
            c:relative_move( 20,   0,   0,   0)
         else
            awful.client.focus.global_bydirection("right")
            if client.focus then client.focus:raise() end
         end
   end),

   awful.key({ modkey, "Shift"   }, "j", function (c)
         if c.floating == true then
            c:relative_move( 0,  0, 0, 40)
         else
            awful.client.incwfact(0.01)
         end
   end),
   awful.key({ modkey, "Shift"   }, "k", function (c)
         if c.floating == true then
            c:relative_move( 0, 0, 0, -40)
         else
            awful.client.incwfact(-0.01)
         end
   end),
   awful.key({ modkey, "Shift"   }, "h", function (c)
         if c.floating == true then
            c:relative_move( 0,  0, -40, 0)
         else
            awful.tag.incmwfact(-0.01)
         end
   end),
   awful.key({ modkey, "Shift"   }, "l", function (c)
         if c.floating == true then
            c:relative_move( 0,  0, 40, 0)
         else
            awful.tag.incmwfact( 0.01)
         end
   end),

   awful.key({ modkey            }, "g", function (c)
         local f = awful.placement.scale
            + awful.placement.centered
         local geo = f(client.focus, {honor_workarea=true, to_percent = 0.5})
   end),

   awful.key({ modkey, "Shift"   }, "y", function (c)
         local axis = 'vertically'
         local f = awful.placement.scale
            + awful.placement.left
            + (axis and awful.placement['maximize_'..axis] or nil)
         local geo = f(client.focus, {honor_workarea=true, to_percent = 0.5})
   end),

   awful.key({ modkey, "Shift"   }, "o", function (c)
         local axis = 'vertically'
         local f = awful.placement.scale
            + awful.placement.right
            + (axis and awful.placement['maximize_'..axis] or nil)
         local geo = f(client.focus, {honor_workarea=true, to_percent = 0.5})
   end),

   awful.key({ modkey, "Shift"   }, "i", function (c)
         local axis = 'horizontally'
         local f = awful.placement.scale
            + awful.placement.top
            + (axis and awful.placement['maximize_'..axis] or nil)
         local geo = f(client.focus, {honor_workarea=true, to_percent = 0.5})
   end),

   awful.key({ modkey, "Shift"   }, "u", function (c)
         local axis = 'horizontally'
         local f = awful.placement.scale
            + awful.placement.bottom
            + (axis and awful.placement['maximize_'..axis] or nil)
         local geo = f(client.focus, {honor_workarea=true, to_percent = 0.5})
   end),


   awful.key({ modkey }, "i",  function (c)
         if c.floating == true then
            local f = awful.placement.scale
               + awful.placement.bottom_right
            local geo = f(client.focus, {honor_workarea=true, to_percent = 0.5})
         else
            awful.tag.incncol( 1, nil, true)
         end
   end),

   awful.key({ modkey }, "u",  function (c)
         if c.floating == true then
            local f = awful.placement.scale
               + awful.placement.bottom_left
            local geo = f(client.focus, {honor_workarea=true, to_percent = 0.5})
         else
            awful.tag.incncol(-1, nil, true)
         end
   end),

   awful.key({ modkey }, "o",  function (c)
         if c.floating == true then
            local f = awful.placement.scale
               + awful.placement.top_right
            local geo = f(client.focus, {honor_workarea=true, to_percent = 0.5})
         else
            awful.tag.incnmaster( 1, nil, true)
         end
   end),

   awful.key({ modkey }, "y",  function (c)
         if c.floating == true then
            local f = awful.placement.scale
               + awful.placement.top_left
            local geo = f(client.focus, {honor_workarea=true, to_percent = 0.5})
         else
            awful.tag.incnmaster(-1, nil, true)
         end
   end),

   awful.key({ modkey, "Shift"  }, "g", awful.placement.centered),

   awful.key({ modkey,   altkey  }, "a",
      function (c)
         -- The client currently has the input focus, so it cannot be
         -- minimized, since minimized clients can't have the focus.
         c.minimized = true
      end ,
      {description = "minimize", group = "client"}),

   awful.key({ modkey,           }, "a",
      function (c)
         c.maximized = not c.maximized
         c:raise()
      end ,
      {description = "maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 7 do
   -- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
   local descr_view, descr_toggle, descr_move, descr_toggle_focus
   if i == 1 or i == 7 then
      descr_view = {description = "view tag #", group = "tag"}
      descr_toggle = {description = "toggle tag #", group = "tag"}
      descr_move = {description = "move focused client to tag #", group = "tag"}
      descr_toggle_focus = {description = "toggle focused client on tag #", group = "tag"}
   end
   globalkeys = my_table.join(globalkeys,
                              -- View tag only.
                              awful.key({ modkey }, "#" .. i + 9,
                                 function ()
                                    local screen = awful.screen.focused()
                                    local tag = screen.tags[i]
                                    if tag then
                                       tag:view_only()
                                    end
                                 end,
                                 descr_view),
                              -- Toggle tag display.
                              awful.key({ modkey, "Control" }, "#" .. i + 9,
                                 function ()
                                    local screen = awful.screen.focused()
                                    local tag = screen.tags[i]
                                    if tag then
                                       awful.tag.viewtoggle(tag)
                                    end
                                 end,
                                 descr_toggle),
                              -- Move client to tag.
                              awful.key({ modkey, "Shift" }, "#" .. i + 9,
                                 function ()
                                    if client.focus then
                                       local tag = client.focus.screen.tags[i]
                                       if tag then
                                          client.focus:move_to_tag(tag)
                                       end
                                    end
                                 end,
                                 descr_move),
                              -- Toggle tag on focused client.
                              awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                                 function ()
                                    if client.focus then
                                       local tag = client.focus.screen.tags[i]
                                       if tag then
                                          client.focus:toggle_tag(tag)
                                       end
                                    end
                                 end,
                                 descr_toggle_focus)
   )
end

clientbuttons = gears.table.join(
   awful.button({ }, 1, function (c)
         c:emit_signal("request::activate", "mouse_click", {raise = true})
   end),
   awful.button({ modkey }, 1, function (c)
         c:emit_signal("request::activate", "mouse_click", {raise = true})
         awful.mouse.client.move(c)
   end),
   awful.button({ modkey }, 3, function (c)
         c:emit_signal("request::activate", "mouse_click", {raise = true})
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
   { rule = { },
     properties = { border_width = beautiful.border_width,
                    border_color = beautiful.border_normal,
                    focus = awful.client.focus.filter,
                    raise = true,
                    keys = clientkeys,
                    buttons = clientbuttons,
                    screen = awful.screen.preferred,
                    placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                    size_hints_honor = false
     }
   },

   -- Titlebars
   { rule_any = { type = { "dialog", "normal" } },
     properties = { titlebars_enabled = true } },

   -- Set Firefox to always map on the first tag on screen 1.
   -- { rule = { class = "Firefox" },
   --   properties = { screen = 1, tag = awful.util.tagnames[1] } },

   -- { rule = { class = "Gimp", role = "gimp-image-window" },
   --   properties = { maximized = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
                         -- Set the windows at the slave,
                         -- i.e. put it at the end of others instead of setting it master.
                         -- if not awesome.startup then awful.client.setslave(c) end

                         -- c.shape
                         --    = function(cr,w,h)
                         --    gears.shape.rounded_rect(cr,w,h,5)
                         -- end

                         -- or
                         -- c.shape = gears.shape.rounded_rect


                         if awesome.startup and
                            not c.size_hints.user_position
                         and not c.size_hints.program_position then
                            -- Prevent clients from being unreachable after screen count changes.
                            awful.placement.no_offscreen(c)
                         end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
                         -- Custom
                         if beautiful.titlebar_fun then
                            beautiful.titlebar_fun(c)
                            return
                         end

                         -- Default
                         -- buttons for the titlebar
                         local buttons = my_table.join(
                            awful.button({ }, 1, function()
                                  c:emit_signal("request::activate", "titlebar", {raise = true})
                                  awful.mouse.client.move(c)
                            end),
                            -- awful.button({ }, 2, function() c:kill() end),
                            awful.button({ }, 3, function()
                                  c:emit_signal("request::activate", "titlebar", {raise = true})
                                  awful.mouse.client.resize(c)
                            end)
                         )

                         awful.titlebar(c, {size = 32, fg_normal = "#606060", fg_focus = "#FFFFFF"}) : setup {
                            { -- Left
                               awful.titlebar.widget.stickybutton   (c),
                               awful.titlebar.widget.ontopbutton    (c),
                               awful.titlebar.widget.floatingbutton (c),
                               -- buttons = buttons,
                               layout  = wibox.layout.fixed.horizontal
                            },
                            { -- Middle
                               { -- Title
                                  align  = "center",
                                  widget = awful.titlebar.widget.titlewidget(c)
                               },
                               buttons = buttons,
                               layout  = wibox.layout.flex.horizontal
                            },
                            { -- Right
                               awful.titlebar.widget.minimizebutton(c),
                               awful.titlebar.widget.maximizedbutton(c),
                               awful.titlebar.widget.closebutton    (c),
                               layout = wibox.layout.fixed.horizontal()
                            },
                            layout = wibox.layout.align.horizontal
                                                                }
end)

-- No border for maximized clients
function border_adjust(c)
   if c.maximized then -- no borders if only 1 client visible
      c.border_width = 0
   elseif #awful.screen.focused().clients > 1 then
      c.border_width = beautiful.border_width
      c.border_color = beautiful.border_focus
   end
end

client.connect_signal("property::maximized", border_adjust)
client.connect_signal("focus", border_adjust)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- possible workaround for tag preservation when switching back to default screen:
-- https://github.com/lcpz/awesome-copycats/issues/251
-- }}}
