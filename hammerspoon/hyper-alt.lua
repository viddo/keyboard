hyper = false
hyperTime = nil

charToAction = {
  -- 1st row
  ['q'] = function() hs.application.launchOrFocus('iTerm') end,
  ['w'] = function() hs.application.launchOrFocus('Google Chrome') end,
  ['e'] = function() hs.application.launchOrFocus('Visual Studio Code') end,
  ['t'] = function() hs.application.launchOrFocus('Slack') end,

  -- 2nd row
  ['d'] = function()
    --- Open Dropdox tray
    --- 2 not happening within 2 sec then it aborts
    hs.osascript.applescript([[
      with timeout of 2 second
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
  end,
  ['f'] = function() hs.application.launchOrFocus('Finder') end,

  ['h'] = function() hs.eventtap.keyStroke(nil, "left", 0) end,
  ['j'] = function() hs.eventtap.keyStroke(nil, "down", 0) end,
  ['k'] = function() hs.eventtap.keyStroke(nil, "up", 0) end,
  ['l'] = function() hs.eventtap.keyStroke(nil, "right", 0) end,

  -- 3rd row
  ['m'] = function() hs.application.launchOrFocus('Spotify') end,
}

down = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
  local character = event:getCharacters()
  -- local keyCode = event:getKeyCode()
  -- print("down", character, keyCode)

  if character == ";" then
    hyper = true
    if hyperTime == nil then
      hyperTime = hs.timer.absoluteTime()
    end
    return true
  end

  if hyper then
    local action = charToAction[character]
    if action then
      action()
      hyperTime = nil
    end

    -- prevent other keys while hyper is active
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
