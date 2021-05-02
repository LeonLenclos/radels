local audio = {}
local utils = require "utils"

function audio.load()
   audio.sounds = {}
   audio.loadSound('carpet')
   audio.loadSound('wall')
   audio.loadSound('bomb')
   audio.loadSound('bomb-explosion')
   audio.loadSound('shoot', 4)
   audio.loadSound('transition')
   audio.loadSound('impact')
   audio.loadSound('coin')
   audio.loadSound('meditation-charging')
   audio.loadSound('meditation1')
   audio.loadSound('meditation2')
   audio.loadSound('meditation3')

   audio.musics = {}
   audio.loadMusic('arena')
   audio.musics['arena']:setVolume(0.7)
   audio.loadMusic('pause')
   audio.musics['pause']:setVolume(0.6)
end

function audio.loadSound(name, variants)
   audio.sounds[name] = {}
   if variants then
	  audio.sounds[name].sources = {}
	  for i=1,variants do
		 local source = love.audio.newSource('audio/sounds/'..name..tostring(i)..'.wav', 'static')
		 audio.sounds[name].sources[i] = source
	  end
   else	 
	  audio.sounds[name].source = love.audio.newSource('audio/sounds/'..name..'.wav', 'static')
   end
end


function audio.loadMusic(name)
   audio.musics[name] = love.audio.newSource('audio/musics/'..name..'.wav', 'stream')

end

function audio.playMusic(name)
   for _, source in pairs(audio.musics) do
	  print(source)
	  source:stop()
   end
   audio.musics[name]:setLooping(true)
   audio.musics[name]:play()
end

function audio.playSound(name)
   local source
   if audio.sounds[name].source then
	  source = audio.sounds[name].source
   elseif audio.sounds[name].sources then
	  source = utils.choice(audio.sounds[name].sources)
   end


   if source:isPlaying() then
	  source = source:clone()
   end
   love.audio.play(source)
   return source
end


return audio
