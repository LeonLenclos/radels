local Entity = require "Entity"
local Bullet = Entity:extend()

function Bullet:new(x, y, directionX)
    Bullet.super.new(self, x+directionX, y,
        {
            type='bullet'
        },
        {
            base={
                colAnimated=true,
                rowOrigin=4,
                animDuration=1/BULLET_SPEED,
                next='course'
            },
            course={
                rowOrigin=4,
                colOrigin=1,
            },
            death={
                rowOrigin=4,
                colOrigin=2,
                colAnimated = true,
                animDuration=SHOOT_RECOVERY_DURATION/3*2,
                animLength=2,
                next='none'
            },
        }
    )
    self.directionX = directionX
    self.life = 1
    self.moveRecovery = 0
end


function Bullet:update(dt)
    Bullet.super.update(self, dt)
    self.moveRecovery = self.moveRecovery + dt
    if self.moveRecovery >= 1/BULLET_SPEED and self.life>0 then
        local x = self.x + self.directionX
        self.moveRecovery = 0
        local solidEntity = world:isSolidAt(x, self.y)
        if solidEntity then
            solidEntity.life = solidEntity.life -1
            if solidEntity.spriteStates.shooted then solidEntity:setSpriteState('shooted') end
            self.life = self.life -1
        elseif world:isOut(x, self.y) then
            self:setProperty('toDelete', true)
        else
            self.x = x
        end
    end
end

return Bullet