local Object = require "lib.classic"
local World = Object:extend();

local utils = require "utils"
local Player = require 'entities.Player'
local Platform = require 'entities.Platform'
local Wall = require 'entities.Wall'
local Carpet = require 'entities.Carpet'
local ReadyArea = require 'entities.ReadyArea'


function World:new(map)
  self.objects = {}
  self:loadMap(map)

end

function World:iter(filterIter)
  local i = 0
  local objects = filterIter and utils.filter(self.objects, filterIter) or self.objects 
  local count = #objects
  return function ()
  i = i + 1
  if i <= count then
    return objects[i]
  end
end
end

function World:isOut(x, y)
  return x>WIDTH or x<0 or y>HEIGHT or y<0
end

function World:isPropertyAt(property, x, y, value)
  value = value or true
  return utils.find(self.objects, function(o)
    return o.life>0 and x==o.x and y==o.y and o:getProperty(property) == value
  end)
end

function World:isTypeAt(type, x, y)
  return self:isPropertyAt('type', x, y, type)
end

function World:isSolidAt(x, y)
  return self:isPropertyAt('isSolid', x, y)
end

function World:isReadyAreaAt(x, y)
  return self:isPropertyAt('isReadyArea', x, y)
end

function World:isGroundAt(x, y)
  return self:isPropertyAt('isGround', x, y)
end

function World:update(dt)
  for obj in self:iter() do
    obj:update(dt)
    if obj:getProperty('isSolid') and not world:isGroundAt(obj.x, obj.y) then
        obj:drown()
    end
  end

  -- remove destroyed objects
  self.objects = utils.filter(self.objects, function(o) return not o:getProperty('toDelete') end)
end

function World:draw()
  for obj in self:iter(function(o) return o:getProperty('isGround') end) do
    obj:draw()
  end
  for obj in self:iter(function(o) return not o:getProperty('isGround') end) do
    obj:draw()

  end
end

function World:add(gameObject)
  table.insert(self.objects, gameObject)
end


function World:getRandomSpawnablePos(id)
  -- local objectsCopy = utils.clone(self.objects)
  local shuffled = utils.shuffle(self.objects)
  for i, obj in ipairs(shuffled) do
    print(i)
    if obj:getProperty('isGround') and not self:isSolidAt(obj.x, obj.y) then
      return obj.x, obj.y
    end
  end
end

function World:getById(id)
  for obj in self:iter() do
    if obj.id == id then
      return obj
    end
  end
end

function World:loadMap(map)
  local x = 0
  local y = 0
  for i = 1, #map do
    local c = map:sub(i,i)
    if c == '\n' then
      y = y + 1
      x = 0
    else
      if     c == '.' then
        self:add(Platform(x, y))
      elseif c == '#' then
        self:add(Wall(x, y))
        self:add(Platform(x, y))
      elseif c == 'X' then
        self:add(Platform(x, y))
        self:add(ReadyArea(x, y))
      elseif c == ':' then
        self:add(Platform(x, y))
        self:add(Carpet(x, y))
      elseif c == '1' then
        self:add(Player(x, y, 'player1'))
        self:add(Platform(x, y))
      elseif c == '2' then
        self:add(Player(x, y, 'player2'))
        self:add(Platform(x, y))
      end
      x = x + 1
    end
  end

end






return World