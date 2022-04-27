------------------------------------
-- Effects -- Misc visual effects --
------------------------------------

local effects = {}

local scores = require "scores"
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
   target.quads.bomb.line[i] = love.graphics.newQuad(14*TILE_SIZE  + (i-1)*(2*TILE_SIZE), 11*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight())
   target.quads.bomb.endOfLine[i] = love.graphics.newQuad(15*TILE_SIZE  + (i-1)*(2*TILE_SIZE), 11*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight())
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
-- Arcade
-- Draw dashes to show where the action will take place
local arcade = {}
effects.arcade = arcade

-- Vars
arcade.currentTime = 0

-- Quads
local arcadeCol = 31 * TILE_SIZE
local arcadeRow = 3 * TILE_SIZE
arcade.quads = {
   life = {},
   player = love.graphics.newQuad(arcadeCol + 25, arcadeRow + 1, 2, 3, tileset:getWidth(), tileset:getHeight()),
   bullet = love.graphics.newQuad(arcadeCol + 28, arcadeRow + 2, 1, 1, tileset:getWidth(), tileset:getHeight())
}
for i=1,6 do
   arcade.quads.life[i] = love.graphics.newQuad(arcadeCol + 1 + 4*(i-1)  , arcadeRow + 1, 3, 12, tileset:getWidth(), tileset:getHeight())
end

-- Show the arcade for the given player and the given action at the given position / arcade position
-- This function must be called at each update loop after arcade.update
arcade.show = function(cabinet)
  arcade.cabinet = cabinet
end

-- Update the arcade effect for both players
arcade.update = function(dt)
   arcade.currentTime=arcade.currentTime+dt
end


-- Draw the arcade effects for both players
arcade.draw = function(x, y)
  if not arcade.cabinet then return end

  local arcadeCanvas = love.graphics.newCanvas(20, 12)
  love.graphics.setCanvas(arcadeCanvas)


  if arcade.cabinet.p1 then
    love.graphics.draw(tileset, arcade.quads.life[utils.constrain(6-arcade.cabinet.p1.life,1,#arcade.quads.life)], 8 + arcade.cabinet.w, 2+arcade.cabinet.h, math.pi)
    love.graphics.draw(tileset, arcade.quads.player, 4 + arcade.cabinet.p1.x, arcade.cabinet.p1.y +2, math.pi)
  end

  if arcade.cabinet.p2 then
    love.graphics.draw(tileset, arcade.quads.life[utils.constrain(6-arcade.cabinet.p2.life,1,#arcade.quads.life)], 0, 0, 0)
    love.graphics.draw(tileset, arcade.quads.player, 4 + arcade.cabinet.p2.x, arcade.cabinet.p2.y-1, 0)
  end

  for i,bullet in ipairs(arcade.cabinet.bullets) do
    love.graphics.draw(tileset, arcade.quads.bullet, 4 + bullet.x, bullet.y, 0)
  end



  love.graphics.setCanvas(canvas)
  love.graphics.draw(arcadeCanvas, x, y)
end


--------------------------------------------------
-- Arrow
-- Draw arrow when player is out of screen
local arrow = {}
effects.arrow = arrow

-- Vars
arrow.currentTime = 0
arrow.arrows = {}

-- Quads
arrow.quads = {
   vert = {},
   diag = {},
}
for i=1,4 do
  arrow.quads.vert[i] = love.graphics.newQuad(14*TILE_SIZE + (i-1)*TILE_SIZE, 12*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight())
  arrow.quads.diag[i] = love.graphics.newQuad(18*TILE_SIZE + (i-1)*TILE_SIZE, 12*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight())
end

-- Show the arrow for the given player
-- This function must be called at each update loop after arrow.update
arrow.show = function(playerId, playerX, playerY)
   local x = playerX
   local y = playerY
   local rotation = 0
   local orientation = 'vert'
   if playerX <= 0 then
     x = 1
     rotation = 3
   elseif playerX >= WIDTH-1 then
     x = WIDTH-2
     rotation = 1
   end
   if playerY >= HEIGHT then
     y = HEIGHT-1
     rotation = 2
     if playerX <= 0 then
       orientation = 'diag'
     elseif playerX >= WIDTH-1 then
       orientation = 'diag'
       rotation = rotation -1
     end
   elseif playerY < 0 then
     y = 0
     rotation = 0
     if playerX <= 0 then
       orientation = 'diag'
       rotation = rotation -1
     elseif playerX >= WIDTH-1 then
       orientation = 'diag'
     end
   end

   rotation = rotation%4
   if rotation == 1 then
     x=x+1
   elseif rotation == 2 then
     x=x+1
     y=y+1
   elseif rotation == 3 then
     y=y+1
   end

   arrow.arrows[playerId] = {
	  playerId=playerId,
    orientation=orientation,
    rotation=rotation*math.pi/2,
	  x=x, y=y,
   }
end

-- Update the arrow effect for both players
arrow.update = function(dt)
   arrow.currentTime=arrow.currentTime+dt
   arrow.arrows = {}
end

-- Draw the arrow effects for both players
arrow.draw = function()
   for playerId, arrowInfos in pairs(arrow.arrows) do
    local frame = math.floor(arrow.currentTime/TARGET_FRAME_DURATION%#arrow.quads[arrowInfos.orientation]+1)
    love.graphics.draw(tileset, arrow.quads[arrowInfos.orientation][frame], arrowInfos.x*TILE_SIZE, arrowInfos.y*TILE_SIZE, arrowInfos.rotation)
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
title.quads = {
  radels = love.graphics.newQuad(26*TILE_SIZE, 8*TILE_SIZE, 8*TILE_SIZE, 2*TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
  win = love.graphics.newQuad(26*TILE_SIZE, 10*TILE_SIZE, 8*TILE_SIZE, 2*TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
  loose = love.graphics.newQuad(26*TILE_SIZE, 12*TILE_SIZE, 8*TILE_SIZE, 2*TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
  credits = love.graphics.newQuad(29*TILE_SIZE, 14*TILE_SIZE, 4*TILE_SIZE, 1*TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
}

-- Start title
title.start = function()
   title.currentTime=0
   title.quad1 = nil
   title.quad2 = nil
   if scores.lastWinner then
     title.quad1 = title.quads.loose
     title.quad2 = title.quads.loose
     if scores.lastWinner == 'player1'
     or scores.lastWinner == 'both' then
        title.quad1 = title.quads.win
     end
     if scores.lastWinner == 'player2'
     or scores.lastWinner == 'both' then
        title.quad2 = title.quads.win
     end
   end
end


-- Update the effect
title.update = function(dt)
   title.currentTime = title.currentTime + dt

end

-- Draw the effect
title.draw = function()
   local wave = (math.sin(title.currentTime)+1) / 3
   local x = 6*TILE_SIZE
   local y = math.floor(TILE_SIZE/4 + wave*14)
   local function easeInOut(x, a)
     return math.pow(x,a)/(math.pow(x,a)+math.pow((1-x),a))
   end
   local min = 6
   local max = 8
   local t = utils.max(utils.min(title.currentTime, max), min)
   t = (t-min)/(max-min)
   local offsetMax = math.floor(DISPLAY_HEIGHT*1.5)
   local offset = math.floor(easeInOut(t,3)*offsetMax)
   if title.quad1 and title.quad2 then
     love.graphics.draw(tileset, title.quad1, DISPLAY_WIDTH-x, DISPLAY_HEIGHT-y+offset, math.pi*3/2)
     love.graphics.draw(tileset, title.quad2, x, y-offset, math.pi/2)
   end
   love.graphics.draw(tileset, title.quads.credits, DISPLAY_WIDTH-x+2*TILE_SIZE, DISPLAY_HEIGHT-(y+2*TILE_SIZE)+offset, math.pi*3/2)
   love.graphics.draw(tileset, title.quads.credits, x-2*TILE_SIZE, (y+2*TILE_SIZE)-offset, math.pi/2)

   love.graphics.draw(tileset, title.quads.radels, DISPLAY_WIDTH-x, DISPLAY_HEIGHT-y+offset-offsetMax, math.pi*3/2)
   love.graphics.draw(tileset, title.quads.radels, x, y-offset+offsetMax, math.pi/2)

end


return effects
