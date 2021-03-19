require 'constants'
local DebugScreen = require 'lib.DebugScreen'
local utils = require 'utils'
local output = require 'output'
local input = require 'input'
local scenes = require 'scenes'
local scores = require 'scores'



function love.load()

    -- Graphics settings
    love.window.setMode(DISPLAY_WIDTH*DISPLAY_PIXEL_RATIO, DISPLAY_HEIGHT*DISPLAY_PIXEL_RATIO)
    love.graphics.setDefaultFilter('nearest')
    love.graphics.setBackgroundColor(0,0,0)
    canvas = love.graphics.newCanvas(DISPLAY_WIDTH, DISPLAY_HEIGHT)
    font = love.graphics.newFont("font/dogicapixel.ttf", 8, 'mono')
    font:setLineHeight(1.5)
    love.graphics.setFont(font)

    scenes.load(scenes.demo)

    --Debug
    DSLeft = DebugScreen.newDebugScreen(2,2,(DISPLAY_WIDTH*DISPLAY_PIXEL_RATIO)-4, 'left', true)
    DSRight = DebugScreen.newDebugScreen(2,2,(DISPLAY_WIDTH*DISPLAY_PIXEL_RATIO)-4, 'right', false)
end



function love.update(dt)

    input.update(dt)
    scenes.current.update(dt)
    output.update(dt)

    -- Debug
    DSRight.set('leds', output.debugString())
    DSRight.set('input', input.debugString())
    DSRight.set('fps', utils.round(1/dt,2))
    DSLeft.set('scores', scores.player1 .. '/' .. scores.player2)
    DSLeft.set('remaining time')
    DSLeft.set('entities', #world.objects)
end

function love.draw()
    -- First draw on the canvas.
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.2,0.2,0.2)
    scenes.current.draw(dt)

    -- Draw the canvas (scaled, and centered) on the window
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(canvas, 0, 0, 0, DISPLAY_PIXEL_RATIO)

    -- Debug Hight resolution
    if DEBUG then
        love.graphics.setColor(1, 1, 1)
        DSLeft.draw()
        DSRight.draw()
    end
end

