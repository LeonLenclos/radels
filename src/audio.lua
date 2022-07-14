-------------------------------------
-- Audio -- play sounds and musics --
-------------------------------------

local audio = {}

local utils = require "utils"

-- Load sounds and musics
function audio.load()
   -- Paths
   audio.paths = {
	  sounds = 'audio/sounds/%s.wav',
	  musics = 'audio/musics/%s.wav'
   }

   -- Load sounds
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
   audio.loadSound('drown')
   audio.loadSound('death')
   audio.loadSound('step', 11)

   -- Load musics and set volumes
   audio.musics = {}
   audio.loadMusic('arena')
   audio.loadMusic('pause')
end

-- Load a sound giving a name and the amount of variants (default is no variant)
function audio.loadSound(name, variants)
   -- The sound is loaded in the audio.sounds table
   audio.sounds[name] = {}
   if variants then
	   -- sources are stored as a table in .sources if multiple variants
	  audio.sounds[name].sources = {}
	  for i=1,variants do
		 local variantName = name..tostring(i)
		 local source = love.audio.newSource(string.format(audio.paths.sounds, variantName), 'static')
		 audio.sounds[name].sources[i] = source
	  end
   else
	  -- source is stored in .source if no variant
	  audio.sounds[name].source = love.audio.newSource(string.format(audio.paths.sounds, name), 'static')
   end
end

-- Load a music giving a name
function audio.loadMusic(name)
   -- The music is loaded in the audio.musics table
   audio.musics[name] = love.audio.newSource(string.format(audio.paths.musics, name), 'stream')
end

-- Stop all the musics
function audio.stopMusic()
   for _, source in pairs(audio.musics) do
	  source:stop()
   end
end


-- Set the current music to be played in loop giving a name
function audio.playMusic(name)
   audio.stopMusic()
   -- Play the current music in loop
   audio.musics[name]:setLooping(true)
   audio.musics[name]:setVolume(MUSIC_VOLUME[name])
   audio.musics[name]:play()
end

-- Play a sound giving a name and an x position
function audio.playSound(name, x)
   -- Get the source
   local source
   if audio.sounds[name].source then
	  source = audio.sounds[name].source
   elseif audio.sounds[name].sources then
	  -- Get a random source if multiple variants
	  source = utils.choice(audio.sounds[name].sources)
   end

   -- Clone the source if it is already playing
   if source:isPlaying() then
	  source = source:clone()
   end

   -- Set source position if specified
   if x then
	  x = x * -1
	  source:setPosition(x,0,0)
   end

   -- Play the source
   love.audio.play(source)

   return source
end

return audio
