local Entity = require "Entity"
local Carpet = Entity:extend()

function Carpet:new(x, y)
    Carpet.super.new(self, x, y, {
        isGround=true
    })
end


function Carpet:draw()
    love.graphics.setColor(0.4, 1, 0.4)
    love.graphics.rectangle("fill", self.x*TILE_SIZE, self.y*TILE_SIZE, TILE_SIZE, TILE_SIZE)
end

return Carpet