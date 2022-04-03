extends Node2D

const ROOM_SIZE = 15

var Apple = preload("res://items/Apple.tscn")

func get_player_spawn_pos():
    return find_node("PlayerSpawn").position

func set_cell(cell):
    var rng = RandomNumberGenerator.new()
    var room_tile_map = find_node("RoomTileMap")
    var wall_tile_map = find_node("WallTileMap")
    var item_spawns = find_node("ItemSpawns")

    var n = Vector2(ROOM_SIZE/2.0, 0).floor()
    if cell["north"]:
        room_tile_map.set_cellv(n, 0)
        wall_tile_map.set_cellv(n, -1)
    else:
        room_tile_map.set_cellv(n, -1)
        wall_tile_map.set_cellv(n, 0)

    var s = Vector2(ROOM_SIZE/2.0, ROOM_SIZE-1).floor()
    if cell["south"]:
        room_tile_map.set_cellv(s, 0)
        wall_tile_map.set_cellv(s, -1)
    else:
        room_tile_map.set_cellv(s, -1)
        wall_tile_map.set_cellv(s, 0)

    var e = Vector2(ROOM_SIZE-1, ROOM_SIZE/2.0).floor()
    if cell["east"]:
        room_tile_map.set_cellv(e, 0)
        wall_tile_map.set_cellv(e, -1)
    else:
        room_tile_map.set_cellv(e, -1)
        wall_tile_map.set_cellv(e, 0)

    var w = Vector2(0, ROOM_SIZE/2.0).floor()
    if cell["west"]:
        room_tile_map.set_cellv(w, 0)
        wall_tile_map.set_cellv(w, -1)
    else:
        room_tile_map.set_cellv(w, -1)
        wall_tile_map.set_cellv(w, 0)

    var spawns = item_spawns.get_children()
    if cell["has_item"] && spawns.size() > 0:
        var spawn = spawns[rng.randi_range(0, spawns.size()-1)]
        var apple = Apple.instance()
        apple.position = spawn.position
        $Items.add_child(apple)
        
    room_tile_map.update_bitmask_region(Vector2.ZERO, Vector2(ROOM_SIZE, ROOM_SIZE))
    wall_tile_map.update_bitmask_region(Vector2.ZERO, Vector2(ROOM_SIZE, ROOM_SIZE))
