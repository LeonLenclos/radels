local Entity = require "Entity"
local Bomb = Entity:extend()
local audio = require "audio"

function Bomb:new(x, y, directionX)
    Bomb.super.new(self, x+directionX, y,
        {
            type='bomb'
        },
        {
            base={
                rowOrigin=4,
                colOrigin=4,
            },
            impact={
                rowOrigin=4,
                colOrigin=5,
                colAnimated = true,
                animDuration=1/8,
                animLength=1,
                next='iddle'
            },
            shooted={
                rowOrigin=4,
                colOrigin=13,
                colAnimated = true,
                animDuration=1/8,
                animLength=1,
                next='iddle'
            },
            iddle={
                rowOrigin=4,
                colOrigin=6,
                colAnimated=true,
                animDuration=1/2,
                animLength=2,
                loop=true
            },
            death={
                rowOrigin=4,
                colOrigin=8,
                colAnimated=true,
                animDuration=1/8,
                animLength=2,
                next='none'
            },
            drowning={
                rowOrigin=4,
                colOrigin=10,
                colAnimated=true,
                animDuration=1/4,
                animLength=3,
                next='none'
            }
        }
    )
    self.directionX = directionX
    self.life = BOMB_LIFE
    self.countDown = BOMB_COUNT_DOWN
    self.reach = BOMB_REACH
    self.moveRecovery = 0
	audio.playSound('bomb')
end

function Bomb:update(dt)
    Bomb.super.update(self, dt)
    self.countDown = self.countDown - dt
    self.moveRecovery = self.moveRecovery + dt
    if self.reach > 0 and self.moveRecovery >= 1/BOMB_SPEED then
        self:move()
        self.moveRecovery = 0
    elseif self.reach <= 0 and not self:getProperty('isSolid') then
        self:setProperty('isSolid', true)
        self:setSpriteState('iddle')
    end
    if self.life>0 and self.countDown<=0 then
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
        self:setProperty('isSolid', true)
        self:setSpriteState('impact')
    end
end

function Bomb:explode(dt)
   audio.playSound('bomb-explosion')
   self.life = 0
    for x=-1,1 do
        for y=-1,1 do
            if x==0 or y==0 then
                for obj in world:iter(function(obj)
                    return obj.x == self.x + x and obj.y ==  self.y + y
                    and not obj:getProperty('isUnbreakable')
                    end) do
                    obj.life = obj.life - BOMB_DAMAGE
                end
            end
        end
    end
end

return Bomb
