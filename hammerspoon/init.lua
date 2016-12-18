local log = hs.logger.new('init.lua', 'debug')

keyUpDown = function(modifiers, key)
  log.d('Sending keystroke:', hs.inspect(modifiers), key)
  hs.eventtap.event.newKeyEvent(modifiers, key, true):post()
  hs.eventtap.event.newKeyEvent(modifiers, key, false):post()
end

require('better-caps-lock')
require('delete-words')
require('hyper')
require('super')

hs.notify.new({title='Hammerspoon', informativeText='Ready to rock 🤘'}):send()
