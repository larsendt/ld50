extends Node2D

var arrow_tile_index_map = {
    Vector2(0, -1): Vector2(0, 0),
    Vector2(0, 1): Vector2(1, 1),
    Vector2(1, 0): Vector2(1, 0),
    Vector2(-1, 0): Vector2(0, 1),
}

var room_size = 9
var room_border = 1
var tile_size = 32
var grid: GameGrid

func _ready():
    grid = GameGrid.new()
    update_tilemap()

func debug_info_for_position(world_pos) -> String:
    print("Show debug at: ", world_pos)
    var tile_pos = $TileMap.world_to_map(world_pos)
    var grid_pos = (tile_pos / room_size).floor()
    var cell = grid.atv(grid_pos)
    return ("cell([color=yellow]%d,%d[/color])\nfilled([color=yellow]%s[/color])\nconnect([color=yellow]\n\tn:%s,\n\ts:%s,\n\te:%s,\n\tw:%s[/color])" % 
        [cell["x"], cell["y"], cell["filled"], cell["north"], cell["south"], cell["east"], cell["west"]])

func update_tilemap():
    for y in range(0, grid.extents().y):
        for x in range(0, grid.extents().x):
            var cell = grid.at(x, y)
            if cell["filled"]:
                for tx in range((x*room_size)+room_border, ((x+1)*room_size)-room_border):
                    for ty in range((y*room_size)+room_border, ((y+1)*room_size)-room_border):
                        $TileMap.set_cell(tx, ty, 0)

                        if cell["came_from"] != Vector2.ZERO:
                            var ax = (x*room_size) + (room_size/2)
                            var ay = (y*room_size) + (room_size/2)
                            $ArrowTilemap.set_cell(ax, ay, 0, false, false, false, arrow_tile_index_map[cell["came_from"]])

                # TODO: generate hallways based on room_border
                if cell["north"]:
                    var dx = (x*room_size) + (room_size / 2)
                    var dy = y*room_size
                    $TileMap.set_cell(dx, dy, 0)
            
                if cell["south"]:
                    var dx = (x*room_size) + (room_size / 2)
                    var dy = ((y+1)*room_size)-1
                    $TileMap.set_cell(dx, dy, 0)

                if cell["east"]:
                    var dx = ((x+1)*room_size)-1
                    var dy = (y*room_size) + (room_size/2)
                    $TileMap.set_cell(dx, dy, 0)

                if cell["west"]:
                    var dx = x*room_size
                    var dy = (y*room_size) + (room_size/2)
                    $TileMap.set_cell(dx, dy, 0)


    $TileMap.update_bitmask_region(Vector2.ZERO, grid.extents()*room_size)
            
