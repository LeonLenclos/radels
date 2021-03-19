local Entity = require "Entity"
local Platform = Entity:extend()

local utils = require "utils"

function Platform:new(x, y)
    Platform.super.new(self, x, y,
        {
            type='platform',
            isGround=true,
        },
        {
            base={
                colBitwiseRuleSet={
                    -- Random
                    function(x,y) return utils.fixedRandom(x+y*WIDTH, 666)>0.5 end,
                    -- Absolute position
                    function(x,y) return y%2==0 end,
                    -- Top neighbour
                    function(x,y, world) return world:isTypeAt('platform', x, y+1) end,
                    -- Bottom neighbour
                    function(x,y, world) return world:isTypeAt('platform', x, y-1) end,
                }
            },
              death={
                colOrigin=16,
                colAnimated=true,
                animDuration=1/8,
                animLength=1,
                next='none'

            },
        }
    )
end

-- function Platform:draw()
--     love.graphics.setColor(1, 1, 1)
--     Platform.tileSubSet:bitwiseColDraw(self.x, self.y, world, Platform.colDetermination)
--     -- love.graphics.rectangle("fill", self.x*TILE_SIZE, self.y*TILE_SIZE, TILE_SIZE, TILE_SIZE)
-- end

return Platform