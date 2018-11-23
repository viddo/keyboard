-- Remove animations on resizing
hs.window.animationDuration = 0

-- Default overrides
hs.grid.ui.showExtraKeys = false
hs.grid.ui.textSize = 50
hs.grid.ui.cellStrokeColor = {0,0,0,0.5}
hs.grid.ui.cellStrokeWidth = 3
hs.grid.ui.highlightColor = {0.8,0.8,0,0.2}
hs.grid.setGrid('9x4').setMargins('0x0')

-- local log = hs.logger.new('windows-grid.lua', 'debug')

-- if first key is "space" then override the default fullscreen behavior and maximize and hide grid instead
keyTapHandler = function(evt)
  local key = evt:getKeyCode()
  -- Uncomment to see log in hammerspoon console
  -- log.d('key:', key)
  if hs.keycodes.map[key] == 'space' then
    hs.grid.maximizeWindow()
    hs.grid.hide()
  end
  keyTap:stop()
  return false
end
keyTap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, keyTapHandler)

hs.hotkey.bind('ctrl', 's', function()
  keyTap:start()
  hs.grid.toggleShow()
end)
