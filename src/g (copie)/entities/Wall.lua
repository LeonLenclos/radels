local Entity = require "Entity"
local Wall = Entity:extend()


function Wall:new(x, y)
    Wall.super.new(self, x, y, {
        isSolid=true
    })
    self.life = WALL_LIFE
end


function Wall:draw()
    love.graphics.setColor(0, 1-1/self.life, 1-1/self.life)
    love.graphics.rectangle("fill", (self.x+0.1)*TILE_SIZE, (self.y+0.2)*TILE_SIZE, TILE_SIZE*0.8, TILE_SIZE*0.6)
end

return Wall