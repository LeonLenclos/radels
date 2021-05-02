local input = {}

local joysticks = love.joystick.getJoysticks()

-- local GPIO = require "GPIO"

-- GPIO.setmode(GPIO.BOARD)
-- GPIO.setwarnings(False)

-- local led_port = 3
-- GPIO.setup(ledport, GPIO.OUT)

-- local buttonPort = 7
-- GPIO.setup(buttonPort, GPIO.IN, GPIO.PUD_DOWN)


function input.update(dt)
   

   if #joysticks >= 2  then
	  
	  -- push buttons
	  input.p1_shoot = not input.p1_shoot_pressed and joysticks[1]:isGamepadDown('a')
	  input.p1_shoot_pressed =  joysticks[1]:isGamepadDown('a')
	  input.p1_action = joysticks[1]:isGamepadDown('b')

	  input.p2_shoot = not input.p2_shoot_pressed and joysticks[2]:isGamepadDown('a')
	  input.p2_shoot_pressed = joysticks[2]:isGamepadDown('a')
	  input.p2_action = joysticks[2]:isGamepadDown('b')

	  -- joysticks
	  input.p1_up =    joysticks[1]:getGamepadAxis("lefty") < JOY_ORIGIN-JOY_SENSIBILITY
	  input.p1_down =  joysticks[1]:getGamepadAxis("lefty") > JOY_ORIGIN+JOY_SENSIBILITY
	  input.p1_left =  joysticks[1]:getGamepadAxis("leftx") < JOY_ORIGIN-JOY_SENSIBILITY
	  input.p1_right = joysticks[1]:getGamepadAxis("leftx") > JOY_ORIGIN+JOY_SENSIBILITY

	  input.p2_up =    joysticks[2]:getGamepadAxis("lefty") < JOY_ORIGIN-JOY_SENSIBILITY
	  input.p2_down =  joysticks[2]:getGamepadAxis("lefty") > JOY_ORIGIN+JOY_SENSIBILITY
	  input.p2_left =  joysticks[2]:getGamepadAxis("leftx") < JOY_ORIGIN-JOY_SENSIBILITY
	  input.p2_right = joysticks[2]:getGamepadAxis("leftx") > JOY_ORIGIN+JOY_SENSIBILITY

	  -- coin
	  input.insert_coin = joysticks[1]:isGamepadDown('x') or joysticks[2]:isGamepadDown('x')
   else
	  -- push buttons
	  input.p1_shoot = not input.p1_shoot_pressed and love.keyboard.isDown("l")
	  input.p1_shoot_pressed = love.keyboard.isDown("l")
	  input.p1_action = love.keyboard.isDown("m")

	  input.p2_shoot = not input.p2_shoot_pressed and love.keyboard.isDown("x")
	  input.p2_shoot_pressed = love.keyboard.isDown("x")
	  input.p2_action = love.keyboard.isDown("c")

	  -- joysticks
	  input.p1_up = love.keyboard.isDown("up")
	  input.p1_down = love.keyboard.isDown("down") 
	  input.p1_left = love.keyboard.isDown("left")
	  input.p1_right = love.keyboard.isDown("right")

	  input.p2_up = love.keyboard.isDown("z")
	  input.p2_down = love.keyboard.isDown("s")
	  input.p2_left = love.keyboard.isDown("q")
	  input.p2_right = love.keyboard.isDown("d")

	  -- coin
	  input.insert_coin = love.keyboard.isDown("space")


   end

end

function input.doPlayersInputs(player1, player2)
   local reverse = false
   if player1.controlsDirectionX ~= player1.directionX then
	  reverse = true
   end

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

   if input.p1_shoot then player1:shoot() end
   if input.p1_action then player1:action() end
   
   reverse = false
   if player2.controlsDirectionX ~= player2.directionX then
	  reverse = true
   end

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
   
   if input.p2_shoot then player2:shoot() end
   if input.p2_action then player2:action() end
end

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
	  .. (input.insert_coin and 'C' or '  ')
	  .. ' | ' .. joydebug
   
end

return input

