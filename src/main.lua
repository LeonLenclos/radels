------------------------------------------
-- Main -- The main script for the game --
------------------------------------------

require 'constants'

local DebugScreen = require 'lib.DebugScreen'
local panels = require 'panels'
local utils = require 'utils'
local output = require 'output'
local input = require 'input'
local scenes = require 'scenes'
local scores = require 'scores'
local audio = require 'audio'


function love.load()
  -- Graphics settings
  love.window.setMode(DISPLAY_WIDTH*DISPLAY_PIXEL_RATIO, DISPLAY_HEIGHT*DISPLAY_PIXEL_RATIO)
  love.graphics.setDefaultFilter('nearest')
  love.graphics.setBackgroundColor(BLACK)
  canvas = love.graphics.newCanvas(DISPLAY_WIDTH, DISPLAY_HEIGHT)
  tileset = love.graphics.newImage('tileset.png')

  -- Fonts
  dogicaFont = love.graphics.newFont("font/dogicapixel.ttf", 8, 'mono')
  debugFont = love.graphics.newFont("font/dogicapixel.ttf", 16, 'mono')
  numbersFont = love.graphics.newImageFont("font/numbers-font.png", "0123456789:")
  dogicaFont:setLineHeight(1.5)
  debugFont:setLineHeight(1.5)
  love.graphics.setFont(dogicaFont)

  -- audio
  audio.load()
  love.audio.setVolume(MASTER_VOLUME)

  -- Game Variables
  gameTime = 0

  -- Game elements
  panels.load()
  scenes.load(scenes.pause)

  --Debug
  DSLeft = DebugScreen.newDebugScreen(2,2,(DISPLAY_WIDTH*DISPLAY_PIXEL_RATIO)-4, 'left', true)
  DSRight = DebugScreen.newDebugScreen(2,2,(DISPLAY_WIDTH*DISPLAY_PIXEL_RATIO)-4, 'right', false)
end



function love.update(dt)
  -- Input
  input.update(dt)


  -- Logic
  panels.update(dt)
  scenes.update(dt)
  output.update(dt)

  -- Debug
  if DEBUG then
    DSRight.set('leds', output.debugString())
    DSRight.set('input', input.debugString())
    DSRight.set('gpio', input.gpioLog)
    DSRight.set('fps', utils.round(1/dt,2))
    DSLeft.set('scores', scores.player1 .. '/' .. scores.player2)
    DSLeft.set('remaining time')
    DSLeft.set('entities', #world.objects)
  end
end

function love.draw()
  -- First draw on the canvas.
  love.graphics.setCanvas(canvas)
  love.graphics.clear(0,0,0)
  -- love.graphics.clear(1,0,0)
  scenes.draw()
  panels.draw()

  -- Draw the canvas (scaled, and centered) on the window
  love.graphics.setCanvas()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(canvas, 0, 0, 0, DISPLAY_PIXEL_RATIO)

  -- Debug Hight resolution
  if DEBUG then
    love.graphics.setFont(debugFont)
    love.graphics.setColor(1, 0, 0)
    DSLeft.draw()
    DSRight.draw()
    love.graphics.setColor(1, 1, 1)
  end
end
