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
var item_positions = []

func _ready():
    grid = GameGrid.new()
    update_tilemap()

func starting_position() -> Vector2:
    var starting_cell = grid.starting_cell
    return tile_to_global(grid_to_room_center_tilespace(Vector2(starting_cell["x"], starting_cell["y"])))

func debug_info_for_position(world_pos) -> String:
    print("Show debug at: ", world_pos)
    var tile_pos = $TileMap.world_to_map(world_pos)
    var grid_pos = (tile_pos / room_size).floor()
    var cell = grid.atv(grid_pos)
    return ("cell([color=yellow]%d,%d[/color])\nfilled([color=yellow]%s[/color])\nconnect([color=yellow]\n\tn:%s,\n\ts:%s,\n\te:%s,\n\tw:%s[/color])" % 
        [cell["x"], cell["y"], cell["filled"], cell["north"], cell["south"], cell["east"], cell["west"]])

func grid_to_tile(grid_pos: Vector2) -> Vector2:
    return grid_pos * Vector2(room_size, room_size)

func tile_to_global(tile_pos: Vector2) -> Vector2:
    return tile_pos * Vector2(tile_size, tile_size)

func grid_to_global(grid_pos: Vector2) -> Vector2:
    return tile_to_global(grid_to_tile(grid_pos))

func grid_to_room_center_tilespace(grid_pos: Vector2) -> Vector2:
    return grid_to_tile(grid_pos) + (Vector2(room_size, room_size)/2)

func update_tilemap():
    for y in range(0, grid.extents().y):
        for x in range(0, grid.extents().x):
            var cell = grid.at(x, y)

            if cell["has_item"]:
                item_positions.push_back(tile_to_global(grid_to_room_center_tilespace(Vector2(x, y))))

            if cell["filled"]:
                generate_room(Vector2(x, y), cell)

    $TileMap.update_bitmask_region(Vector2.ZERO, grid.extents()*room_size)
    $WallTileMap.update_bitmask_region(Vector2.ZERO, grid.extents()*room_size)
            
func generate_room(grid_pos, cell):
    var room_min = grid_to_tile(grid_pos)
    var room_max = grid_to_tile(grid_pos+Vector2(1.0, 1.0))

    for tx in range(room_min.x, room_max.x):
        for ty in range(room_min.y, room_max.y):
            if ty <= room_min.y + room_border:
                if tx == int(room_min.x + (room_size / 2)) && cell["north"]:
                    # vertical centerline, need a floor if there's a connection to the north
                    $TileMap.set_cell(tx, ty, 0)
                else:
                    # non-centerline there's no connection to the north
                    $WallTileMap.set_cell(tx, ty, 0)
            elif ty >= room_max.y - room_border:
                if tx == int(room_min.x + (room_size / 2)) && cell["south"]:
                    # vertical centerline, need a floor if there's a connection to the south
                    $TileMap.set_cell(tx, ty, 0)
                else:
                    # non-centerline there's no connection to the south
                    $WallTileMap.set_cell(tx, ty, 0)
            elif tx <= room_min.x + room_border:
                if ty == int(room_min.y + (room_size / 2)) && cell["west"]:
                    # horizontal centerline, need a floor if there's a connection to the west
                    $TileMap.set_cell(tx, ty, 0)
                else:
                    # non-centerline there's no connection to the west
                    $WallTileMap.set_cell(tx, ty, 0)
            elif tx >= room_max.x - room_border:
                if ty == int(room_min.y + (room_size / 2)) && cell["east"]:
                    # horizontal centerline, need a floor if there's a connection to the east
                    $TileMap.set_cell(tx, ty, 0)
                else:
                    # non-centerline there's no connection to the east
                    $WallTileMap.set_cell(tx, ty, 0)
            else:
                # interior of a room
                $TileMap.set_cell(tx, ty, 0)

            if cell["came_from"] != Vector2.ZERO:
                var ax = room_min.x + (room_size/2)
                var ay = room_min.y + (room_size/2)
                $ArrowTilemap.set_cell(ax, ay, 0, false, false, false, arrow_tile_index_map[cell["came_from"]])


    if cell["south"]:
        var dx = room_min.x + (room_size / 2)
        var dy = room_max.y-1
        $TileMap.set_cell(dx, dy, 0)

    if cell["east"]:
        var dx = room_max.x-1
        var dy = room_min.y + (room_size/2)
        $TileMap.set_cell(dx, dy, 0)

    if cell["west"]:
        var dx = room_min.x
        var dy = room_min.y + (room_size/2)
        $TileMap.set_cell(dx, dy, 0)
