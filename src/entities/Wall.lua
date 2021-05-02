local Entity = require "Entity"
local Wall = Entity:extend()
local audio = require 'audio'

function Wall:new(x, y)
    Wall.super.new(self, x, y,
        {
            type='wall',
            isSolid=true,
        },
        {
            birth={
                rowOrigin=3,
                colOrigin=12,
                colAnimated=true,
                animDuration=DEFAULT_BIRTH_DURATION,
                animLength=2,
            },
            base={
                rowOrigin=3,
                colRule=function() return self.life-1 end,
            },
            shooted={
                rowOrigin=3,
                colOrigin=6,
                colRule=function() return self.life-1 end,
                rowAnimated = true,
                animDuration=SHOOT_RECOVERY_DURATION/4,
                animLength=1,
                next='base',
            },
            death={
                rowOrigin=3,
                colOrigin=11,
                rowAnimated = true,
                animDuration=DEFAULT_DEATH_DURATION,
                animLength=1,
                next='none',
            }, 
            drowning={
                rowOrigin=4,
                colOrigin=10,
                colAnimated=true,
                animDuration=DEFAULT_DROWNING_DURATION,
                animLength=3,
                next='none'
            }
        }
    )
    self.life = WALL_LIFE
	audio.playSound('wall')
end


-- function Wall:draw()
--     Wall.tileSubSet:offsetColDraw(self.x, self.y, 0)
-- end

return Wall
