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

-- Modifications:
--  - Changed paths to match this repo
--  - Show all stored layouts in menubar (only current one is possible to use)
--  - Show notifications on successful changes
--  - Restore layout automatically on screen change
--  - Simplify layout format, to {appName:winFrame}, so whatever file/tab/title doesn't matter

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
local prevLayoutName = ''

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
    local appName = app:name()
    if appName then
      fnutils.each(app:allWindows(), function (win)
        if win and win:isStandard() and win:isVisible() then
          local winFrame = win:frame()
          -- caveat: this will only store last "valid" window frame for any given app e.g. "Google Chrome" and canary
          -- have same appName, but could potentially be distinguished by window title (which contains it) but would
          -- have to do some per-known-app exceptions handling in that case. for now this is good enough
          if winFrame and winFrame.h > 1 then
            windows[appName] = winFrame.table
          end
        end
      end)
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
  hs.notify.new({
    title = 'Hammerspoon',
    informativeText = "Saved window layout for " .. getLayoutName()
  }):send()
  module.updateMenubar()
  return screenLayout
end

-- also match patterns http://www.lua.org/pil/20.2.html
function module.restoreLayout( ... )
  log.i("Trying to restore window layout...")
  local storedLayouts = getStoredLayouts()
  local currentLayoutName = getLayoutName()
  local currentLayout = storedLayouts[currentLayoutName]

  -- the watcher that calls this functon is called sporadically, so make sure to
  -- only update if the layout actually changed
  if not (currentLayoutName == prevLayoutName) then
    prevLayoutName = currentLayoutName

    if currentLayout then
      log.d("Found layout for: " .. getLayoutName())
      fnutils.each(application.runningApplications(), function (app)
        local savedFrame = currentLayout[app:name()]
        if savedFrame then
          log.i('Found frame for app, ' .. hs.inspect(savedFrame))
          fnutils.each(app:allWindows(), function (win)
            if win and win:isStandard() and win:isVisible() then
              win:setFrame(savedFrame, 0)
            end
          end)
        end
      end)
      module.updateMenubar()
      hs.notify.new({
        title = 'Hammerspoon',
        informativeText = "Restored window layout for " .. getLayoutName()
      }):send()
    else
      log.i("No saved layout found for: " .. getLayoutName())
    end
  end
end

function module.start()
  local menubar = menubar.new()
  module.menubar = menubar

  -- icon path must match ~/.hammerspoon/keyboard symlink:
  menubar:setIcon("./keyboard/screenlayout.pdf")

  module.updateMenubar()

  local screenWatcher = screen.watcher.new(function()
    module.updateMenubar()
    module.restoreLayout()
  end)
  screenWatcher:start()
end

function module.updateMenubar()
  local menuitems = {
    { title = "Save Current Window Layout", fn = module.saveLayout },
  }

  local i = 1
  local layoutName = getLayoutName()
  local screenLayouts = getStoredLayouts()

  -- Prepend stored layouts
  -- Current layout can be used to restore current stored layout
  for name, layout in pairs(screenLayouts) do
    local isCurrentLayout = name == layoutName
    local title = name
    if isCurrentLayout then
      title = "Restore " .. name
    end
    table.insert(menuitems, i, {
      title = title,
      disabled = not isCurrentLayout,
      fn = module.restoreLayout
    })
    i = i + 1
  end

  -- Divider
  table.insert(menuitems, i, { title = "-" })

  module.menubar:setMenu(menuitems)
end

return module
