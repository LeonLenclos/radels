local Object = require "lib.classic"
local PlayerPanel = Object:extend()
local utils = require "utils"
local scores = require "scores"

-- Poperties :
--
-- type = str
-- isReadyArea = str
-- isGround = str
-- ...

local tileset = love.graphics.newImage('tileset.png')
local quads = {
    player2 = love.graphics.newQuad(10*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
    player1 = love.graphics.newQuad(11*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
    panel = love.graphics.newQuad(12*TILE_SIZE, 13*TILE_SIZE, HEIGHT*TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
    heartFull=love.graphics.newQuad(20*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE/3, TILE_SIZE/3, tileset:getWidth(), tileset:getHeight()),
    heartEmpty=love.graphics.newQuad(20*TILE_SIZE+20, 13*TILE_SIZE+10, TILE_SIZE/3, TILE_SIZE/3, tileset:getWidth(), tileset:getHeight()),
    specialActions={
        love.graphics.newQuad(21*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
        love.graphics.newQuad(22*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
        love.graphics.newQuad(23*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
    },
    ready=love.graphics.newQuad(24*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
    notReady=love.graphics.newQuad(25*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
    pause=love.graphics.newQuad(26*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
}


function PlayerPanel:new(playerId)
    self.playerId = playerId
end


function PlayerPanel:setPlayer(player)
    self.player = player
end

function PlayerPanel:setMessage(message)
    self.message = message
end



function PlayerPanel:update(dt)

    -- Right Frame
    if self.player then
        if self.player.SpecialActionIndex then
            self.rightFrameQuad = quads.specialActions[self.player.SpecialActionIndex]
        else
            self.rightFrameQuad = nil
        end
    elseif isReady and isReady[self.playerId] then
        self.rightFrameQuad = quads.ready
    else
        self.rightFrameQuad = nil
    end

end

function PlayerPanel:draw()

    local playerPanelCanvas = love.graphics.newCanvas(DISPLAY_HEIGHT, TILE_SIZE)
    love.graphics.setCanvas(playerPanelCanvas)

    love.graphics.draw(tileset, quads[self.playerId], 0, 0)
    love.graphics.draw(tileset, quads.panel, TILE_SIZE, 0)

    -- hearts/message
    if self.message then
        love.graphics.setFont(dogicaFont)
        love.graphics.setColor(BLACK)
        love.graphics.print(self.message, 31, 3)
        love.graphics.setColor(1,1,1)
    elseif self.player then
        for i=1, PLAYER_LIFE do
            love.graphics.draw(tileset, i<=self.player.life and quads.heartFull or quads.heartEmpty, 10*i+21, 0)
        end
    end
    -- Right Frame
    if self.rightFrameQuad then
        love.graphics.draw(tileset, self.rightFrameQuad, 8*TILE_SIZE,0)
    end

    -- Numbers
    love.graphics.setFont(numbersFont)
    if gameTime > 0 or (love.timer.getTime()%1>1/2) then
        love.graphics.print(string.format("%.2d:%.2d", gameTime/60%60, gameTime%60), 56,18)
    end
    love.graphics.print(string.format("%03d",scores[self.playerId]), 134,18)
    love.graphics.print(string.format("%03d",scores[self.playerId=='player1' and 'player2' or 'player1']), 197,18)

    -- Draw on canvas
    local x = self.playerId=='player1' and (WIDTH-1)*TILE_SIZE or TILE_SIZE
    local y = self.playerId=='player1' and HEIGHT*TILE_SIZE or 0
    local rotation = self.playerId=='player1' and (math.pi/2)*3 or math.pi/2 
    love.graphics.setCanvas(canvas)
    love.graphics.draw(playerPanelCanvas, x, y, rotation)
end

return PlayerPanel