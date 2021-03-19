

Parquet

Random =

1

Neighbours =

    [2]
    [ ]
    [4]

Abs Poisition 

y%2==0  -> 8


Tileset

tileState

tileStateDefinition = {
     random
}
tileFrame

fixedRandom(x+y*,1)>0.5

function(x, y, world) return




```


CarpetRowDetermination = {
    -- Top neighbour
    function(x,y, world) return world:isGroundAt(x, y+1) end,
    -- Bottom neighbour
    function(x,y, world) return world:isGroundAt(x, y-1) end,
    -- Right neighbour
    function(x,y, world) return world:isGroundAt(x+1, y) end,
    -- Left neighbour
    function(x,y, world) return world:isGroundAt(x-1, y) end,
}


WaterRowDetermination = {
    -- Top neighbour
    function(x,y, world) return world:isGroundAt(x, y+1) end,
    -- Bottom neighbour
    function(x,y, world) return world:isGroundAt(x, y-1) end,
    -- Right neighbour
    function(x,y, world) return world:isGroundAt(x+1, y) end,
    -- Left neighbour
    function(x,y, world) return world:isGroundAt(x-1, y) end,
}