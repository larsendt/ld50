extends Node2D

onready var Room0 = preload("res://rooms/Room0.tscn")
onready var Room1 = preload("res://rooms/Room1.tscn")
onready var Room2 = preload("res://rooms/Room2.tscn")
onready var Room3 = preload("res://rooms/Room3.tscn")
onready var Room4 = preload("res://rooms/Room4.tscn")
onready var Room5 = preload("res://rooms/Room5.tscn")
onready var EmptyRoom = preload("res://rooms/EmptyRoom.tscn")
onready var LastRoom = preload("res://rooms/LastRoom.tscn")
onready var rooms = [Room0, Room1, Room2, Room3, Room4, Room5]
onready var rng = RandomNumberGenerator.new()

var arrow_tile_index_map = {
    Vector2(0, -1): Vector2(0, 0),
    Vector2(0, 1): Vector2(1, 1),
    Vector2(1, 0): Vector2(1, 0),
    Vector2(-1, 0): Vector2(0, 1),
}

var room_size = Vector2(15, 15)
var room_padding = Vector2(1, 1)
var room_margin = Vector2(9, 9)
var tile_size = Vector2(32, 32)
var grid: GameGrid
var items = []

func _ready():
    randomize()
    grid = GameGrid.new()
    generate_tilemaps()

func get_items():
    return items

func starting_position() -> Vector2:
    # TODO: get this directly from the starting cell
    var starting_cell = grid.starting_cell
    return tile_to_global(grid_to_room_center_tilespace(Vector2(starting_cell["x"], starting_cell["y"])))

func debug_info_for_position(world_pos) -> String:
    print("Show debug at: ", world_pos)
    var tile_pos = $RoomTileMap.world_to_map(world_pos)
    var grid_pos = tile_to_grid(tile_pos)
    var cell = grid.atv(grid_pos)
    if cell != null:
        return ("cell([color=yellow]%d,%d[/color])\nfilled([color=yellow]%s[/color])\nconnect([color=yellow]\n\tn:%s,\n\ts:%s,\n\te:%s,\n\tw:%s[/color])" % 
            [cell["x"], cell["y"], cell["filled"], cell["north"], cell["south"], cell["east"], cell["west"]])
    else:
        return "???"

func grid_to_tile(grid_pos: Vector2) -> Vector2:
    return grid_pos * (room_size + (room_margin*2))

func tile_to_grid(tile_pos: Vector2) -> Vector2:
    return (tile_pos / ((room_margin*2) + room_size)).floor()

func tile_to_global(tile_pos: Vector2) -> Vector2:
    return tile_pos * tile_size

func grid_to_global(grid_pos: Vector2) -> Vector2:
    return tile_to_global(grid_to_tile(grid_pos))

func grid_to_room_center_tilespace(grid_pos: Vector2) -> Vector2:
    return grid_to_tile(grid_pos) + ((room_size+room_margin+room_margin)/2)

func generate_tilemaps():
    for y in range(0, grid.extents().y):
        for x in range(0, grid.extents().x):
            var grid_pos = Vector2(x, y)
            var cell = grid.atv(grid_pos)

            if cell["filled"]:
                if cell["room_type"] == "starting_room":
                    var room = Room0.instance()
                    room.set_cell(cell)
                    merge_room(grid_pos, room)

                    var item_spawn_pos = room.get_item_spawn_pos()
                    if item_spawn_pos != null:
                        var global_pos = tile_to_global(grid_to_tile(grid_pos) + room_margin) + item_spawn_pos
                        items.push_back({"world_pos": global_pos})
                elif cell["room_type"] == "last_room":
                    var room = LastRoom.instance()
                    room.set_cell(cell)
                    merge_room(grid_pos, room)
                    $VictoryPortal.position = tile_to_global(grid_to_room_center_tilespace(grid_pos))
                else:
                    var room = rooms[rng.randi_range(0, rooms.size()-1)].instance()
                    room.set_cell(cell)
                    merge_room(grid_pos, room)

                    var item_spawn_pos = room.get_item_spawn_pos()
                    if item_spawn_pos != null:
                        var global_pos = tile_to_global(grid_to_tile(grid_pos) + room_margin) + item_spawn_pos
                        items.push_back({"world_pos": global_pos})
                generate_hallways(grid_pos, cell)
            else:
                var room = EmptyRoom.instance()
                room.set_cell(cell)
                merge_room(grid_pos, room)

    $RoomTileMap.update_bitmask_region(Vector2.ZERO, grid_to_tile(grid.extents() + Vector2(1.0, 1.0)))
    $WallTileMap.update_bitmask_region(Vector2.ZERO, grid_to_tile(grid.extents() + Vector2(1.0, 1.0)))
    $GrassyTileMap.update_bitmask_region(Vector2.ZERO, grid_to_tile(grid.extents() + Vector2(1.0, 1.0)))

func merge_room(grid_pos, room):
    var tile_pos = grid_to_tile(grid_pos) + room_margin
    var room_tilemap = room.find_node("RoomTileMap")
    var wall_tilemap = room.find_node("WallTileMap")
    var grassy_tilemap = room.find_node("GrassyTileMap")

    for rx in range(room.ROOM_SIZE):
        for ry in range(room.ROOM_SIZE):
            var room_tile = room_tilemap.get_cell(rx, ry)
            var wall_tile = wall_tilemap.get_cell(rx, ry)
            var grassy_tile = grassy_tilemap.get_cell(rx, ry)

            if room_tile != -1:
                $RoomTileMap.set_cell(tile_pos.x+rx, tile_pos.y+ry, 0)

            if wall_tile != -1:
                $WallTileMap.set_cell(tile_pos.x+rx, tile_pos.y+ry, 0)

            if grassy_tile != -1:
                $GrassyTileMap.set_cell(tile_pos.x+rx, tile_pos.y+ry, 0)

func generate_hallways(grid_pos, cell):
    var tile_pos = grid_to_tile(grid_pos)
    var top = Rect2(tile_pos, Vector2(room_size.x+(room_margin.x*2), room_margin.y))

    var left = Rect2(tile_pos, Vector2(room_margin.x, room_size.y+(room_margin.y*2)))

    var bottom = Rect2(Vector2(tile_pos.x, tile_pos.y+room_size.y+room_margin.y), Vector2(room_size.x+(room_margin.x*2), room_margin.y))

    var right = Rect2(Vector2(tile_pos.x+room_margin.x+room_size.x, tile_pos.y), Vector2(room_margin.x, room_size.y+(room_margin.y*2)))

    var rects = [top, left, bottom, right]
    for r in rects:
        for x in range(r.position.x, r.end.x):
            for y in range(r.position.y, r.end.y):
                $WallTileMap.set_cell(x, y, 0)

    if cell["north"]:
        var x = tile_pos.x + ((room_margin.x + room_margin.x + room_size.x) / 2)
        for y in range(tile_pos.y, tile_pos.y + room_margin.y):
            $WallTileMap.set_cell(x, y, -1)
            $RoomTileMap.set_cell(x, y, 0)

    if cell["south"]:
        var x = tile_pos.x + ((room_margin.x + room_margin.x + room_size.x) / 2)
        for y in range(tile_pos.y + room_margin.y + room_size.y, tile_pos.y + (room_margin.y*2) + room_size.y):
            $WallTileMap.set_cell(x, y, -1)
            $RoomTileMap.set_cell(x, y, 0)

    if cell["east"]:
        var y = tile_pos.y + ((room_margin.y + room_margin.y + room_size.y) / 2)
        for x in range(tile_pos.x + room_margin.x + room_size.x, tile_pos.x + (room_margin.x*2) + room_size.x):
            $WallTileMap.set_cell(x, y, -1)
            $RoomTileMap.set_cell(x, y, 0)

    if cell["west"]:
        var y = tile_pos.y + ((room_margin.y + room_margin.y + room_size.y) / 2)
        for x in range(tile_pos.x, tile_pos.x + room_margin.x):
            $WallTileMap.set_cell(x, y, -1)
            $RoomTileMap.set_cell(x, y, 0)
