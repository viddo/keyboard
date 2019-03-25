-- The MIT License (MIT)
--
-- Copyright (c) 2015, Christian Inzinger
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
---
-- Original source from https://github.com/inz/hammerspoon-config/blob/2087b3e2527ad468ab60436a497f6a3fa0bcde04/extensions/screenlayout.lua
-- Slightly modified to work with my setup

--- === screenlayout ===
---
--- Save and restore window layouts

local module = {}

local CONFIG = "./screenlayout.conf" -- => ~/.hammerspoon/

local application = require "hs.application"
local fnutils = require "hs.fnutils"
local menubar = require "hs.menubar"
local screen = require "hs.screen"
local window = require "hs.window"
local inspect = require "hs.inspect"
local logger = require "hs.logger"
local log = logger.new('scrlayout')

module.DEBUG = false

local function table_length(table)
  local count = 0
  for _ in pairs(table) do
    count = count + 1
  end
  return count
end

local function table_equals(aTable, otherTable)
  if aTable == otherTable then return true end
  if aTable == nil or otherTable == nil or #aTable ~= #otherTable then
    return false
  end
  for key, value in pairs(aTable) do
    if aTable[key] ~= otherTable[key] then return false end
  end
  return true
end

local function serialize(o)
  local result = {}
  if type(o) == "number" then
    table.insert(result, o)
  elseif type(o) == "string" then
    table.insert(result, string.format("%q", o))
  elseif type(o) == "table" then
    table.insert(result, "{\n")
    for k, v in pairs(o) do
      table.insert(result, "  [")
      table.insert(result, serialize(k))
      table.insert(result, "] = ")
      table.insert(result, serialize(v))
      table.insert(result, ",\n")
    end
    table.insert(result, "}\n")
  else
    error("cannot serialize a " .. type(o))
  end
  return table.concat(result, "")
end

local function getLayoutName()
  local screens = fnutils.map(screen.allScreens(), function (screen)
      return screen:name()
  end)
  table.sort(screens)
  return inspect(screens)
end

local function getStoredLayouts()
  local config = loadfile(CONFIG)
  if not config then return {} end
  return config()
end

local function getCurrentLayout()
  local screenLayout = getStoredLayouts()

  windows = screenLayout[getLayoutName()] or {}
  fnutils.each(application.runningApplications(), function (app)
    if app:bundleID() then
      local appentry = windows[app:bundleID()] or {}

      fnutils.each(app:allWindows(), function (win)
        if win and win:frame() and win:frame().h > 1 and win:title() then
          appentry[win:title()] = win:frame().table
        end
      end)

      if table_length(appentry) > 0 then
        log.i("Adding " .. app:bundleID() .. " to layout.")
        windows[app:bundleID()] = appentry
      end
    else
      log.i("Found app without bundle ID: pid:" .. app:pid() .. ", title: " .. app:title())
      if app:title() == "quartz-wm" then
        fnutils.each(app:allWindows(), function (win)
          log.i("found " .. win:title())
          if win and win:frame() and win:frame().h > 1 and win:title() then
            appentry[win:title()] = win:frame().table
          end
        end)
      end
    end
  end)

  screenLayout[getLayoutName()] = windows
  return screenLayout
end

function module.getCurrentLayout()
  return getCurrentLayout()
end

function module.saveLayout()
  log.i("Saving current window layout...")
  local screenLayout = getCurrentLayout()
  local config = assert(io.open(CONFIG, "w"))
  config:write("-- Screen layouts as saved on " .. os.date() .. "\n")
  config:write("return " .. inspect(screenLayout))
  config:close()
  log.i("Window layout saved.")
  return screenLayout
end

-- also match patterns http://www.lua.org/pil/20.2.html
function module.restoreLayout( ... )
  log.i("Restoring window layout for " .. getLayoutName() .. "...")
  local storedLayouts = getStoredLayouts()
  local currentLayout = storedLayouts[getLayoutName()]
  if currentLayout then
    log.d("Found layout for: " .. getLayoutName())
    for bundleID, windows in pairs(currentLayout) do
      fnutils.each(application.applicationsForBundleID(bundleID), function(app)
        log.d("  found app " .. bundleID)
        fnutils.each(app:visibleWindows(), function(win)
          if win:title() and windows[win:title()] then
            log.d("    found window " .. win:title() .. "")
            win:setFrame(windows[win:title()], 0)
          end
        end)
      end)
    end
  else
    log.i("No saved layout found for: " .. getLayoutName())
  end
end

function module.start()
  local menubar = menubar.new()
  module.menubar = menubar

  menuitems = {
    { title = "Save Current Window Layout", fn = module.saveLayout },
    { title = "Restore Window Layout", fn = module.restoreLayout },
  }

  if module.DEBUG then
    table.insert(menuitems, 1, { title = "Screens: " .. getLayoutName(), disabled = true})
    table.insert(menuitems, 2, { title = "-"})
  end

  -- menubar:setTitle("W")
  -- icon path must match ~/.hammerspoon/keyboard symlink:
  menubar:setIcon("./keyboard/screenlayout.pdf")
  menubar:setMenu(menuitems)

  module.restoreLayout()
end

return module
