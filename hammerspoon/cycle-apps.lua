log = hs.logger.new('windows-grid.lua', 'debug')

-- Need to remove/change default "Show Spotlight search" keyboard shortcut for this to work, even if it's not activated
hs.application.enableSpotlightForNameSearches(true)
hs.hotkey.bind({"cmd", "shift"}, "space", function()
  log.d('trigger')
  local atom = getApp('Atom Beta')
  local emacs = getApp('Emacs')

  if (atom and emacs) then
    if atom:isFrontmost() then
      emacs:activate()
      atom:hide()
    elseif emacs:isFrontmost() then
      emacs:hide()
    else
      atom:activate()
    end
  elseif atom then
    if atom:isFrontmost() then
      atom:hide()
    else
      atom:activate()
    end
  elseif emacs then
    if emacs:isFrontmost() then
      emacs:hide()
    else
      emacs:activate()
    end
  end
end)

getApp = function(name, altName)
  return hs.application.get(name) or hs.application.get(altName or "")
end
