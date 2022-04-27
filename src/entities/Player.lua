local Entity = require "Entity"
local Player = Entity:extend()

local utils = require 'utils'
local Bullet = require 'entities.Bullet'
local Wall = require 'entities.Wall'
local Bomb = require 'entities.Bomb'
local Carpet = require 'entities.Carpet'
local scores = require 'scores'
local audio = require 'audio'
local effects = require 'effects'

local tileset = love.graphics.newImage('tileset.png')

function Player:new(x, y, id)
   local spriteRow = {
	  small = id=='player1' and 5 or 6,
	  big = id=='player1' and 7 or 10,
   }
   Player.super.new(self, x, y,
					{
					   class='player',
					   isSolid=true,
					},
					{
					   base={
						  rowOrigin = spriteRow.small
					   },
					   shooting={
						  rowOrigin = spriteRow.small,
						  colOrigin = 1,
						  colAnimated = true,
						  animDuration=SHOOT_RECOVERY_DURATION*2/3,
						  animLength=2,
						  next='base'
					   },
					   shooted={
						  rowOrigin = spriteRow.small,
						  colOrigin = 3,
						  colAnimated = true,
						  animDuration=SHOOT_RECOVERY_DURATION/3,
						  animLength=1,
						  next='base'
					   },
					   death={
						  width=3*TILE_SIZE,
						  height=3*TILE_SIZE,
						  rowOrigin = spriteRow.big,
						  colOrigin = 2,
						  colAnimated = true,
						  animDuration=SHOOT_RECOVERY_DURATION,-- sync with bullet death
						  animLength=3,
						  next='none'
					   },
					   drowning={
						  rowOrigin=spriteRow.small,
						  colOrigin=16,
						  colAnimated=true,
						  animDuration=DEFAULT_DROWNING_DURATION,
						  animLength=3,
						  next='none'
					   },
					   actionCharging={
						  rowOrigin=spriteRow.small,
						  colOrigin=19,
						  colRule=function() return self.SpecialActionIndex or 0 end,
					   },
					   action1={
						  width=3*TILE_SIZE,
						  height=3*TILE_SIZE,
						  rowOrigin=spriteRow.big,
						  colOrigin=11,
					   },
					   action2={
						  width=3*TILE_SIZE,
						  rowOrigin=spriteRow.small,
						  colOrigin=23,
					   },
					   action3={
						  width=3*TILE_SIZE,
						  rowOrigin=spriteRow.small,
						  colOrigin=26,
					   },
					   moveUp={
						  width=3*TILE_SIZE,
						  rowOrigin = spriteRow.small,
						  colOrigin = 4,
						  colRule = function(x, y, world) return (x%2)*3 end,
						  rowAnimated = true,
						  animDuration=1/PLAYER_SPEED/2,
						  animLength=1,
						  next='base'
					   },
					   moveDown={
						  width=3*TILE_SIZE,
						  rowOrigin = spriteRow.small,
						  colOrigin = 10,
						  colRule = function(x, y, world) return (x%2)*3 end,
						  rowAnimated = true,
						  animDuration=1/PLAYER_SPEED/2,
						  animLength=1,
						  next='base'
					   },
					   moveLeft={
						  height=3*TILE_SIZE,
						  rowOrigin = spriteRow.big,
						  colOrigin = 1,--id=='player1' and 0 or 1,
						  colAnimated = true,
						  animDuration=1/PLAYER_SPEED/2,
						  animLength=1,
						  next='base'
					   },
             moveRight={
						  height=3*TILE_SIZE,
						  rowOrigin = spriteRow.big,
						  colOrigin = 0,--id=='player1' and 1 or 0,
						  colAnimated = true,
						  animDuration=1/PLAYER_SPEED/2,
						  animLength=1,
						  next='base'
					   },
					}
   )
   self.id = id
   self.directionX = id == 'player1' and -1 or 1
   self.controlsDirectionX = self.directionX

   self.life = PLAYER_LIFE
   self.moveRecovery = 0

   self.actionCharge = 0
   self.actionCharging = false
   self.specialActionCharged = false
   self.SpecialActionIndex = nil
   self.specialActions = {self.placeCarpet,self.placeWall,self.throwBomb}


   self.shootRecovery = 0
end

function Player:update(dt)
   Player.super.update(self, dt)
   self.moveRecovery = self.moveRecovery + dt
   self.shootRecovery = self.shootRecovery + dt

   if self.moveRecovery >= 1/PLAYER_SPEED then
	  local distanceToOpponent = world:getById(self.id == 'player1' and 'player2' or 'player1').x - self.x
	  self.directionX = distanceToOpponent>0 and 1 or distanceToOpponent<0 and -1 or self.directionX
   end

   -- Target
   if self.specialActionCharged then
	  local targetX = self.x
	  local targetY = self.y
	  if self.SpecialActionIndex == 3 then --bomb
		 targetX = targetX + self.directionX
		 local reach = BOMB_REACH
		 while not world:isSolidAt(targetX + self.directionX, targetY) and reach > 0 do
			reach = reach - 1
			targetX = targetX+self.directionX
		 end
	  elseif self.SpecialActionIndex == 2 then --Box
		 targetX = targetX + self.directionX
		 if world:isSolidAt(targetX, targetY) then
			targetX = nil
			targetY = nil
		 end
	  end
	  effects.target.show(self.id, self.SpecialActionIndex, self.x, self.y, targetX, targetY)
   end



   if self.actionCharging then
	  -- Action Press
	  self:setSpriteState('actionCharging')
	  if self.actionCharge == 0 and not self.specialActionCharged then
		 self.meditationSound = audio.playSound('meditation-charging', self.controlsDirectionX)
	  end
	  self.actionCharge = self.actionCharge + dt
	  if not self.specialActionCharged and self.actionCharge > MEDITATION_DURATION then
		 local newIndex = 1 + math.floor(self.actionCharge*MEDITATION_SPEED%#self.specialActions)
		 if newIndex ~= self.SpecialActionIndex then
			audio.playSound('meditation' .. newIndex, self.controlsDirectionX)
		 end
		 self.SpecialActionIndex = newIndex
	  elseif self.specialActionCharged then
		 self:setSpriteState('action' .. self.SpecialActionIndex)
	  end
	  self.actionCharging = false
   elseif self.actionCharge > 0 and self.life>0 then
	  self:setSpriteState('base')
	  -- Action Release
	  if self.meditationSound then
		 self.meditationSound:stop()
	  end
	  if self.specialActionCharged then
		 local actionMethod = self.specialActions[self.SpecialActionIndex]
		 if actionMethod(self) then
			self.SpecialActionIndex = nil
			self.specialActionCharged = false
		 end
	  elseif self.SpecialActionIndex then
		 self.specialActionCharged = true
	  end
	  self.actionCharge = 0
   end

   -- Arrows
   if self.isOut then
     effects.arrow.show(self.id, self.x, self.y)
   end


end

function Player:moveTo(x, y)
   if(self.moveRecovery >= 1/PLAYER_SPEED and not world:isSolidAt(x, y)) and self.actionCharge == 0 then
	  audio.playSound('step')
	  self.x = x
	  self.y = y
	  self.moveRecovery = 0
    self.isOut = x >= WIDTH-1 or x <= 0 or y >= HEIGHT or y < 0
	  return true
   end
   return false
end

function Player:moveUp()
   if self.life > 0 and self:moveTo(self.x+self.directionX, self.y) then
	  self:setSpriteState('moveUp')
   end
end

function Player:moveDown()
   if self.life > 0 and self:moveTo(self.x-self.directionX, self.y) then
	  self:setSpriteState('moveDown')
   end
end

function Player:moveLeft()
   if self.life > 0 and self:moveTo(self.x, self.y-self.directionX) then
	  if self.directionX < 0 then
		 self:setSpriteState('moveRight')
	  else
		 self:setSpriteState('moveLeft')
	  end
   end
end

function Player:moveRight()
   if self.life > 0 and self:moveTo(self.x, self.y+self.directionX) then
	  if self.directionX > 0 then
		 self:setSpriteState('moveRight')
	  else
		 self:setSpriteState('moveLeft')
	  end
   end
end

function Player:shoot()
   if self.life > 0 and self.shootRecovery >= SHOOT_RECOVERY_DURATION and self.actionCharge == 0 then
	  self:setSpriteState('shooting')
	  world:add(Bullet(self.x, self.y, self.directionX))
	  self.shootRecovery = 0
   end
end

function Player:placeCarpet()
   for x=-1,1 do for y=-1,1 do
		 local carpet = Carpet(self.x+x, self.y+y)
		 world:add(carpet)
		 carpet:setSpriteState('birth')
   end end
   return true
end

function Player:placeWall()
   if not world:isSolidAt(self.x+self.directionX, self.y) then
	  local wall = Wall(self.x+self.directionX, self.y)
	  world:add(wall)
	  wall:setSpriteState('birth')
	  return true
   end
   return false
end

function Player:throwBomb()
   world:add(Bomb(self.x, self.y, self.directionX))
   return true
end

function Player:action(dt)
   if self.life > 0 then
	  self.actionCharging = true;
   end
end

return Player
