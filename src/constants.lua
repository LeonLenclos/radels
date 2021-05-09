-------------------------------------------
-- Constants -- game settings and values --
-------------------------------------------

-- Debug

DEBUG = false

-- Sounds

MASTER_VOLUME = 0.5 -- /1

-- Colors

BLACK = {43/255, 32/255, 90/255}
WHITE = {246/255, 232/255, 214/255}

-- Sizes

TILE_SIZE = 30 -- pixels

WIDTH = 16 -- tiles
HEIGHT = 9 -- tiles

DISPLAY_WIDTH = TILE_SIZE*WIDTH -- pixels
DISPLAY_HEIGHT = TILE_SIZE*HEIGHT -- pixels
DISPLAY_PIXEL_RATIO = 4

-- Player

PLAYER_SPEED = 4 -- tiles per sec
PLAYER_LIFE = 12 -- pv

-- Shoot

BULLET_SPEED = 20 -- tiles per sec
SHOOT_RECOVERY_DURATION = 1/4 --sec

-- Wall

WALL_LIFE = 6 -- pv

-- Bomb

BOMB_SPEED = 30 -- tiles per sec
BOMB_REACH = 6 -- tiles
BOMB_LIFE = 6 -- pv
BOMB_COUNT_DOWN = 3 -- sec
BOMB_DAMAGE = 1 -- pv
BOMB_COLLISION_DURATION = 0.05 -- sec

-- Meditation

MEDITATION_DURATION = 1 -- sec
MEDITATION_SPEED = 4 -- actions per sec

-- Durations

TRANSITION_TIME = 1/2 -- sec
DEFAULT_DROWNING_DURATION = 1/4 -- sec
DEFAULT_DEATH_DURATION = 1/8 -- sec
DEFAULT_BIRTH_DURATION = 1/6 -- sec
WATER_FRAME_DURATION = 1/4 -- sec
MAX_PAUSE_TIME = 20 --sec
TARGET_FRAME_DURATION = 1/8 -- sec
CAMERASHAKE_DURATION = 1/2 -- sec
CAMERASHAKE_FRAME_DURATION = 1/10 -- sec

-- Inputs

COIN_VALUE = 5*60 -- sec
JOY_SENSIBILITY = 0.6
JOY_ORIGIN = 0 

-- Map

ARENA_MAP = [[

  .....  ..... 
  ....#  #.... 
  #....  ....# 
  #2...  ...1# 
  #....  ....# 
  ....#  #.... 
  .....  ..... 

]]
