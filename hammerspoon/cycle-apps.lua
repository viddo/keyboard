local apps = { "VSCodium" }
local appsCount = #apps
local currentIdx = nil

-- if app of index i is running, pass it to given fn (otherwise skip)
local withApp = function(i, fn)
  local app = hs.application.get(apps[i])
  if app then
    return fn(app, i)
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
  tryApps(startIdx, function(app, i)
    app:activate()
    currentIdx = i
    return true
  end)
end

-- find current app on load, if any
tryApps(1, function(app, i)
  if app:isFrontmost() then
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
      local didActivateCurrent = withApp(currentIdx, function(app)
        if not app:isFrontmost() then
          app:activate()
          return true
        end
      end)
      if not didActivateCurrent then
        currentIdx = nil
        for i = 1, appsCount do
          withApp(i, function(app)
            app:hide()
          end)
        end
      end
    end
  end
end)
