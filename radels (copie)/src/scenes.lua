local scenes = {}

local scores = require 'scores'
local World = require 'World'
local Player = require 'entities.Player'

local effects = require 'effects'
local panels = require 'panels'
local output = require 'output'
local input = require 'input'


function scenes.load(scene)
    -- Transition
    if scenes.current then
        effects.transition.start('fadeout')
    end
    -- logic
    nextScene = scene
end


function scenes.update(dt)

    -- Transition
    if not scenes.current or (effects.transition.isOver() and nextScene) then
        scenes.current = nextScene
        scenes.current.load()
        nextScene = nil
        effects.transition.start('fadein')
    elseif effects.transition.isOver() then
        scenes.current.update(dt)
    end
    -- Effects
    effects.transition.update(dt)
    effects.water.update(dt)
end


function scenes.draw()
    effects.water.draw()
    scenes.current.draw()
    effects.transition.draw()
end

------------------------ PAUSE

scenes.pause = {}

function scenes.pause.load()
    world = World('')
    panels.setPlayers()
    isReady = {
        player1 = false,
        player2 = false,
    }
end

function scenes.pause.update(dt)
    -- Input
    if gameTime > 0 then
        if input.p1_shoot and input.p1_action then
            isReady.player1 = true
        end

        if input.p2_shoot and input.p2_action then
            isReady.player2 = true
        end

        if isReady.player1 and isReady.player2 then
            scenes.load(scenes.arena)
        end
    end
    -- PlayerPanels
    for id, panel in panels.iter() do
        if gameTime <= 0 then
            panel:setMessage('INSEREZ UNE PIECE DE MONNAIE !')
        elseif not isReady[id] then
            panel:setMessage('PRESSEZ A + B POUR COMMENCER...')
        elseif isReady.player1 and isReady.player2 then
            panel:setMessage()
        else
            panel:setMessage("L'AUTRE AUSSI DOIT PRESSER A + B")
        end
    end
end

function scenes.pause.draw()
    world:draw()
    effects.title.draw()
end


------------------------ ARENA

scenes.arena = {}

function scenes.arena.load()
    world = World(ARENA_MAP)
    player1 = world:getById('player1')
    player2 = world:getById('player2')
    panels.setPlayers(player1, player2)
end

function scenes.arena.update(dt)
    -- Input
    input.doPlayersInputs(player1, player2)

    -- Logic
    world:update(dt)
    output.update(dt)

    -- Output
    output.doPlayerOutput(player1, player2)


    -- End
    if player1:getProperty('toDelete') and player2:getProperty('toDelete') then
        scores.player1 = scores.player1 + 1
        scores.player2 = scores.player2 + 1
        scenes.load(scenes.pause)
    elseif player1:getProperty('toDelete')  then
        scores.player2 = scores.player2 + 1
        scenes.load(scenes.pause)
    elseif player2:getProperty('toDelete')  then
        scores.player1 = scores.player1 + 1
        scenes.load(scenes.pause)
    end
end


function scenes.arena.draw()
    world:draw()
end


------------------------ DEMO

-- scenes.demo = {}

-- function scenes.demo.load()
--     world = World('')
-- end

-- function scenes.demo.update(dt)
--     -- Input
--     if input.insert_coin then
--         scenes.load(scenes.playground)
--     end
-- end

-- function scenes.demo.draw()
--     world:draw()
-- end



------------------------ PLAYGROUND

-- scenes.playground = {}

-- function scenes.playground.load()
--     world = World(PLAYGROUND_MAP)
--     player1 = world:getById('player1')
--     player2 = world:getById('player2')
--     playerPanels.player1:setPlayer(player1)
--     playerPanels.player1:setPlayer(player2)
-- end

-- function scenes.playground.update(dt)
--     -- Input
--     input.doPlayersInputs(player1, player2)

--     -- Logic
--     world:update(dt)
--     output.update(dt)

--     -- Output
--     output.doPlayerOutput(player1, player2)

--     -- End
--     if world:isReadyAreaAt(player1.x, player1.y)
--     and world:isReadyAreaAt(player2.x, player2.y) then
--         scenes.load(scenes.arena)
--     end


--     if player1.life == 0 then
--         x, y = world:getRandomSpawnablePos()
--         player1 = Player(x, y, 'player1')
--         world:add(player1)
--     end
--     if player2.life == 0 then
--         x, y = world:getRandomSpawnablePos()
--         player2 = Player(x, y, 'player2')
--         world:add(player2)
--     end
-- end

-- function scenes.playground.draw()
--     world:draw()
-- end


--------------


return scenes
