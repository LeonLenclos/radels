local Entity = require "Entity"
local ArcadePlayer = Entity:extend()

local utils = require 'utils'
local scores = require 'scores'
local audio = require 'audio'
local effects = require 'effects'

local tileset = love.graphics.newImage('tileset.png')

function ArcadePlayer:new(x, y, id)
   local spriteCol = id=='player1' and 32 or 30
   ArcadePlayer.super.new(self, x, y,
					{
					   class='arcadePlayer',
					},
					{
					   base={
						  colOrigin=spriteCol,
              colRule=function() return self.shooting and 1 or 0 end,
						  rowRule=function() return 1-self.moving end,
					   },
					}
   )
   self.id = id
   self.shooting = false
   self.moving = 0
end

function ArcadePlayer:update(dt)
   ArcadePlayer.super.update(self, dt)
end


return ArcadePlayer
