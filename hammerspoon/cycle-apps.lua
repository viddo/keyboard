local apps = {
  {
    ["name"]= "Code - Insiders",
    ["titlePattern"] = "Dendron"
  }
}
local appsCount = #apps
local currentIdx = nil
-- local log = hs.logger.new('cycle-apps.lua', 'debug')


-- if app of index i is running, pass it to given fn (otherwise skip)
local withApp = function(i, fn)
  local app = hs.application.get(apps[i]["name"])
  if app then
    local titlePattern = apps[i]["titlePattern"]
    if titlePattern then
      local win = app:findWindow(titlePattern)
      if win then
        return fn(app, win, i)
      end
    else
      return fn(app, app:mainWindow(), i)
    end
  end
  return false
end

-- for each app that is running, execute given fn
-- stop trying if fn returns true
local tryApps = function(startIdx, fn)
  for i = startIdx, appsCount do
    local result = withApp(i, fn)
    if result then
      break
    end
  end
end

local findAndShowNextOpenApp = function(startIdx)
  tryApps(startIdx, function(app, win, i)
    win:focus()
    currentIdx = i
    return true
  end)
end

-- find current app on load, if any
tryApps(1, function(app, win, i)
  if app:isFrontmost() and app:focusedWindow() == win then
    currentIdx = i
    return true
  end
end)

hs.hotkey.bind({"cmd", "shift"}, "space", function()
  if currentIdx == nil then
    findAndShowNextOpenApp(1)
  else
    if currentIdx < appsCount then
      currentIdx = currentIdx + 1
      findAndShowNextOpenApp(currentIdx)
    else
      local didActivateCurrent = withApp(currentIdx, function(app, win)
        if not (app:isFrontmost() and app:focusedWindow() == win) then
          win:focus()
          return true
        end
      end)
      if not didActivateCurrent then
        currentIdx = nil
        for i = 1, appsCount do
          withApp(i, function(app, win)
            app:hide()
          end)
        end
      end
    end
  end
end)
