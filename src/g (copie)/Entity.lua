local Object = require "lib.classic"
local Entity = Object:extend()
local utils = require "utils"

-- Poperties :
--
-- type = str
-- isReadyArea = str
-- isGround = str
-- ...



function Entity:new(x, y, properties)
    self.life = 1
    self.x = x
    self.y = y
    self.properties = properties or {}
end

function Entity:getProperty(key)
    return self.properties[key]
end

function Entity:setProperty(key, value)
    self.properties[key] = value
end

function Entity:update(dt)
end

function Entity:draw()
end

return Entity