-------------------------------------------------------------------------------------------------
-- Entity -- something in the physic world of the game (this class is herited by all entities) --
-------------------------------------------------------------------------------------------------

local Object = require "lib.classic"
local Entity = Object:extend()

local utils = require "utils"
local audio = require "audio"

local tileset = love.graphics.newImage('tileset.png')

local defaultSpriteState = {
   -- size of the sprite (in pixels)
   width=TILE_SIZE,
   height=TILE_SIZE,
   -- position of the sprite in the tileset (in pixel)
   colOrigin=0,
   rowOrigin=0,
   -- is it animated with frames in a row or in a column
   rowAnimated=false,
   colAnimated=false,
   -- the lenght of the animation (in frames)
   animLength=1,
   -- Animation time and duration (in seconds)
   animCurrentTime=0,
   animDuration=0,
   -- the state to set when the animation is finish
   next='base',
   -- does the animation needs to be played in loop
   loop=false,
   -- set of functions, each functios return a bool that are bitwise added used to find the pos in the tileset (relative to origin)
   colBitwiseRuleSet=nil,
   rowBitwiseRuleSet=nil,
   -- simple function that returns the pos of the sprite in the tileset (relative to origin)
   colRule=nil,
   rowRule=nil,
}

-- Constructor for the Entity. It takes x and y position, a properties table and a spriteStates table.
function Entity:new(x, y, properties, spriteStates)
   -- Attributes
   self.life = 1
   self.x = x
   self.y = y
   self.properties = properties or {}
   self.spriteState = 'base'

   -- Load spriteStates
   self.spriteStates = {}
   for k,v in pairs(spriteStates) do
	  -- For each state, set default values for unset keys
	  self.spriteStates[k] = utils.update(defaultSpriteState, v)
	  -- create a rowRule function with rowBitwiseRuleSet
	  if self.spriteStates[k].rowBitwiseRuleSet then
		 self.spriteStates[k].rowRule = function(x, y, world)
			local offset = 0
			for i, fun in ipairs(self.spriteStates[k].rowBitwiseRuleSet) do
			   offset = offset + (fun(x, y, world) and 2^(i-1) or 0)
			end
			return offset
		 end
	  end
	  -- create a colRule function with colBitwiseRuleSet
	  if self.spriteStates[k].colBitwiseRuleSet then
		 self.spriteStates[k].colRule = function(x, y, world)
			local offset = 0
			for i, fun in ipairs(self.spriteStates[k].colBitwiseRuleSet) do
			   offset = offset + (fun(x, y, world) and 2^(i-1) or 0)
			end
			return offset
		 end
	  end
	  -- create rowRule dunction for rowAnimated sprites
	  if self.spriteStates[k].rowAnimated then
		 self.spriteStates[k].rowRule = function(x, y, world)
			return math.floor(self.spriteStates[k].animCurrentTime/self.spriteStates[k].animDuration*self.spriteStates[k].animLength)
		 end
	  end
	  -- create colRule dunction for colAnimated sprites
	  if self.spriteStates[k].colAnimated then
		 self.spriteStates[k].colRule = function(x, y, world)
			return math.floor(self.spriteStates[k].animCurrentTime/self.spriteStates[k].animDuration*self.spriteStates[k].animLength)
		 end
	  end
   end
end

-- Get the value of a given property
function Entity:getProperty(key)
   if self.properties then
	  return self.properties[key]
   end  
end

-- Set the value for a given property
function Entity:setProperty(key, value)
   self.properties[key] = value
end

-- Get the current spriteState table
function Entity:getSpriteState()
   return self.spriteStates[self.spriteState]
end

-- Set the current spriteState
function Entity:setSpriteState(state)
   -- Do nothing if the given state is already the current state
   if state ~= self.spriteState then
	  self.spriteState = state
	  -- reset the animation
	  if self.spriteStates[self.spriteState] then
		 self.spriteStates[self.spriteState].animCurrentTime = 0
	  end
   end
end

-- Drown the entity
function Entity:drown()
   -- Do nothing if the entity is alreqdy dead
   if self.life>0 then
	  -- kill the entity
	  self.life = 0
	  -- play sound and set sprite state
	  audio.playSound('drown')
	  if self.spriteStates.drowning then
		 self:setSpriteState('drowning')
	  end
   end
end

-- Update the Entity
function Entity:update(dt)

   -- Play the death sound once if the entity is a player
   if self.life<=0 and (self.id == 'player1' or self.id == 'player2') and not self.deathSoundPlaying then
	  audio.playSound('death')
	  self.deathSoundPlaying = true
   end

   -- Set the death sprite if Entity is dead and not invisible and not drowing
   if self.life <= 0 and self.spriteState ~= 'none' and self.spriteState ~= 'drowning' then
	  self:setSpriteState('death')
   end

   -- Sprite
   local spriteState = self:getSpriteState()
   if spriteState then
	  -- If a spriteState is setted, do animations, loop and next.
	  if spriteState.rowAnimated or spriteState.colAnimated then
		 spriteState.animCurrentTime = spriteState.animCurrentTime + dt
		 if spriteState.animCurrentTime > spriteState.animDuration then
			if spriteState.loop then
			   spriteState.animCurrentTime = spriteState.animCurrentTime % spriteState.animDuration
			else
			   self:setSpriteState(spriteState.next)
			end
		 end
	  end
   elseif self.life <= 0 then
	  -- If no spriteState and entity is dead, it will be deleted
	  self:setProperty('toDelete', true)
   end
end

-- Draw the Entity
function Entity:draw()
   local spriteState = self:getSpriteState()
   if spriteState then
	  -- Choose the sprite frame/variation 
	  local tileX = spriteState.colOrigin*TILE_SIZE
	  local tileY = spriteState.rowOrigin*TILE_SIZE
	  if spriteState.rowRule then
		 tileY = tileY + spriteState.rowRule(self.x, self.y, world)*spriteState.width
	  end
	  if spriteState.colRule then
		 tileX = tileX + spriteState.colRule(self.x, self.y, world)*spriteState.height
	  end

	  -- Draw the sprite
	  local quad = love.graphics.newQuad(tileX, tileY, spriteState.width, spriteState.height, tileset:getWidth(), tileset:getHeight())
	  local scaleX = self.directionX or 1
	  local scaleY = 1
	  local x = self.x*TILE_SIZE + TILE_SIZE/2 - spriteState.width/2*scaleX
	  local y = self.y*TILE_SIZE + TILE_SIZE/2 - spriteState.height/2*scaleY
	  local rotation = 0
	  love.graphics.draw(tileset, quad, x, y, rotation, scaleX, scaleY)
   end
end

return Entity
