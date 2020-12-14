hs.hotkey.bind({"cmd", "shift"}, "space", function()
  local emacs = hs.application.get("Emacs")
  if emacs:isFrontmost() then
    emacs:hide()
  else
    emacs:activate()
  end
end)
