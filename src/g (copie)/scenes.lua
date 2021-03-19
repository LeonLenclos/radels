local scenes = {}

local scores = require 'scores'
local World = require 'World'
local Player = require 'entities.Player'

local output = require 'output'
local input = require 'input'


function scenes.load(scene)
    scenes.current = scene
    scenes.current.load()
end

------------------------ DEMO

scenes.demo = {}

function scenes.demo.load()
    world = World('')
end

function scenes.demo.update(dt)
    -- Input
    if input.insert_coin then
        scenes.load(scenes.playground)
    end
end

function scenes.demo.draw()
    world:draw()
end

------------------------ PLAYGROUND

scenes.playground = {}

function scenes.playground.load()
    world = World(PLAYGROUND_MAP)
    player1 = world:getById('player1')
    player2 = world:getById('player2')
end

function scenes.playground.update(dt)
    -- Input
    if input.p1_up then player1:moveUp() end
    if input.p1_down then player1:moveDown() end
    if input.p1_left then player1:moveLeft() end
    if input.p1_right then player1:moveRight() end
    if input.p1_shoot then player1:shoot() end
    if input.p1_action then player1:action(dt) end
    if input.p2_up then player2:moveUp() end
    if input.p2_down then player2:moveDown() end
    if input.p2_left then player2:moveLeft() end
    if input.p2_right then player2:moveRight() end
    if input.p2_shoot then player2:shoot() end
    if input.p2_action then player2:action(dt) end

    -- Logic
    world:update(dt)
    output.update(dt)

    -- Output
    output.p1_life_1 = player1.life >= 1
    output.p1_life_2 = player1.life >= 2
    output.p1_life_3 = player1.life >= 3
    output.p1_life_4 = player1.life >= 4
    output.p1_life_5 = player1.life >= 5

    output.p1_action_1 = player1.SpecialActionIndex == 1
    output.p1_action_2 = player1.SpecialActionIndex == 2
    output.p1_action_3 = player1.SpecialActionIndex == 3

    output.p2_life_1 = player2.life >= 1
    output.p2_life_2 = player2.life >= 2
    output.p2_life_3 = player2.life >= 3
    output.p2_life_4 = player2.life >= 4
    output.p2_life_5 = player2.life >= 5

    output.p2_action_1 = player2.SpecialActionIndex == 1
    output.p2_action_2 = player2.SpecialActionIndex == 2
    output.p2_action_3 = player2.SpecialActionIndex == 3


    -- End
    if world:isReadyAreaAt(player1.x, player1.y)
    and world:isReadyAreaAt(player2.x, player2.y) then
        scenes.load(scenes.arena)
    end


    if player1.life == 0 then
        x, y = world:getRandomSpawnablePos()
        player1 = Player(x, y, 'player1')
        world:add(player1)
    end
    if player2.life == 0 then
        x, y = world:getRandomSpawnablePos()
        player2 = Player(x, y, 'player2')
        world:add(player2)
    end
end

function scenes.playground.draw()
    world:draw()
end

------------------------ ARENA

scenes.arena = {}

function scenes.arena.load()
    world = World(ARENA_MAP)
    player1 = world:getById('player1')
    player2 = world:getById('player2')
end

function scenes.arena.update(dt)
    -- Input
    if input.p1_up then player1:moveUp() end
    if input.p1_down then player1:moveDown() end
    if input.p1_left then player1:moveLeft() end
    if input.p1_right then player1:moveRight() end
    if input.p1_shoot then player1:shoot() end
    if input.p1_action then player1:action(dt) end
    if input.p2_up then player2:moveUp() end
    if input.p2_down then player2:moveDown() end
    if input.p2_left then player2:moveLeft() end
    if input.p2_right then player2:moveRight() end
    if input.p2_shoot then player2:shoot() end
    if input.p2_action then player2:action(dt) end
    
    -- Logic
    world:update(dt)
    output.update(dt)

    -- Output
    output.p1_life_1 = player1.life >= 1
    output.p1_life_2 = player1.life >= 2
    output.p1_life_3 = player1.life >= 3
    output.p1_life_4 = player1.life >= 4
    output.p1_life_5 = player1.life >= 5

    output.p1_action_1 = player1.SpecialActionIndex == 1
    output.p1_action_2 = player1.SpecialActionIndex == 2
    output.p1_action_3 = player1.SpecialActionIndex == 3

    output.p2_life_1 = player2.life >= 1
    output.p2_life_2 = player2.life >= 2
    output.p2_life_3 = player2.life >= 3
    output.p2_life_4 = player2.life >= 4
    output.p2_life_5 = player2.life >= 5

    output.p2_action_1 = player2.SpecialActionIndex == 1
    output.p2_action_2 = player2.SpecialActionIndex == 2
    output.p2_action_3 = player2.SpecialActionIndex == 3


    -- End
    if player1.life == 0 and player2.life == 0 then
        scores.player1 = scores.player1 + 1
        scores.player2 = scores.player2 + 1
        scenes.load(scenes.playground)
    elseif player1.life == 0 then
        scores.player2 = scores.player2 + 1
        scenes.load(scenes.playground)
    elseif player2.life == 0 then
        scores.player1 = scores.player1 + 1
        scenes.load(scenes.playground)
    end
end

function scenes.arena.draw()
    world:draw()
end

return scenes