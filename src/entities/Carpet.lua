local Entity = require "Entity"
local Carpet = Entity:extend()
local audio = require 'audio'

function Carpet:new(x, y)
    Carpet.super.new(self, x, y,
        {
            type='carpet',
            isGround=true,
        },
        {
            base={
                rowOrigin=1,
                colBitwiseRuleSet={
                    -- Top neighbour
                    function(x,y, world) return world:isTypeAt('carpet', x, y-1) end,
                    -- Bottom neighbour
                    function(x,y, world) return world:isTypeAt('carpet', x, y+1) end,
                    -- Right neighbour
                    function(x,y, world) return world:isTypeAt('carpet', x+1, y) end,
                    -- Left neighbour
                    function(x,y, world) return world:isTypeAt('carpet', x-1, y) end,
                }
            },
            death={
                rowOrigin=1,
                colOrigin=16,
                colAnimated=true,
                animDuration=DEFAULT_DEATH_DURATION,
                animLength=1,
                next='none'

            },
            birth={
                rowOrigin=0,
                colOrigin=17,
                colRule=function()
                    if not world:isTypeAt('carpet', x, y-1) then -- Top neighbour
                        if not world:isTypeAt('carpet', x+1, y) then -- Right neighbour
                            return 0
                        elseif not world:isTypeAt('carpet', x-1, y) then -- Left neighbour
                            return 1
                        else
                            return 2
                        end
                    elseif not world:isTypeAt('carpet', x, y+1) then -- Bottom neighbour
                        if not world:isTypeAt('carpet', x+1, y) then -- Right neighbour
                            return 3
                        elseif not world:isTypeAt('carpet', x-1, y) then -- Left neighbour
                            return 4
                        else
                            return 5
                        end
                    elseif not world:isTypeAt('carpet', x+1, y) then -- Right neighbour
                        return 6
                    elseif not world:isTypeAt('carpet', x-1, y) then -- Left neighbour
                        return 7
                    else
                        return 8
                    end
                end,
                rowAnimated=true,
                animDuration=DEFAULT_BIRTH_DURATION,
                animLength=2,
            },
        }
    )
		audio.playSound('carpet')
end


-- function Carpet:draw()
--     Carpet.tileSubSet:bitwiseColDraw(self.x, self.y, world, Carpet.colDetermination)
-- end

return Carpet
