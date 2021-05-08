------------------------------------
-- World -- the world of the game --
------------------------------------

local Object = require "lib.classic"
local World = Object:extend();

local utils = require "utils"
local Player = require 'entities.Player'
local Platform = require 'entities.Platform'
local Wall = require 'entities.Wall'
local Carpet = require 'entities.Carpet'
local ReadyArea = require 'entities.ReadyArea'

-- Constructor for the World
function World:new(map)
   self.objects = {}
   self:loadMap(map)
end

-- Iter threw each object of the world given a filter
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

-- Is this position out of the world ??
function World:isOut(x, y)
   return x>WIDTH or x<0 or y>HEIGHT or y<0
end

-- Is this position containing an entity that has this property ?
function World:isPropertyAt(property, x, y, value)
   value = value or true
   return utils.find(self.objects, function(o)
						return o.life>0 and x==o.x and y==o.y and o:getProperty(property) == value
   end)
end

-- Is there an object of this type at that place?
function World:isTypeAt(type, x, y)
   return self:isPropertyAt('type', x, y, type)
end

-- Is there a solid entity at that place ?
function World:isSolidAt(x, y)
   return self:isPropertyAt('isSolid', x, y)
end

-- Is there ground at that place ?
function World:isGroundAt(x, y)
   return self:isPropertyAt('isGround', x, y)
end


-- Update the world
function World:update(dt)

   -- If one of the two players is dead, update only the dead player.
   local oneIsDead = false
   if self:getById('player1').life <= 0 or self:getById('player2').life <= 0 then
	  oneIsDead = true
	  if self:getById('player1').life <= 0 then
		 self:getById('player1'):update(dt)
	  end
	  if self:getById('player2').life <= 0 then
		 self:getById('player2'):update(dt)
	  end
   end

   -- Update all entites except players if one is dead.
   for obj in self:iter() do
	  if not oneIsDead or not (self.id == 'player1' or self.id == 'player2') then 
		 obj:update(dt)
		 if obj:getProperty('isSolid') and not world:isGroundAt(obj.x, obj.y) then
			obj:drown()
		 end
	  end
   end
   
   -- remove destroyed objects
   self.objects = utils.filter(self.objects, function(o) return not o:getProperty('toDelete') end)
end

-- Draw the world
function World:draw()

   -- Draw each ground object
   for obj in self:iter(function(o) return o:getProperty('isGround') end) do
	  obj:draw()
   end

   -- Draw each nonground object
   for obj in self:iter(function(o) return not o:getProperty('isGround') end) do
	  obj:draw()
   end

   -- Draw players again (to be sure there are on top of everything
   if self:getById('player1') then self:getById('player1'):draw() end
   if self:getById('player2') then self:getById('player2'):draw() end
end

-- Add an object to the world
function World:add(gameObject)
   table.insert(self.objects, gameObject)
end

-- Get a world object b Id
function World:getById(id)
   for obj in self:iter() do
	  if obj.id == id then
		 return obj
	  end
   end
end

-- Load a map
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
