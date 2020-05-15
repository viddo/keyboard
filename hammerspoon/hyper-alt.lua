hyper = false
hyperTime = nil
prevChar = nil
runningAppleScript = false

createAppLauncher = function(name, altName)
  return function()
    local isRunning = hs.application.get(name) or hs.application.get(altName or "")
    -- local app = hs.application.get(name)
    if not isRunning then
      hs.notify.new({
        title = 'Hammerspoon',
        informativeText = "Opening " .. name .. "…",
        withdrawAfter=2
      }):send()
    end
    hs.application.launchOrFocus(name)
  end
end

doKeyStroke = function(key)
  return function()
    hs.eventtap.keyStroke(nil, key, 0)
    -- Reset prev char to avoid toggle behavior
    prevChar = nil
  end
end

charToAction = {
  -- 1st row
  ['q'] = createAppLauncher('iTerm', 'iTerm2'),
  ['w'] = createAppLauncher('Google Chrome'),
  ['e'] = createAppLauncher('Visual Studio Code', 'Code'),
  ['t'] = createAppLauncher('Slack'),

  -- 2nd row
  ['d'] = function()
    -- Reset prev char to avoid toggle behavior
    prevChar = nil
    if not runningAppleScript then
      runningAppleScript = true
      --- Open Dropdox tray, which automatically focused on search input :)
      --- Abort script if it does not execute within reasonable timeout
      local success = hs.osascript.applescript([[
        with timeout of 3 second
          ignoring application responses
            tell application "System Events" to tell UI element "Dropbox"
              click menu bar item 1 of menu bar 2
            end tell
          end ignoring
          delay 0.1
          do shell script "killall System\\ Events"
          tell application "System Events" to tell process "Dropbox"
            tell menu bar item 1 of menu bar 2
              click menu item "Open Dropbox in Menu Bar" of menu 1
            end tell
          end tell
        end timeout
      ]])
      if not success then
        print("Could not trigger Dropbox for whatever reason")
      end
      runningAppleScript = false
    end
  end,
  ['f'] = createAppLauncher('Finder'),
  ['g'] = createAppLauncher('Github Desktop', 'Github'),
  ['h'] = doKeyStroke("left"),
  ['j'] = doKeyStroke("down"),
  ['k'] = doKeyStroke("up"),
  ['l'] = doKeyStroke("right"),
}

-- 3rd row
launchSpotify = createAppLauncher('Spotify')
charToAction['m'] = function()
  if hs.application.get("Music") then
  -- if Music app is running let that take presedence over Spotify
    hs.application.launchOrFocus("Music")
  else
    launchSpotify()
  end
end

down = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
  local char = event:getCharacters()
  -- local keyCode = event:getKeyCode()
  -- print("down", char, keyCode)

  if char == ";" then
    hyper = true
    if hyperTime == nil then
      hyperTime = hs.timer.absoluteTime()
    end
    return true
  end

  if hyper then
    hyperTime = nil

    local action = charToAction[char]
    if action then
      if char == prevChar then
        -- If hit same key again hide the application
        -- Effectively make it
        hs.application.frontmostApplication():hide()
        prevChar = nil
      else 
        prevChar = char
        action()
      end
    end
  end
end)
down:start()

up = hs.eventtap.new({hs.eventtap.event.types.keyUp}, function(event)
  local char = event:getCharacters()
  if char == ";" and hyper then
    local currentTime = hs.timer.absoluteTime()
    -- print(currentTime, hyperTime)
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
