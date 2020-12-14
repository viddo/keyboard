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

k = hs.hotkey.modal.new('ctrl', ';')
function k:entered() 
    visualCue:show()
end
function k:exited()
    visualCue:hide()
end
k:bind('', 'escape', function() k:exit() end)
k:bind('', ';', function() k:exit() end)
k:bind('ctrl', ';', function() k:exit() end)

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
    k:exit()
  end
end

-- 1st row
k:bind('', 'q', createAppLauncher('iTerm', 'iTerm2'))
k:bind('', 'w', createAppLauncher('Google Chrome'))
k:bind('', 'e', createAppLauncher('Visual Studio Code', 'Code'))
k:bind('', 'r', createAppLauncher('Dropbox Paper'))
k:bind('', 't', createAppLauncher('Slack'))

-- 2nd row
k:bind('', 'f', createAppLauncher('Finder'))
k:bind('', 'g', createAppLauncher('GitHub Desktop'))

-- 3rd row
k:bind('', 'n', createAppLauncher('Notes'))
launchSpotify = createAppLauncher('Spotify')
k:bind('', 'm', function() 
  if hs.application.get("Music") then -- Music take presedence over Spotify
    hs.application.launchOrFocus("Music")
  else
    launchSpotify()
  end
end)
