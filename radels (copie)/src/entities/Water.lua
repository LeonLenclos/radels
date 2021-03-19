local Entity = require "Entity"
local Water = Entity:extend()

local utils = require "utils"
local TileSubSet = require "TileSubSet"

Water.tileSubSet = TileSubSet(0,1)

Water.colDetermination = {
    -- Top neighbour
    function(x,y, world) return world:isGroundAt(x, y-1) end,
    -- Bottom neighbour
    function(x,y, world) return world:isGroundAt(x, y+1) end,
    -- Right neighbour
    function(x,y, world) return world:isGroundAt(x+1, y) end,
    -- Left neighbour
    function(x,y, world) return world:isGroundAt(x-1, y) end,
    -- Top Right neighbour
    function(x,y, world) return world:isGroundAt(x+1, y-1) end,
    -- Bottom Right neighbour
    function(x,y, world) return world:isGroundAt(x+1, y+1) end,
    -- Top Left neighbour
    function(x,y, world) return world:isGroundAt(x-1, y-1) end,
    -- Bottom Left neighbour
    function(x,y, world) return world:isGroundAt(x-1, y+1) end,
}


function Water:new(x, y)
    Water.super.new(self, x, y, {
        isGround=false,
        type='water'
    })
end


function Water:draw()
    love.graphics.setColor(1, 1, 1)
    Water.tileSubSet:draw(self.x, self.y, world, Water.colDetermination)
end

return Water