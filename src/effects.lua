------------------------------------
-- Effects -- Misc visual effects --
------------------------------------

local effects = {}

local utils = require "utils"

local tileset = love.graphics.newImage('tileset.png')


--------------------------------------------------
-- Target
-- Draw dashes to show where the action will take place
local target = {}
effects.target = target

-- Vars
target.currentTime = 0
target.targets = {}

-- Quads
target.quads = {
   carpet = {},
   wall = {},
   bomb = {line={}, endOfLine={}}
}
for i=1,4 do
   target.quads.carpet[i] = love.graphics.newQuad(14*TILE_SIZE + (i-1)*(3*TILE_SIZE), 7*TILE_SIZE, TILE_SIZE*3, TILE_SIZE*3, tileset:getWidth(), tileset:getHeight())
end
for i=1,4 do
   target.quads.wall[i] = love.graphics.newQuad(14*TILE_SIZE  + (i-1)*(TILE_SIZE), 10*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight())
end
for i=1,5 do
   target.quads.bomb.line[i] = love.graphics.newQuad(18*TILE_SIZE  + (i-1)*(2*TILE_SIZE), 10*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight())
   target.quads.bomb.endOfLine[i] = love.graphics.newQuad(19*TILE_SIZE  + (i-1)*(2*TILE_SIZE), 10*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight())
end

-- Show the target for the given player and the given action at the given position / target position
-- This function must be called at each update loop after target.update
target.show = function(playerId, specialAction, x, y, tx, ty)
   target.targets[playerId] = {
	  playerId=playerId,
	  specialAction=specialAction,
	  x=x, y=y, tx=tx, ty=ty,
   }
end

-- Update the target effect for both players
target.update = function(dt)    
   target.currentTime=target.currentTime+dt
   target.targets = {}
end

-- Draw a carpet target giving x and y
target.drawCarpet = function(x, y)
   local frame = math.floor(target.currentTime/TARGET_FRAME_DURATION%#target.quads.carpet+1)
   love.graphics.draw(tileset, target.quads.carpet[frame], (x-1)*TILE_SIZE, (y-1)*TILE_SIZE)
end

-- Draw a wall target giving x and y
target.drawWall = function(x, y)
   local frame = math.floor(target.currentTime/TARGET_FRAME_DURATION%#target.quads.wall+1)
   love.graphics.draw(tileset, target.quads.wall[frame], x*TILE_SIZE, y*TILE_SIZE)
end


-- Draw a bomb target giving x, y, tx and ty
target.drawBomb = function(x, y, tx, ty)
   -- tile rotation and offset depends on bomb direction
   local rotation = tx > x and 0 or math.pi
   local offset = tx > x and 0 or 1
   local frame = math.floor(target.currentTime/TARGET_FRAME_DURATION%#target.quads.bomb.line+1)
   for tilex=  utils.min(x, tx)+1, utils.max(x, tx)-1 do
	  love.graphics.draw(tileset, target.quads.bomb.line[frame], (tilex+offset)*TILE_SIZE, (ty+offset)*TILE_SIZE, rotation)
   end
   love.graphics.draw(tileset, target.quads.bomb.endOfLine[frame], (tx+offset)*TILE_SIZE, (ty+offset)*TILE_SIZE, rotation)
end


-- Draw the target effects for both players
target.draw = function()
   for playerId, targetInfos in pairs(target.targets) do
	  -- targetInfos is nil if target.show hasn't be called this loop
	  if targetInfos then
		 if targetInfos.specialAction == 1 then -- Carpet
			target.drawCarpet(targetInfos.tx, targetInfos.ty)
		 elseif targetInfos.specialAction == 2 and targetInfos.tx then -- Wall
			target.drawWall(targetInfos.tx, targetInfos.ty)
		 elseif targetInfos.specialAction == 3 then -- Bomb
			target.drawBomb(targetInfos.x, targetInfos.y, targetInfos.tx, targetInfos.ty)
		 end
	  end
   end
end


--------------------------------------------------
-- CameraShake
-- Shake the camera for bomb explosions
local cameraShake = {}
effects.cameraShake = cameraShake

-- Start shaking
cameraShake.start = function()
   cameraShake.currentTime=0
end

-- Is the shaking finished ?
cameraShake.isOver = function()
   return not cameraShake.currentTime or cameraShake.currentTime > CAMERASHAKE_DURATION
end

-- Update the effect
cameraShake.update = function(dt)
   if cameraShake.isOver() then
	  -- If it is over : no offset
	  cameraShake.offset = {0, 0}
   else
	  -- Else : choose camera offset (x and y will be set to -1, 0 or 1)
	  cameraShake.currentTime=cameraShake.currentTime+dt
	  local x = math.floor(cameraShake.currentTime/CAMERASHAKE_FRAME_DURATION % 2) -1
	  local y = math.floor((1.5+cameraShake.currentTime)/CAMERASHAKE_FRAME_DURATION % 2) -1
	  cameraShake.offset = {x, y}
   end
end

-- Return the current camera offset (a {x,y} table)
cameraShake.getOffset = function(dt)
   return cameraShake.offset and cameraShake.offset or {0,0}
end

--------------------------------------------------
-- Transition
-- Fade in or fade out between pause and arena
local transition = {}
effects.transition = transition

-- Start the transition giving a type ('fadein' or 'fadeout')
transition.start = function(transitionType)
   transition.type = transitionType
   transition.currentTime = 0
end

-- Is the transition over ??
transition.isOver = function()
   return transition.currentTime > TRANSITION_TIME
end

-- Update the effect
transition.update = function(dt)
   transition.currentTime=transition.currentTime+dt
   if transition.isOver() then
	  -- Stop the transition if it is over
	  transition.type = nil 
   else
	  -- create a quad for the current transition momment
	  local tileCol = 0
	  if transition.type == 'fadeout' then
		 tileCol = utils.mapvalue(transition.currentTime, 0,TRANSITION_TIME,0,8)
	  elseif transition.type == 'fadein' then
		 tileCol = utils.mapvalue(transition.currentTime, 0,TRANSITION_TIME,8,0)
	  end
	  tileCol = math.floor(utils.constrain(tileCol, 0, 5))
	  transition.tileQuad = love.graphics.newQuad(tileCol*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight())
   end
end

-- Draw the effect
transition.draw = function()
   if transition.currentTime < TRANSITION_TIME + 0.05 then -- that 0.05 seconds is an ugly hack but I cant figure how to do without it  
	  for i=0,WIDTH*HEIGHT do
		 -- For each tile of the screen draw the quad
		 local x, y = utils.indexToCoord(i, WIDTH)
		 love.graphics.draw(tileset, transition.tileQuad, x*TILE_SIZE, y*TILE_SIZE)
	  end
   end
end

--------------------------------------------------
-- Water
-- Draw fancy waves animation
local water = {}
effects.water = water

-- Vars
water.currentTime=0
water.grayQuad = {
   love.graphics.newQuad(1*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
   love.graphics.newQuad(2*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
   love.graphics.newQuad(3*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
   love.graphics.newQuad(4*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
   love.graphics.newQuad(3*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
   love.graphics.newQuad(2*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
}
water.tileQuads= {
   love.graphics.newQuad(6*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
   love.graphics.newQuad(7*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
   love.graphics.newQuad(8*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
   love.graphics.newQuad(9*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
}

-- Update the effect
water.update = function(dt)
   water.currentTime = water.currentTime + dt
end

-- Draw the effect
water.draw = function()
   for i=0,WIDTH*(HEIGHT+1) do
	  local x, y = utils.indexToCoord(i, WIDTH)
	  local yOffset = math.floor(water.currentTime*4%TILE_SIZE)
	  local quad = math.floor(utils.fixedRandom(x, 10)* #water.tileQuads)+1
	  love.graphics.draw(tileset, water.tileQuads[quad], x*TILE_SIZE, y*TILE_SIZE-yOffset)
   end
   for i=0,WIDTH*(HEIGHT+1) do
	  local x, y = utils.indexToCoord(i, WIDTH)
	  love.graphics.draw(tileset, water.grayQuad[math.floor(water.currentTime/3+x)%#water.grayQuad+1], x*TILE_SIZE, y*TILE_SIZE)
   end
end


--------------------------------------------------
-- Title
-- Draw the title of the game : Radèls
local title = {}
effects.title = title

-- Vars
title.currentTime=0
title.quad = love.graphics.newQuad(22*TILE_SIZE, 11*TILE_SIZE, 8*TILE_SIZE, 2*TILE_SIZE, tileset:getWidth(), tileset:getHeight())

-- Update the effect
title.update = function(dt)
   title.currentTime = title.currentTime + dt
end

-- Draw the effect
title.draw = function()
   local wave = (math.sin(title.currentTime)+1) / 2
   love.graphics.draw(tileset, title.quad, 6*TILE_SIZE, TILE_SIZE/2 + math.floor(wave*14), math.pi/2)
   love.graphics.draw(tileset, title.quad, DISPLAY_WIDTH-6*TILE_SIZE, DISPLAY_HEIGHT -TILE_SIZE/2 - math.floor(wave*14), math.pi*3/2)
end


return effects
