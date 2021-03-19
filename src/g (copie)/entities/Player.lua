local Entity = require "Entity"
local Player = Entity:extend()

local Bullet = require 'entities.Bullet'
local Wall = require 'entities.Wall'
local Bomb = require 'entities.Bomb'
local Carpet = require 'entities.Carpet'

function Player:new(x, y, id)
    Player.super.new(self, x, y, {
        isSolid=true
    })
    self.id = id
    self.directionX = id == 'player1' and -1 or 1
    self.life = PLAYER_LIFE
    self.moveRecovery = 0

    self.actionCharge = 0
    self.actionCharging = false
    self.specialActionCharged = false
    self.SpecialActionIndex = nil
    self.specialActions = {self.placeCarpet,self.placeWall,self.throwBomb}


    self.shootRecovery = 0
end

function Player:draw()
    if self.id == 'player1' then
        love.graphics.setColor(0, 0, 1)
    elseif self.id == 'player2' then
        love.graphics.setColor(1, 0, 0)
    end
    love.graphics.circle("fill", (self.x+0.5)*TILE_SIZE, (self.y+0.5)*TILE_SIZE, TILE_SIZE*0.4)
end

function Player:update(dt)
    self.super:update(dt)
    self.moveRecovery = self.moveRecovery + dt
    self.shootRecovery = self.shootRecovery + dt

    if self.actionCharging then
        -- Action Press
        if not self.specialActionCharged and self.actionCharge > MEDITATION_DURATION then
            self.SpecialActionIndex = 1 + math.floor(self.actionCharge*MEDITATION_SPEED%#self.specialActions)
        end
        self.actionCharging = false
    elseif self.actionCharge > 0 then
        -- Action Release
        if self.specialActionCharged then
            self.specialActions[self.SpecialActionIndex](self)
            self.SpecialActionIndex = nil
            self.specialActionCharged = false
        elseif self.SpecialActionIndex then
            self.specialActionCharged = true
        end
        self.actionCharge = 0
    end
end

function Player:moveTo(x, y)
    if(self.moveRecovery >= 1/PLAYER_SPEED and not world:isSolidAt(x, y)) then
        self.x = x
        self.y = y
        self.moveRecovery = 0
    end
end

function Player:moveUp()
    self:moveTo(self.x, self.y-1)
end

function Player:moveDown()
    self:moveTo(self.x, self.y+1)
end

function Player:moveLeft()
    self:moveTo(self.x-1, self.y)
end

function Player:moveRight()
    self:moveTo(self.x+1, self.y)
end

function Player:shoot()
    if(self.shootRecovery >= SHOOT_RECOVERY_DURATION) then
        world:add(Bullet(self.x, self.y, self.directionX))
        self.shootRecovery = 0
    end
end

function Player:placeCarpet()
    for x=-1,1 do for y=-1,1 do
        world:add(Carpet(self.x+x, self.y+y))
    end end
end

function Player:placeWall()
    if not world:isSolidAt(self.x+self.directionX, self.y) then
        world:add(Wall(self.x+self.directionX, self.y))
    end
end

function Player:throwBomb()
    world:add(Bomb(self.x, self.y, self.directionX))
end

function Player:action(dt)
    self.actionCharging = true;
    self.actionCharge = self.actionCharge + dt
end

return Player