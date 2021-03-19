local Entity = require "Entity"
local ReadyArea = Entity:extend()

function ReadyArea:new(x, y)
    ReadyArea.super.new(self, x, y,
        {
            type='readyarea',
            isGround=true,
            isReadyArea=true,
            isUnbreakable=true,
        },
        {
            base={
                rowOrigin=2,
                colBitwiseRuleSet={
                    -- Top neighbour
                    function(x,y, world) return world:isTypeAt('readyarea', x, y-1) end,
                    -- Bottom neighbour
                    function(x,y, world) return world:isTypeAt('readyarea', x, y+1) end,
                    -- Right neighbour
                    function(x,y, world) return world:isTypeAt('readyarea', x+1, y) end,
                    -- Left neighbour
                    function(x,y, world) return world:isTypeAt('readyarea', x-1, y) end,
                }
            }
        }
    )
end


-- function ReadyArea:draw()
--     ReadyArea.tileSubSet:offsetColDraw(self.x, self.y, 0)
-- end

return ReadyArea