-- Remove animations on resizing
hs.window.animationDuration = 0

-- Default overrides
hs.grid.ui.showExtraKeys = false
hs.grid.ui.textSize = 50
hs.grid.ui.cellStrokeColor = {0,0,0,0.5}
hs.grid.ui.cellStrokeWidth = 3
hs.grid.ui.highlightColor = {0.8,0.8,0,0.2}
hs.grid.setGrid('9x4').setMargins('0x0')

-- log = hs.logger.new('windows-grid.lua', 'debug')

keyTap = nil
onExitCallback = function()
  -- log.d('EXIT!')
  keyTap:stop()
end

-- if first key is "space" then override the default fullscreen behavior and maximize and hide grid instead
keyTap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(evt)
  local key = evt:getKeyCode()
  -- log.d('keycode', key)
  -- log.d('key', hs.keycodes.map[key])
  -- Uncomment to see log in hammerspoon console
  -- log.d('key:', key)

  -- Maximize window
  if hs.keycodes.map[key] == 'space' then
    keyTap:stop()
    hs.grid.maximizeWindow()
    hs.grid:hide()
    return true
  end

  -- Reload
  if hs.keycodes.map[key] == '/' then
    keyTap:stop()
    hs.reload()
    hs.grid:hide()
    return true
  end
end)

hs.hotkey.bind('ctrl', 's', function()
  -- log.d('start!!')
  keyTap:start()
  hs.grid.show(onExitCallback)
end)
