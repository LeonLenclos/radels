local Entity = require "Entity"
local Bullet = Entity:extend()

function Bullet:new(x, y, directionX)
    Bullet.super.new(self, x, y, {
    })
    self.directionX = directionX
    self.life = 1
    self.moveRecovery = 0
end

function Bullet:draw()
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", (self.x+0.5)*TILE_SIZE, (self.y+0.5)*TILE_SIZE, TILE_SIZE*0.1)
end

function Bullet:update(dt)
    self.moveRecovery = self.moveRecovery + dt
    if self.moveRecovery >= 1/BULLET_SPEED then
        self.x = self.x + self.directionX
        self.moveRecovery = 0
        local solidEntity = world:isSolidAt(self.x, self.y)
        if solidEntity then
            solidEntity.life = solidEntity.life -1
            self.life = self.life -1
        elseif world:isOut(self.x, self.y) then
            self.life = 0
        end
    end
end

return Bullet