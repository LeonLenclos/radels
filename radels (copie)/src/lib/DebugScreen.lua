local module = {}


function module.newDebugScreen(x, y, w, align, showKeys)
  local debugScreen = {}
  debugScreen.x = x or 0
  debugScreen.y = y or 0
  debugScreen.w = w or nil
  debugScreen.align = align or nil
  debugScreen.showKeys = showKeys
  debugScreen.infos = {}
  
  function debugScreen.set(key, value)
    for i, info in ipairs(debugScreen.infos) do
      if info.key == key then
        info.value = tostring(value)
        return True
      end
    end
    table.insert(debugScreen.infos, {
      key=key,
      value=tostring(value)
    })
  end

  function debugScreen.getText()
      txt = ''
      for i, info in ipairs(debugScreen.infos) do
        if debugScreen.showKeys then 
          txt = txt .. info.key .. ': '
        end
        txt = txt .. info.value .. '\n'
      end
      return txt
  end

  function debugScreen.draw()
      love.graphics.printf(debugScreen.getText(), debugScreen.x, debugScreen.y, debugScreen.w , debugScreen.align)
  end

  function debugScreen.print()
      print(debugScreen.getText())
  end


  function debugScreen.update(infos)
      infos = infos or {}
      debugScreen.infos = infos
  end

  return debugScreen
end

return module
