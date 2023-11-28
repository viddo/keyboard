-- log = hs.logger.new('apps-trigger.lua', 'debug')

hd = "Hands Down"

function stopHandsDown()
  local hdApp = hs.application.get(hd)
  if hdApp then
    hdApp:kill()
  end
end

function startHandsDown()
  hs.application.launchOrFocus(hd)
end

watcher = hs.application.watcher.new(function(appName, eventType, app)
  -- log.d('appName', appName)
  -- log.d('evenType', eventType)
  if appName == "zoom.us" or appName == 'FaceTime' then
    if eventType == hs.application.watcher.launched then
      stopHandsDown()
    elseif eventType == hs.application.watcher.terminated then
      startHandsDown()
    end 
  end
end)
watcher:start()

local wf=hs.window.filter
wf_slack = wf.new(false):setAppFilter('Slack', { allowTitles = 'Huddle' }) -- Any Slack windows with "huddle" anywhere in the title
wf_slack:subscribe(wf.hasWindow, stopHandsDown)
wf_slack:subscribe(wf.hasNoWindows, startHandsDown)
