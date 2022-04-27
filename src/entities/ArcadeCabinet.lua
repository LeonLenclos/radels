local Entity = require "Entity"
local ArcadeCabinet = Entity:extend()
local effects = require "effects"
local utils = require "utils"
local audio = require "audio"

function ArcadeCabinet:new(x, y, id)
    ArcadeCabinet.super.new(self, x, y,
        {
            type='arcadeCabinet',
        },
        {
            base={
                rowOrigin=3,
                colOrigin=30
          },
        }
      )

    self.w=12
    self.h=10
    self.id = id
    self.p1={
      shootRecovery=0,
      x=self.w,
      y=self.h/2,
      life=5
    }
    self.p2={
      shootRecovery=0,
      x=0,
      y=self.h/2,
      life=5
    }
    self.bullets = {}
    self.frameDuration = 0
end

function ArcadeCabinet:update(dt)
  self.frameDuration = self.frameDuration + dt
  self.p1.shootRecovery = self.p1.shootRecovery + dt
  self.p2.shootRecovery = self.p2.shootRecovery + dt
  if self.frameDuration > 1/10 then
    self.frameDuration = 0
    if player1 or player2 then
      self.p1.y = self.p1.y + player1.moving
      self.p2.y = self.p2.y - player2.moving
      self.p2.y = utils.constrain(self.p2.y, 1, self.h)
      self.p1.y = utils.constrain(self.p1.y, 1, self.h)
    end
    for i,bullet in ipairs(self.bullets) do
      bullet.x = bullet.x + bullet.dir
      if bullet.x == self.p1.x and bullet.y == self.p1.y then
        self.p1.life = self.p1.life-1
        bullet.destroy = true
      elseif bullet.x == self.p2.x and bullet.y == self.p2.y then
        self.p2.life = self.p2.life-1
        bullet.destroy = true
      end
      if bullet.x > self.w or bullet.x < 0 then
        bullet.destroy = true
      end
    end

    for i=#self.bullets,1,-1 do
      if self.bullets[i].destroy then
          table.remove(self.bullets, i)
      end
    end

  end


  if player1 or player2 then
    if player1.shooting and self.p1.shootRecovery > SHOOT_RECOVERY_DURATION then
      self.p1.shootRecovery = 0
      table.insert(self.bullets, {
        x=self.p1.x-1,
        y=self.p1.y,
        dir=-1,
      })
      audio.playSound('shoot')
    end
    if player2.shooting and self.p2.shootRecovery > SHOOT_RECOVERY_DURATION then
      self.p2.shootRecovery = 0
      table.insert(self.bullets, {
        x=self.p2.x+1,
        y=self.p2.y,
        dir=1,
      })
      audio.playSound('shoot')
    end

  end

  if self.p1.life < 0 then
    self.winner = 'player2'
    if self.p2.life < 0 then
      self.winner = 'both'
    end
  elseif self.p2.life < 0 then
    self.winner = 'player1'
  end

  effects.arcade.show(self)

end

return ArcadeCabinet
