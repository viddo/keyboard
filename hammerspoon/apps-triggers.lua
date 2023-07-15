-- log = hs.logger.new('apps-trigger.lua', 'debug')

hd = "Hands Down"

watcher = hs.application.watcher.new(function(appName, eventType, app)
  -- log.d('appName', appName)
  -- log.d('evenType', eventType)
  if appName == "zoom.us" or appName == 'FaceTime' then
    if eventType == hs.application.watcher.launched then
      --- stop
      local hdApp = hs.application.get(hd)
      if hdApp then
        hdApp:kill()
      end
    elseif eventType == hs.application.watcher.terminated then
      hs.application.launchOrFocus(hd)
    end
  end
end)
watcher:start()