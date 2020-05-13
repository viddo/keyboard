local log = hs.logger.new('shortcut-win.lua', 'debug')
local wf = hs.window.filter
local prev = nil

-- Bind hotkey to toggle a browse + tab based on matching name
-- If focused it will hide the window
hs.hotkey.bind('cmd', '\\', function()
  -- limitation: https://www.hammerspoon.org/docs/hs.application#allWindows
  -- "if Displays have separate Spaces is on (in System Preferences>Mission Control),
  -- the current Space is defined as the union of all currently visible Spaces"
  local wins = hs.application.get('Google Chrome'):allWindows()
  for i = 1, #wins do
    local win = wins[i]
    log.d('WIN!', win:title())
    if not (win:title():find('CRDT') == nil) then
      log.d('YAY!')
      if win == hs.window.focusedWindow() then
        log.d('hide!')
        if prev then
          prev:focus()
        end
      else
        log.d('focus!')
        prev = hs.window.focusedWindow()
        win:focus()
      end
      break
    end
  end
end)
