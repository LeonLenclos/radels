--------------------------------------------------------
-- Scenes -- There is two scenes, 'pause' and 'arena' --
--------------------------------------------------------
local scenes = {}

local scores = require 'scores'
local World = require 'World'
local Player = require 'entities.Player'
local effects = require 'effects'
local panels = require 'panels'
local output = require 'output'
local input = require 'input'
local audio = require 'audio'

--------------------------------------------------
-- Scenes

function scenes.load(scene)
   -- Transition
   if scenes.current then
	  effects.transition.start('fadeout')
   end
   -- logic
   nextScene = scene
   -- Sound
   audio.playSound('transition')
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

--------------------------------------------------
-- Pause scene

scenes.pause = {}

function scenes.pause.load()
   world = World('')
   panels.setPlayers()
   isReady = {
	  player1 = false,
	  player2 = false,
   }
   pauseTime = 0
   if gameTime > 0 then
	  audio.playMusic('pause')
   else
	  audio.stopMusic()
   end
   
end

function scenes.pause.update(dt)

   -- Auto play if players takes too long time to get ready
   if gameTime > 0 then
	  pauseTime = pauseTime + dt
	  if not audio.musics['pause']:isPlaying() then
		 audio.playMusic('pause')
	  end
   end
  if pauseTime > MAX_PAUSE_TIME then
	  scenes.load(scenes.arena)
   end
   
   -- Input
   if gameTime > 0 then
	  if input.p1_shoot or input.p1_action then
		 isReady.player1 = true
	  end

	  if input.p2_shoot or input.p2_action then
		 isReady.player2 = true
	  end

	  if isReady.player1 and isReady.player2 then
		 scenes.load(scenes.arena)
	  end
   end
   
   -- PlayerPanels
   for id, panel in panels.iter() do
	  if gameTime <= 0 then
		 panel:setMessage('INSERE UNE PIECE DE MONNAIE !')
	  elseif pauseTime > MAX_PAUSE_TIME - 3 then
		 panel:setMessage('ATTENTION ÇA VA COMMENCER...')
	  elseif not isReady[id] then
		 panel:setMessage('PRESSE UN BOUTON...')
	  else
		 panel:setMessage("L'AUTRE DOIT AUSSI APPUYER.")
	  end
   end
   
   -- Title
   effects.title.update(dt)
end

function scenes.pause.draw()
   world:draw()
   effects.title.draw()
end


--------------------------------------------------
-- Arena scene

scenes.arena = {}

function scenes.arena.load()
   world = World(ARENA_MAP)
   player1 = world:getById('player1')
   player2 = world:getById('player2')
   panels.setPlayers(player1, player2)
   for id, panel in panels.iter() do
	  panel:setMessage()
   end
   audio.playMusic('arena')
end

function scenes.arena.update(dt)
   -- Time
   gameTime = gameTime-dt > 0 and gameTime-dt or 0

   -- Input
   input.doPlayersInputs(player1, player2)

   -- Logic
   effects.target.update(dt)
   world:update(dt)
   output.update(dt)
   effects.cameraShake.update(dt)
   
   -- Output
   output.doPlayerOutput(player1, player2)


   -- End
   if player1:getProperty('toDelete') and player2:getProperty('toDelete') then
	  scores.player1 = scores.player1 + 1
	  scores.player2 = scores.player2 + 1
	  scores.lastWinner = 'both'
	  scenes.load(scenes.pause)
   elseif player1:getProperty('toDelete')  then
	  scores.player2 = scores.player2 + 1
	  scores.lastWinner = 'player2'
	  scenes.load(scenes.pause)
   elseif player2:getProperty('toDelete')  then
	  scores.player1 = scores.player1 + 1
	  scores.lastWinner = 'player1'
	  scenes.load(scenes.pause)
   end
end


function scenes.arena.draw()
   love.graphics.push()
   love.graphics.translate(unpack(effects.cameraShake.getOffset()))
   world:draw()
   effects.target.draw()
   love.graphics.pop()
end

return scenes
