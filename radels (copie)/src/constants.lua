DEBUG = false

--- color

BLACK = {43/255, 32/255, 90/255}
WHITE = {246/255, 232/255, 214/255}

--- size

TILE_SIZE = 30

WIDTH = 16
HEIGHT = 9

DISPLAY_WIDTH = TILE_SIZE*WIDTH
DISPLAY_HEIGHT = TILE_SIZE*HEIGHT
DISPLAY_PIXEL_RATIO = 3

--- time and speed

PLAYER_SPEED = 4 -- tiles per sec
BULLET_SPEED = 20 -- tiles per sec
SHOOT_RECOVERY_DURATION = 1/4 --sec

BOMB_SPEED = 30 -- tiles per sec
BOMB_REACH = 8
BOMB_LIFE = 3
BOMB_COUNT_DOWN = 3 -- sec
BOMB_DAMAGE = 1
BOMB_COLLISION_DURATION = 0.05

MEDITATION_DURATION = 1 -- sec
MEDITATION_SPEED = 4 -- actions per sec

TRANSITION_TIME = 1/2
DEFAULT_DROWNING_DURATION = 1/4
DEFAULT_DEATH_DURATION = 1/8
DEFAULT_BIRTH_DURATION = 1/6
WATER_FRAME_DURATION = 1/4
-- 

COIN_VALUE = 10*60 -- sec

--
PLAYER_LIFE = 20
WALL_LIFE = 6

-- maps


ARENA_MAP = [[

  #....  ....# 
  #...#  #...# 
  #....  ....# 
  #2...  ...1# 
  #....  ....# 
  #...#  #...# 
  #....  ....# 

]]


PLAYGROUND_MAP =
 [[


  ............ 
  .....XX..... 
  2....XX....1 
  .....XX..... 
  ............ 


]]
