local effects = {}

local utils = require "utils"
local tileset = love.graphics.newImage('tileset.png')

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
