--------------------------------------------------
-- Input -- arcade inputs / keyboard management --
--------------------------------------------------
local input = {}
local joysticks = love.joystick.getJoysticks()
local GPIO = nil
local utils = require 'utils'
-- init GPIO
function input.initGPIO()
   GPIO = require "GPIO"

   GPIO.setmode(GPIO.BOARD)
   GPIO.setwarnings(False)

   local led_port = 3
   GPIO.setup{
	  channel=ledport,
	  direction=GPIO.IN,
	  pull_up_down=GPIO.PUD_DOWN,
   }
end

function errorHandler(err)
   input.gpioLog = err
end

xpcall(input.initGPIO, errorHandler)

-- Update input
function input.update(dt)
   -- If two joysticks are plugged store input values from joystick, else take keyboard inputs
   -- Note that shoot is true only once per press (on press)

   if #joysticks >= 2  then
	  -- Push buttons
	  input.p1_shoot = not input.p1_shoot_pressed and joysticks[1]:isGamepadDown('a')
	  input.p1_shoot_pressed = joysticks[1]:isGamepadDown('a')
	  input.p1_action = joysticks[1]:isGamepadDown('b')

	  input.p2_shoot = not input.p2_shoot_pressed and joysticks[2]:isGamepadDown('a')
	  input.p2_shoot_pressed = joysticks[2]:isGamepadDown('a')
	  input.p2_action = joysticks[2]:isGamepadDown('b')

	  -- Joysticks
	  input.p1_up =    joysticks[1]:getGamepadAxis("lefty") < JOY_ORIGIN-JOY_SENSIBILITY
	  input.p1_down =  joysticks[1]:getGamepadAxis("lefty") > JOY_ORIGIN+JOY_SENSIBILITY
	  input.p1_left =  joysticks[1]:getGamepadAxis("leftx") < JOY_ORIGIN-JOY_SENSIBILITY
	  input.p1_right = joysticks[1]:getGamepadAxis("leftx") > JOY_ORIGIN+JOY_SENSIBILITY

	  input.p2_up =    joysticks[2]:getGamepadAxis("lefty") < JOY_ORIGIN-JOY_SENSIBILITY
	  input.p2_down =  joysticks[2]:getGamepadAxis("lefty") > JOY_ORIGIN+JOY_SENSIBILITY
	  input.p2_left =  joysticks[2]:getGamepadAxis("leftx") < JOY_ORIGIN-JOY_SENSIBILITY
	  input.p2_right = joysticks[2]:getGamepadAxis("leftx") > JOY_ORIGIN+JOY_SENSIBILITY

	  -- Mute
	  input.mute = joysticks[2]:isGamepadDown('x')
   else
	  -- Keys
	  input.p1_shoot = not input.p1_shoot_pressed and love.keyboard.isDown("l")
	  input.p1_shoot_pressed = love.keyboard.isDown("l")
	  input.p1_action = love.keyboard.isDown("m")

	  input.p2_shoot = not input.p2_shoot_pressed and love.keyboard.isDown("x")
	  input.p2_shoot_pressed = love.keyboard.isDown("x")
	  input.p2_action = love.keyboard.isDown("c")

	  -- Arrows
	  input.p1_up = love.keyboard.isDown("up")
	  input.p1_down = love.keyboard.isDown("down")
	  input.p1_left = love.keyboard.isDown("left")
	  input.p1_right = love.keyboard.isDown("right")

	  input.p2_up = love.keyboard.isDown("z")
	  input.p2_down = love.keyboard.isDown("s")
	  input.p2_left = love.keyboard.isDown("q")
	  input.p2_right = love.keyboard.isDown("d")

	  -- Mute key
	  input.mute = love.keyboard.isDown("space")
   end

   if GPIO then
	  input.mute = GPIO.input(3) ~= GPIO.LOW
   end

   input.konamiCheck()
end

input.konamiMemoryP1 = {}
input.konamiMemoryP2 = {}
input.konamiCallback = nil
function input.konamiCheck()
  local konami = {' ',
    'up', ' ', 'up', ' ', 'down', ' ', 'down', ' ',
    'left', ' ', 'right', ' ', 'left', ' ', 'right', ' ',
    'b', ' ', 'a', ' '
  }
  -- key storage for p1
  if input.p1_up then
    if input.konamiMemoryP1[#input.konamiMemoryP1] ~= 'up' then
      table.insert(input.konamiMemoryP1, 'up')
    end
  elseif input.p1_down  then
    if input.konamiMemoryP1[#input.konamiMemoryP1] ~= 'down' then
      table.insert(input.konamiMemoryP1, 'down')
    end
  elseif input.p1_left  then
    if input.konamiMemoryP1[#input.konamiMemoryP1] ~= 'left' then
      table.insert(input.konamiMemoryP1, 'left')
    end
  elseif input.p1_right  then
    if input.konamiMemoryP1[#input.konamiMemoryP1] ~= 'right' then
      table.insert(input.konamiMemoryP1, 'right')
    end
  elseif input.p1_shoot_pressed  then
    if input.konamiMemoryP1[#input.konamiMemoryP1] ~= 'a' then
      table.insert(input.konamiMemoryP1, 'a')
    end
  elseif input.p1_action  then
    if input.konamiMemoryP1[#input.konamiMemoryP1] ~= 'b' then
      table.insert(input.konamiMemoryP1, 'b')
    end
  elseif input.konamiMemoryP1[#input.konamiMemoryP1] ~= ' ' then
    table.insert(input.konamiMemoryP1, ' ')
  end
  -- key storage for p2
  if input.p2_up then
    if input.konamiMemoryP2[#input.konamiMemoryP2] ~= 'up' then
      table.insert(input.konamiMemoryP2, 'up')
    end
  elseif input.p2_down  then
    if input.konamiMemoryP2[#input.konamiMemoryP2] ~= 'down' then
      table.insert(input.konamiMemoryP2, 'down')
    end
  elseif input.p2_left  then
    if input.konamiMemoryP2[#input.konamiMemoryP2] ~= 'left' then
      table.insert(input.konamiMemoryP2, 'left')
    end
  elseif input.p2_right  then
    if input.konamiMemoryP2[#input.konamiMemoryP2] ~= 'right' then
      table.insert(input.konamiMemoryP2, 'right')
    end
  elseif input.p2_shoot_pressed  then
    if input.konamiMemoryP2[#input.konamiMemoryP2] ~= 'a' then
      table.insert(input.konamiMemoryP2, 'a')
    end
  elseif input.p2_action  then
    if input.konamiMemoryP2[#input.konamiMemoryP2] ~= 'b' then
      table.insert(input.konamiMemoryP2, 'b')
    end
  elseif input.konamiMemoryP2[#input.konamiMemoryP2] ~= ' ' then
    table.insert(input.konamiMemoryP2, ' ')
  end

  -- memory check for p1
  for i,k in ipairs(input.konamiMemoryP1) do
    if k ~= konami[i] then
      table.remove(input.konamiMemoryP1, 1)
      break
    end
  end

  -- memory check for p2
  for i,k in ipairs(input.konamiMemoryP2) do
    if k ~= konami[i] then
      table.remove(input.konamiMemoryP2, 1)
      break
    end
  end

  if #input.konamiMemoryP2 > 0 then
    print(utils.tableRepr(input.konamiMemoryP2))
  end

  if #konami == #input.konamiMemoryP1 or #konami == #input.konamiMemoryP2 then
    input.konamiCallback()
    input.konamiMemoryP1 = {}
    input.konamiMemoryP2 = {}
  end
end

-- Call player function for each input
function input.doArcadeInputs(player1, player2, cabinet)

   -- Player 1
   -- The controls are reverse if the players looks to the back

   -- Input for player animation
   player1.moving = 0
   if input.p1_right then player1.moving = -1 end
   if input.p1_left then player1.moving = 1 end

   player2.moving = 0
   if input.p2_right then player2.moving = -1 end
   if input.p2_left then player2.moving = 1 end

   player1.shooting = input.p1_shoot
   player2.shooting = input.p2_shoot

end

-- Call player function for each input
function input.doPlayersInputs(player1, player2)

   -- Player 1
   -- The controls are reverse if the players looks to the back
   local reverse = false
   if player1.controlsDirectionX ~= player1.directionX then
	  reverse = true
   end

   -- Move
   if not reverse then
	  if input.p1_up then player1:moveUp() end
	  if input.p1_down then player1:moveDown() end
	  if input.p1_left then player1:moveLeft() end
	  if input.p1_right then player1:moveRight() end
   else
	  if input.p1_up then player1:moveDown() end
	  if input.p1_down then player1:moveUp() end
	  if input.p1_left then player1:moveRight() end
	  if input.p1_right then player1:moveLeft() end
   end

   -- Shoot and action
   if input.p1_shoot then player1:shoot() end
   if input.p1_action then player1:action() end

   -- Player 2
   -- The controls are reverse if the players looks to the back
   reverse = false
   if player2.controlsDirectionX ~= player2.directionX then
	  reverse = true
   end

   -- Move
   if not reverse then
	  if input.p2_up then player2:moveUp() end
	  if input.p2_down then player2:moveDown() end
	  if input.p2_left then player2:moveLeft() end
	  if input.p2_right then player2:moveRight() end
   else
  	  if input.p2_up then player2:moveDown() end
	  if input.p2_down then player2:moveUp() end
	  if input.p2_left then player2:moveRight() end
	  if input.p2_right then player2:moveLeft() end
   end

   -- Shoot and Action
   if input.p2_shoot then player2:shoot() end
   if input.p2_action then player2:action() end
end

-- Return a string for input debugging
function input.debugString()
   local joydebug = ''
   if #joysticks >= 2 then
	  joydebug = '1 isGamePad = ' .. tostring(joysticks[1]:isGamepad())
		 .. '| 1 buttons = ' .. tostring(joysticks[1]:getButtonCount())
	     .. '| 2 isGamePad = ' .. tostring(joysticks[2]:isGamepad())
		 .. '| 2 buttons = ' .. tostring(joysticks[2]:getButtonCount())
   end
   return 'p1 controls = '
	  .. (input.p1_up and 'U' or '')
	  .. (input.p1_down and 'D' or '')
	  .. (input.p1_left and 'L' or '')
	  .. (input.p1_right and 'R' or '')
	  .. (input.p1_shoot and 'S' or '')
	  .. (input.p1_action and 'A' or '')
	  .. ' | p2 controls = '
	  .. (input.p2_up and 'U' or '')
	  .. (input.p2_down and 'D' or '')
	  .. (input.p2_left and 'L' or '')
	  .. (input.p2_right and 'R' or '')
	  .. (input.p2_shoot and 'S' or '')
	  .. (input.p2_action and 'A' or '')
	  .. ' | other = '
	  .. (input.mute and 'M' or '  ')
	  .. ' | ' .. joydebug
   	  .. ' | GPIO = ' .. tostring(GPIO)
end

return input
