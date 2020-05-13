hyper = false
hyperTime = nil

down = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
  local character = event:getCharacters()
  local keyCode = event:getKeyCode()
  -- print("down", character, keyCode)

  if character == ";" then
    hyper = true
    if hyperTime == nil then
      hyperTime = hs.timer.absoluteTime()
    end
    return true
  end

  if character == 'h' and hyper then
    hs.eventtap.keyStroke(nil, "left", 0)
    hyperTime = nil
    return true
  end

  if character == 'j' and hyper then
    hs.eventtap.keyStroke(nil, "down", 0)
    hyperTime = nil
    return true
  end
  if character == 'k' and hyper then
    hs.eventtap.keyStroke(nil, "up", 0)
    hyperTime = nil
    return true
  end

  if character == 'l' and hyper then
    hs.eventtap.keyStroke(nil, "right", 0)
    hyperTime = nil
    return true
  end

  if character == 'd' and hyper then
    --- Open Dropdox tray
    hs.osascript.applescript([[
      with timeout of 1 second
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
    hyperTime = nil
    return true
  end

  if character == 'e' and hyper then
    hs.application.launchOrFocus("Visual Studio Code")
    hyperTime = nil
    return true
  end

  if character == 'f' and hyper then
    hs.application.launchOrFocus("Finder")
    hyperTime = nil
    return true
  end

  if character == 'r' and hyper then
    hs.application.launchOrFocus("Slack")
    hyperTime = nil
    return true
  end

  if character == 's' and hyper then
    hs.application.launchOrFocus("Spotify")
    hyperTime = nil
    return true
  end

  if character == 'q' and hyper then
    hs.application.launchOrFocus("iTerm")
    hyperTime = nil
    return true
  end

  if character == 't' and hyper then
    hs.application.launchOrFocus("iTerm")
    hyperTime = nil
    return true
  end

  if character == 'w' and hyper then
    hs.application.launchOrFocus("Google Chrome")
    hyperTime = nil
    return true
  end
end)
down:start()

up = hs.eventtap.new({hs.eventtap.event.types.keyUp}, function(event)
  local character = event:getCharacters()
  if character == ";" and hyper then
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
