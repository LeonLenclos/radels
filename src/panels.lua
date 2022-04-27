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
  function newQuad(x, w)
    w = w or 1
    return love.graphics.newQuad(x*TILE_SIZE, 14*TILE_SIZE, w*TILE_SIZE, TILE_SIZE, tileset:getWidth(), tileset:getHeight())
  end
  quads = {
    player1 = {
      iddle = newQuad(16),
      happy = newQuad(17),
      sad = newQuad(18),
      sleep = newQuad(19),
      dead = newQuad(20),
    },
    player2 = {
      iddle = newQuad(21),
      happy = newQuad(22),
      sad = newQuad(23),
      sleep = newQuad(24),
      dead = newQuad(25),
    },
    panelPause = newQuad(HEIGHT-1, HEIGHT-1),
    panelArena = newQuad(0, HEIGHT-1),
    specialActions = {
      newQuad(26),
      newQuad(27),
      newQuad(28),
    },
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
  if self.player
  and self.player.SpecialActionIndex then
    self.rightFrameQuad = quads.specialActions[self.player.SpecialActionIndex] -- Action logo
  else
    self.rightFrameQuad = nil
  end

  -- Choose the left frame quad
  local playerQuads = quads[self.playerId]
  if self.player then
    if self.player.spriteState=='shooted'
    or self.player.spriteState=='drowning'
    or self.player.spriteState=='death'
    or self.player.life <= 0 then
      self.leftFrameQuad = playerQuads.sad
    elseif self.player.spriteState=='actionCharging' then
      self.leftFrameQuad = playerQuads.sleep
    else
      self.leftFrameQuad = playerQuads.iddle
    end
  else
    if isReady and isReady[self.playerId] then
      self.leftFrameQuad = playerQuads.iddle
    elseif scores.lastWinner == 'both' or scores.lastWinner == self.playerId then
      self.leftFrameQuad = playerQuads.happy
    elseif scores.lastWinner then
      self.leftFrameQuad = playerQuads.dead
    else
      self.leftFrameQuad = playerQuads.iddle
    end
  end

  -- Life Bar
  if self.player then
    self.lifeBar = self.player.life/PLAYER_LIFE
    if self.player.spriteState=='shooted'
    and self.player:getSpriteState().animCurrentTime <= .1 then
      self.lifeBar = 0 -- blink on shooted
    end
  else
    self.lifeBar = nil
  end

  -- Meditation charge Bar
  if self.player
  and not self.player.SpecialActionIndex then
    self.meditationChargeBar = self.player.actionCharge/MEDITATION_DURATION
  else
    self.meditationChargeBar = nil
  end

end

-- Draw the panel
function PlayerPanel:draw()

  -- Create a canvas to draw the panel
  local playerPanelCanvas = love.graphics.newCanvas(DISPLAY_HEIGHT, TILE_SIZE)
  love.graphics.setCanvas(playerPanelCanvas)

  -- Panel background
  if self.player then
    love.graphics.draw(tileset, quads.panelArena, TILE_SIZE, 0)
  else
    love.graphics.draw(tileset, quads.panelPause, TILE_SIZE, 0)
  end

  if self.message then
    -- Show message
    love.graphics.setFont(dogicaFont)
    local textWidth  = dogicaFont:getWidth(self.message)
    love.graphics.setColor(BLACK)
    love.graphics.print(self.message, 148-textWidth/2, 11)
    love.graphics.setColor(1,1,1)
  end

  function drawBar(x,w,state)
    love.graphics.setColor(BLACK)
    love.graphics.rectangle('fill', x+math.floor(w*state), 3, w-math.floor(w*state), 23)
    love.graphics.setColor(1,1,1)
  end

  if self.lifeBar then
    drawBar(31, 203, self.lifeBar)
  end

  if self.meditationChargeBar then
    drawBar(241, 24, self.meditationChargeBar)
  end


  -- Right Frame
  if self.rightFrameQuad then
    love.graphics.draw(tileset, self.rightFrameQuad, 8*TILE_SIZE,0)
  end

  -- Left Frame
  if self.leftFrameQuad then
    love.graphics.draw(tileset, self.leftFrameQuad, 0, 0)
  end


  -- Draw on canvas
  local x = self.playerId=='player1' and (WIDTH-1)*TILE_SIZE or TILE_SIZE
  local y = self.playerId=='player1' and HEIGHT*TILE_SIZE or 0
  local rotation = self.playerId=='player1' and (math.pi/2)*3 or math.pi/2
  love.graphics.setCanvas(canvas)
  love.graphics.draw(playerPanelCanvas, x, y, rotation)
end

return panels
