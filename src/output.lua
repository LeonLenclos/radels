----------------------------------------
-- Ouput -- GPIO output for leds etc. --
----------------------------------------

local output = {}

function output.update()

end

function output.setupGPIO()
    local GPIO=require "GPIO"
end

function output.doPlayerOutput(player1, player2)
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
end

function output.debugString()
    return 'p1 life = '
    .. (output.p1_life_1 and '¤' or '•')
    .. (output.p1_life_2 and '¤' or '•')
    .. (output.p1_life_3 and '¤' or '•')
    .. (output.p1_life_4 and '¤' or '•')
    .. (output.p1_life_5 and '¤' or '•')
    .. ' | p1 action = '
    .. (output.p1_action_1 and 'T' or '•')
    .. (output.p1_action_2 and 'M' or '•')
    .. (output.p1_action_3 and 'B' or '•')
    .. ' | p2 life = '
    .. (output.p2_life_1 and '¤' or '•')
    .. (output.p2_life_2 and '¤' or '•')
    .. (output.p2_life_3 and '¤' or '•')
    .. (output.p2_life_4 and '¤' or '•')
    .. (output.p2_life_5 and '¤' or '•')
    .. ' | p2 action = '
    .. (output.p2_action_1 and 'T' or '•')
    .. (output.p2_action_2 and 'M' or '•')
    .. (output.p2_action_3 and 'B' or '•')
end

return output
