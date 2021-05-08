---------------------------------------------
-- Scores -- this module just store scores --
---------------------------------------------

local scores = {}

scores.reset = function()
    scores.player1 = 0
    scores.player2 = 0
end

scores.reset()

return scores

