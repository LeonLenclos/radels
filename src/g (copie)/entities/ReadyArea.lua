local Entity = require "Entity"
local ReadyArea = Entity:extend()


function ReadyArea:new(x, y)
    ReadyArea.super.new(self, x, y, {
        isGround=true,
        isReadyArea=true,
        isUnbreakable=true,
    })
end


function ReadyArea:draw()
    love.graphics.setColor(0.6, 0.6, 0.4)
    love.graphics.rectangle("fill", self.x*TILE_SIZE, self.y*TILE_SIZE, TILE_SIZE, TILE_SIZE)
end

return ReadyArea