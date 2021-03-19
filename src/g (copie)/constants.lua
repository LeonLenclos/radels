DEBUG = true

--- size

TILE_SIZE = 30

WIDTH = 16
HEIGHT = 9

DISPLAY_WIDTH = TILE_SIZE*WIDTH
DISPLAY_HEIGHT = TILE_SIZE*HEIGHT
DISPLAY_PIXEL_RATIO = 4

--- time and speed

PLAYER_SPEED = 7 -- tiles per sec
BULLET_SPEED = 60 -- tiles per sec
SHOOT_RECOVERY_DURATION = 1/4 --sec

BOMB_SPEED = 30 -- tiles per sec
BOMB_REACH = 8
BOMB_LIFE = 3 -- lose 1 per sec
BOMB_DAMAGE = 1

MEDITATION_DURATION = 1 -- sec
MEDITATION_SPEED = 4 -- actions per sec

-- 
PLAYER_LIFE = 5
WALL_LIFE = 10

-- maps


ARENA_MAP = [[

 #....    ....# 
 #...#    #...# 
 #....    ....# 
 #2...    ...1# 
 #....    ....# 
 #...#    #...# 
 #....    ....# 

]]


PLAYGROUND_MAP =
 [[

 #............# 
 .............. 
 ......XX...... 
 2.....XX.....1 
 ......XX...... 
 .............. 
 #............# 

]]
