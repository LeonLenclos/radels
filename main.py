import pygame
successes, failures = pygame.init()
print("{0} successes and {1} failures".format(successes, failures))


screen = pygame.display.set_mode((720, 480))
clock = pygame.time.Clock()
FPS = 60  # Frames per second.

TILE = 64;

BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
RED = (255, 0, 0)
GREEN = (0, 255, 0)
BLUE = (0, 0, 255)

image = pygame.Surface((32, 32))
image.fill(WHITE)  

game_objects = []

class GameObject(object):
    """docstring for GameObject"""
    def __init__(self, x, y, w, h):
        self.pos = x, y
        self.size = w, h
        game_objects.append(self)


    def __del__(self):
        game_objects.remove(self)

    def show(self):
        rect = pygame.Rect(self.pos, self.size)
        pygame.draw.rect(screen, RED, rect)


class Player(GameObject):
    """docstring for Player"""
    def __init__(self):
        super(Player, self).__init__(100,100,TILE,TILE)
        
        


player1 = Player()
game_objects.append(GameObject(6,6,TILE,TILE))
game_objects.append(GameObject(90,6,TILE,TILE))

while True:
    clock.tick(FPS)
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            quit()
        elif event.type == pygame.KEYDOWN:
            if event.key == pygame.K_z:
                rect.move_ip(0, -2)
            elif event.key == pygame.K_s:
                rect.move_ip(0, 2)
            elif event.key == pygame.K_q:
                rect.move_ip(-2, 0)
            elif event.key == pygame.K_d:
                rect.move_ip(2, 0)

    screen.fill(BLACK)

    for obj in game_objects:
        obj.show();

    pygame.display.update()