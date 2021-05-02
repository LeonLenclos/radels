local Entity = require "Entity"
local Bullet = Entity:extend()
local audio = require 'audio'

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
   self.hasMoved = false
   audio.playSound('shoot')
end


function Bullet:update(dt)
   Bullet.super.update(self, dt)

   if self.life<=0 then
	  return
   end
   
   self.moveRecovery = self.moveRecovery + dt
   if self.moveRecovery >= 1/BULLET_SPEED then
	  self:move()
	  self.hasMoved = true
   end

   local solidEntity = world:isSolidAt(self.x, self.y)
   -- meet an entity that is not a wall on first position
   if solidEntity and not (solidEntity:getProperty('type')=='wall' and not self.hasMoved)  then
	  audio.playSound('impact')
	  solidEntity.life = solidEntity.life -1
	  if solidEntity.spriteStates.shooted then
		 solidEntity:setSpriteState('shooted')
	  end
	  self.life = self.life -1
	  self.x = self.x - self.directionX
   end
end

function Bullet:move()
   self.x = self.x + self.directionX
   self.moveRecovery = 0
   if world:isOut(self.x, self.y) then
	  self:setProperty('toDelete', true)
   end
end

return Bullet
