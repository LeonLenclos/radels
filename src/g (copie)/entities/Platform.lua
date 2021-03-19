local Entity = require "Entity"
local Platform = Entity:extend()

function Platform:new(x, y)
    Platform.super.new(self, x, y, {
        isGround=true
    })
end

function Platform:draw()
    love.graphics.setColor(1, 1, 0)
    love.graphics.rectangle("fill", self.x*TILE_SIZE, self.y*TILE_SIZE, TILE_SIZE, TILE_SIZE)
end

return Platform