local Entity = require "Entity"
local Bomb = Entity:extend()

function Bomb:new(x, y, directionX)
    Bomb.super.new(self, x+directionX, y, {
    })
    self.directionX = directionX
    self.life = BOMB_LIFE
    self.reach = BOMB_REACH
    self.moveRecovery = 0
end

function Bomb:draw()
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.circle("fill", (self.x+0.5)*TILE_SIZE, (self.y+0.5)*TILE_SIZE, TILE_SIZE*0.3)
end


function Bomb:update(dt)
    self.life = self.life - dt
    self.moveRecovery = self.moveRecovery + dt
    if self.reach > 0 and self.moveRecovery >= 1/BOMB_SPEED then
        self:move()
        self.moveRecovery = 0
    elseif self.reach <= 0 then
        self:setProperty('isSolid', true)
    end

    if self.life<=0 then
        self:explode()
    end
end

function Bomb:move()
    local x = self.x + self.directionX
    if not world:isSolidAt(x, self.y) then
        self.x = x
        self.reach = self.reach -1
    else
        self.reach = 0
    end
end

function Bomb:explode(dt)
    for x=-1,1 do
        for y=-1,1 do
            if x==0 or y==0 then
                for obj in world:iter(function(obj)
                    return obj.x == self.x + x and obj.y ==  self.y + y
                    and not obj:getProperty('isUnbreakable')
                    end) do
                    print(i,v)
                    obj.life = obj.life - BOMB_DAMAGE
                end
            end
        end
    end
end

return Bomb