local utils = {}
-- My utils functions for developing games with Love2d

-- Numbers

function utils.mapvalue(val, min, max, mapmin, mapmax)
    return ((val-min)/(max-min))*(mapmax-mapmin)+mapmin
end

function utils.constrain(val, min, max)
    return val<min and min or val>max and max or val
end

function utils.lerp(start, stop, amount)
    return amount * (stop-start) + start
end

function utils.round(val, decimal)
    -- TODO: may not work with negative numbers and the decimal opition.
    if (decimal) then
        return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
    else
        return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
    end
end

function utils.min(a, b)
  return a > b and b or a
end

function utils.max(a, b)
  return a < b and b or a
end

-- Coords

function utils.indexToCoord(i, w)
    return i%w, math.floor(i/w)
end

function utils.coordToIndex(x, y, w)
    return x + y * w
end

-- Tables

function utils.reduce(t, fun, acc)
    acc = acc==nil and 0 or acc
    for k, v in ipairs(t) do
        acc = fun(acc, v)
    end 
    return acc 
end

function utils.find(t, callback)
    for i,v in ipairs(t) do
        if callback(v, i, t) then return v end
    end
end

function utils.filter(t, filterIter)
  local out = {}

  for i, v in ipairs(t) do
    if filterIter(v, i, t) then table.insert(out, v) end
  end

  return out
end

function utils.tableRepr(t, depthLimit, indentation)

    depthLimit = depthLimit or 2
    indentation = indentation or 0
    local function tabline (txt)
        local tabs = ''
        for i=1,indentation do tabs = '  ' .. tabs end
        return tabs .. txt .. '\n'
    end
    txt = tabline('{')
    for k,v in pairs(t) do
        if type(v) == 'table' then
            if depthLimit and indentation > depthLimit then
                txt = txt .. tabline(k..': {...}')
            else
                txt = txt .. tabline(k..': '..utils.tableRepr(v, depthLimit, indentation+1))
            end
        else
            txt = txt .. tabline(k..':'..tostring(v))
        end
    end
    txt = txt .. tabline('}')
    return txt
end

function utils.shuffle(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

function utils.clone(t)
  return {unpack(t)}
end


-- Love specific

function utils.anyIsDown(controlsList)
  return utils.reduce(controlsList, function(a, v) return a or love.keyboard.isDown(v) end, false)
end

return utils