local effects = {}

local utils = require "utils"
local tileset = love.graphics.newImage('tileset.png')


-- Target

local target = {}
effects.target = target

target.currentTime=0
target.targets = {}
target.show = function(playerId, specialAction, x, y, tx, ty)
   target.targets[playerId] = {
	  playerId=playerId,
	  specialAction=specialAction,
	  x=x,
	  y=y,
	  tx=tx,
	  ty=ty
   }
end


target.update = function(dt)    
   target.currentTime=target.currentTime+dt
   target.targets = {}
end

target.quads = {}
target.quads.carpet= {}
for i=1,4 do
   target.quads.carpet[i] = love.graphics.newQuad(14*TILE_SIZE  + (i-1)*(3*TILE_SIZE), 7*TILE_SIZE,
											  TILE_SIZE*3, TILE_SIZE*3, tileset:getWidth(), tileset:getHeight())
end
target.quads.wall = {}
for i=1,4 do
   target.quads.wall[i] = love.graphics.newQuad(14*TILE_SIZE  + (i-1)*(TILE_SIZE), 10*TILE_SIZE,
											  TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight())
end
target.quads.bomb = {line={}, endOfLine={}}
for i=1,5 do
   target.quads.bomb.line[i] = love.graphics.newQuad(18*TILE_SIZE  + (i-1)*(2*TILE_SIZE), 10*TILE_SIZE,
											  TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight())
   target.quads.bomb.endOfLine[i] = love.graphics.newQuad(19*TILE_SIZE  + (i-1)*(2*TILE_SIZE), 10*TILE_SIZE,
											  TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight())
end

target.draw = function()
   for playerId, targetInfos in pairs(target.targets) do
	  if targetInfos then
		 
		 if targetInfos.specialAction == 1 then -- Carpet
			local frame = math.floor(target.currentTime*8%4+1)
			love.graphics.draw(tileset, target.quads.carpet[frame], (targetInfos.tx-1)*TILE_SIZE, (targetInfos.ty-1)*TILE_SIZE)
		 elseif targetInfos.specialAction == 2 and targetInfos.tx then -- Wall
			local frame = math.floor(target.currentTime*8%4+1)
			love.graphics.draw(tileset, target.quads.wall[frame], targetInfos.tx*TILE_SIZE, targetInfos.ty*TILE_SIZE)
		 elseif targetInfos.specialAction == 3 then -- Bomb
			if targetInfos.tx > targetInfos.x then
			   local frame = math.floor(target.currentTime*8%5+1)
			   for x=targetInfos.x+1, targetInfos.tx-1 do
				  love.graphics.draw(tileset, target.quads.bomb.line[frame], x*TILE_SIZE, targetInfos.ty*TILE_SIZE)
			   end
			   love.graphics.draw(tileset, target.quads.bomb.endOfLine[frame], targetInfos.tx*TILE_SIZE, targetInfos.ty*TILE_SIZE)
			else
			   local frame = math.floor(target.currentTime*8%5+1)
			   for x=targetInfos.tx+1, targetInfos.x-1 do
				  love.graphics.draw(tileset, target.quads.bomb.line[frame], (x+1)*TILE_SIZE, (targetInfos.y+1)*TILE_SIZE, math.pi)
			   end
			   love.graphics.draw(tileset, target.quads.bomb.endOfLine[frame], (targetInfos.tx+1)*TILE_SIZE, (targetInfos.ty+1)*TILE_SIZE, math.pi)
			end
			
		end
	  end
    end
end



-- CameraShake

local cameraShake = {}
effects.cameraShake = cameraShake


cameraShake.start = function()
   cameraShake.currentTime=0
end

cameraShake.isOver = function()
    return not cameraShake.currentTime or cameraShake.currentTime > TRANSITION_TIME
end

cameraShake.update = function(dt)
    if cameraShake.isOver() then
	   cameraShake.offset = {0, 0}
    else
	   local x = math.floor(cameraShake.currentTime*10%2)-1
	   local y = math.floor((1.5+cameraShake.currentTime)*10%2)-1
	   cameraShake.offset = {x, y}
	   cameraShake.currentTime=cameraShake.currentTime+dt
	end
end

cameraShake.getOffset = function(dt)
   return cameraShake.offset and cameraShake.offset or {0,0}
end


-- Transition

local transition = {}
effects.transition = transition

transition.start = function(type)
    transition.type = type
    transition.currentTime=0
end

transition.isOver = function()
    return transition.currentTime > TRANSITION_TIME
end
transition.update = function(dt)
    transition.currentTime=transition.currentTime+dt
    if transition.isOver() then
        transition.type = nil 
    else
        local tileCol = 0
        if transition.type == 'fadeout' then
            tileCol = utils.mapvalue(transition.currentTime, 0,TRANSITION_TIME,0,8)
        elseif transition.type == 'fadein' then
            tileCol = utils.mapvalue(transition.currentTime, 0,TRANSITION_TIME,8,0)
        end
        tileCol = math.floor(utils.constrain(tileCol, 0, 5))
        DSLeft.set('transition col', tileCol)

        transition.tileQuad = love.graphics.newQuad(tileCol*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight())
    end

end

transition.draw = function()
    if transition.currentTime < TRANSITION_TIME+0.05 then 
        for i=0,WIDTH*HEIGHT do
            local x, y = utils.indexToCoord(i, WIDTH)
            love.graphics.draw(tileset, transition.tileQuad, x*TILE_SIZE, y*TILE_SIZE)
        end
    end
end

-- Water

local water = {}
effects.water = water

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

water.update = function(dt)
    water.currentTime = water.currentTime + dt
end

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



-- Title

local title = {}
effects.title = title

title.currentTime=0
title.quad = love.graphics.newQuad(0, 14*TILE_SIZE, 8*TILE_SIZE, 3*TILE_SIZE, tileset:getWidth(), tileset:getHeight())

title.update = function(dt)
    title.currentTime = title.currentTime + dt
end

title.draw = function()
   local wave = (math.sin(title.currentTime)+1) / 2
   love.graphics.draw(tileset, title.quad, 6*TILE_SIZE, TILE_SIZE/2 + math.floor(wave*14), math.pi/2)
   love.graphics.draw(tileset, title.quad, DISPLAY_WIDTH-6*TILE_SIZE, DISPLAY_HEIGHT -TILE_SIZE/2 - math.floor(wave*14), math.pi*3/2)
end


return effects
