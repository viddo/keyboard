-- Show visual cue when pressed next to apple icon in top-left corner
canvas = require("hs.canvas")
visualCue = canvas.new{x = 1, y = 1, h = 50, w = 50}
visualCue[1] = {
  frame = { h = 50, w = 20, x = 0, y = -35 },
  text = hs.styledtext.new(".", {
    font = { name = ".AppleSystemUIFont", size = 50 },
    color = hs.drawing.color.red,
    paragraphStyle = { alignment = "center" }
  }),
  type = "text",
}

hyper = false
hyperTime = nil
runningAppleScript = false

createAppLauncher = function(name, altName)
  return function()
    local app = hs.application.get(name) or hs.application.get(altName or "")
    if app then
      if app:isFrontmost() then
        app:hide()
      else
        app:activate()
      end
    else 
      hs.notify.new({
        title = 'Hammerspoon',
        informativeText = "Open " .. name .. " to focus on it using this shortcut",
        withdrawAfter=2
      }):send()
    end
  end
end

doKeyStroke = function(key)
  return function()
    hs.eventtap.keyStroke(nil, key, 0)
  end
end

charToAction = {
  -- 1st row
  ['q'] = createAppLauncher('iTerm', 'iTerm2'),
  ['w'] = createAppLauncher('Google Chrome'),
  ['e'] = createAppLauncher('Visual Studio Code', 'Code'),
  ['r'] = createAppLauncher('Dropbox Paper'),
  ['t'] = createAppLauncher('Slack'),

  -- 2nd row
  ['f'] = createAppLauncher('Finder'),
  ['g'] = createAppLauncher('GitHub Desktop'),
  ['h'] = doKeyStroke("left"),
  ['j'] = doKeyStroke("down"),
  ['k'] = doKeyStroke("up"),
  ['l'] = doKeyStroke("right"),
}

-- 3rd row
launchSpotify = createAppLauncher('Spotify')
charToAction['m'] = function()
  if hs.application.get("Music") then -- Music take presedence over Spotify
    hs.application.launchOrFocus("Music")
  else
    launchSpotify()
  end
end
charToAction['n'] = createAppLauncher('Notes')

down = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
  local char = event:getCharacters()
  if char == ";" then
    hyper = true
    if hyperTime == nil then
      hyperTime = hs.timer.absoluteTime()
    end
    visualCue:show()
    return true
  end

  if hyper then
    hyperTime = nil

    local action = charToAction[char]
    if action then
      action()
      return true -- Prevent keys from emitting characters while ; is pressed 
    end
  end
end)
down:start()

up = hs.eventtap.new({hs.eventtap.event.types.keyUp}, function(event)
  local char = event:getCharacters()
  if char == ";" and hyper then
    visualCue:hide()
    local currentTime = hs.timer.absoluteTime()
    if hyperTime ~= nil and (currentTime - hyperTime) / 1000000 < 250 then
      down:stop()
      hs.eventtap.keyStrokes(";")
      down:start()
    end
    hyper = false
    hyperTime = nil
  end
end)
up:start()
