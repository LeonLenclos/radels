local input = {}

-- local GPIO = require "GPIO"

-- GPIO.setmode(GPIO.BOARD)
-- GPIO.setwarnings(False)

-- local led_port = 3
-- GPIO.setup(ledport, GPIO.OUT)

-- local buttonPort = 7
-- GPIO.setup(buttonPort, GPIO.IN, GPIO.PUD_DOWN)


function input.update(dt)

    -- push buttons
    input.p1_shoot = love.keyboard.isDown("l")
    input.p1_action = love.keyboard.isDown("m")

    input.p2_shoot = love.keyboard.isDown("x")
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


    -- GPIO
    -- input.p1_shoot = input.p1_shoot or GPIO.input(buttonPort) == 1
    
end

function input.doPlayersInputs(player1, player2)
    if input.p1_up then player1:moveUp() end
    if input.p1_down then player1:moveDown() end
    if input.p1_left then player1:moveLeft() end
    if input.p1_right then player1:moveRight() end
    if input.p1_shoot then player1:shoot() end
    if input.p1_action then player1:action() end
    
    if input.p2_up then player2:moveUp() end
    if input.p2_down then player2:moveDown() end
    if input.p2_left then player2:moveLeft() end
    if input.p2_right then player2:moveRight() end
    if input.p2_shoot then player2:shoot() end
    if input.p2_action then player2:action() end
end

function input.debugString()
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
end

return input

