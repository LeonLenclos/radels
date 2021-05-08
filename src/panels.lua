------------------------------------------------------------
-- Panels -- the player panels on each side of the screen --
------------------------------------------------------------
local panels = {}
local Object = require "lib.classic"
local PlayerPanel = Object:extend()

local utils = require "utils"
local scores = require "scores"

local quads = {}

-- Init the panels
function panels.load()
    -- Quads
    quads = {
        player2 = love.graphics.newQuad(10*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
        player1 = love.graphics.newQuad(11*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
        panel = love.graphics.newQuad(12*TILE_SIZE, 13*TILE_SIZE, HEIGHT*TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
        specialActions={
            love.graphics.newQuad(20*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
            love.graphics.newQuad(21*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
            love.graphics.newQuad(22*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
        },
        ready=love.graphics.newQuad(23*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
        win=love.graphics.newQuad(24*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
        loose=love.graphics.newQuad(25*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
		insertCoin=love.graphics.newQuad(26*TILE_SIZE, 13*TILE_SIZE, TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight()),
    }

	-- create a panel for each player
    panels.playerPanels = {
        player1=PlayerPanel('player1'),
        player2=PlayerPanel('player2'),
    }
end

-- Update the panels
function panels.update()
    for id, playerPanel in pairs(panels.playerPanels) do
        playerPanel:update(dt)
    end
end

-- Draw the panels
function panels.draw()
    for id, playerPanel in pairs(panels.playerPanels) do
        playerPanel:draw()
    end
end

-- Set the players for each panels
function panels.setPlayers(p1, p2)
    panels.playerPanels.player1:setPlayer(p1)
    panels.playerPanels.player2:setPlayer(p2)
end

-- Iter threw panels
function panels.iter()
    return pairs(panels.playerPanels)
end

--------------------------------------------------
-- PlayerPanel Class

-- constructor
function PlayerPanel:new(playerId)
    self.playerId = playerId
end

-- setter for .player
function PlayerPanel:setPlayer(player)
    self.player = player
end

-- setter for .message
function PlayerPanel:setMessage(message)
    self.message = message
end

-- Update the panel
function PlayerPanel:update(dt)
    -- Choose the right frame quad
   if self.player then
        if self.player.SpecialActionIndex then
            self.rightFrameQuad = quads.specialActions[self.player.SpecialActionIndex] -- Action logo
		else
            self.rightFrameQuad = nil
        end
	    elseif isReady and isReady[self.playerId] then
        self.rightFrameQuad = quads.ready
	elseif gameTime == 0 then
	   self.rightFrameQuad = quads.insertCoin -- Insert coin logo
	elseif scores.lastWinner == 'both' or scores.lastWinner == self.playerId then
	   self.rightFrameQuad = quads.win -- Win logo
	elseif scores.lastWinner then
	   self.rightFrameQuad = quads.loose -- Loose logo
    else
        self.rightFrameQuad = nil
    end
end

-- Draw the panel
function PlayerPanel:draw()

   -- Create a canvas to draw the panel
    local playerPanelCanvas = love.graphics.newCanvas(DISPLAY_HEIGHT, TILE_SIZE)
    love.graphics.setCanvas(playerPanelCanvas)
	-- Panel background with player face
    love.graphics.draw(tileset, quads[self.playerId], 0, 0)
    love.graphics.draw(tileset, quads.panel, TILE_SIZE, 0)

    -- Top bar
    if self.message then
	   -- Show message
        love.graphics.setFont(dogicaFont)
        love.graphics.setColor(BLACK)
        love.graphics.print(self.message, 31, 3)
        love.graphics.setColor(1,1,1)
    elseif self.player then
	   -- Show life bar
	   local life = self.player.life/PLAYER_LIFE
	   love.graphics.setColor(BLACK)
	   love.graphics.rectangle('fill', 31, 3, 201*life, 7)
	   love.graphics.setColor(1,1,1)
    end

    -- Right Frame
    if self.rightFrameQuad then
	   -- show logo
        love.graphics.draw(tileset, self.rightFrameQuad, 8*TILE_SIZE,0)
    elseif self.player and  self.player.actionCharge > 0 then
	   -- show meditation charge
		   local charge = self.player.actionCharge/MEDITATION_DURATION
		   love.graphics.setColor(BLACK)
		   love.graphics.rectangle('fill', 239, 3, math.floor(27*charge), 23)
		   love.graphics.setColor(1,1,1)
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

return panels
