class_name GameGrid

enum Direction {
    NONE,
    NORTH,
    SOUTH,
    EAST,
    WEST,
}

export var grid_size = Vector2(1, 2)
export var item_probability = 1.0

var game_grid = []
var rng = RandomNumberGenerator.new()
var starting_cell = null

func _init():
    self.game_grid = _init_game_grid()
    self.starting_cell = self.game_grid[0][0]
    _make_map()
    self.starting_cell["room_type"] = "starting_room"

func at(x, y):
    return self.game_grid[y][x]

func atv(v):
    return self.game_grid[v.y][v.x]

func extents():
    return self.grid_size

func offsetv(cell, offset_vector):
    return offset(cell, offset_vector.x, offset_vector.y)

func offset(cell, x_off, y_off):
    var new_x = cell["x"] + x_off
    var new_y = cell["y"] + y_off
    if new_x < 0 || new_x >= grid_size.x || new_y < 0 || new_y >= grid_size.y:
        return null
    return self.game_grid[new_y][new_x]

func direction_to_vector(direction):
    match direction:
        Direction.NONE: 
            return Vector2.ZERO
        Direction.NORTH:
            return Vector2(0, -1)
        Direction.SOUTH:
            return Vector2(0, 1)
        Direction.EAST:
            return Vector2(1, 0)
        Direction.WEST:
            return Vector2(-1, 0)

func vector_to_direction(vector):
    match vector:
        Vector2(0, -1):
            return Direction.NORTH
        Vector2(0, 1):
            return Direction.SOUTH
        Vector2(1, 0):
            return Direction.EAST
        Vector2(-1, 0):
            return Direction.WEST
        Vector2(0, 0):
            return Direction.NONE

func dir_key(direction):
    match direction:
        Direction.NORTH:
            return "north"
        Direction.SOUTH:
            return "south"
        Direction.EAST:
            return "east"
        Direction.WEST:
            return "west"

func _init_game_grid():
    var grid = []
    for y in range(0, grid_size.y):
        var row = []
        for x in range(0, grid_size.x):
            row.push_back(_make_empty_cell(x, y))
        grid.push_back(row)
    return grid

func _dirs():
    return [Vector2(0, -1), Vector2(0, 1), Vector2(1, 0), Vector2(-1, 0)]

func _make_map():
    print("Starting map generation from ", starting_cell)
    var cell_queue = [starting_cell]
    var remaining_branches = 5

    while !cell_queue.empty():
        var cell = cell_queue.pop_front()
        cell["filled"] = true
        if rng.randf() <= item_probability:
            cell["has_item"] = true

        var candidates = []
        for dir in _dirs():
            var candidate = offsetv(cell, dir)
            if candidate != null && !candidate["filled"]:
                candidate["came_from"] = dir 
                candidates.push_back(candidate)

        if candidates.empty():
            print("candidates empty")
            if cell_queue.empty() && remaining_branches > 0:
                print("cell queue empty but trying to branch")
                # ran out of places to go, need to start another branch
                var branch_candidate = _find_branchable_cell()
                if branch_candidate == null:
                    print("didn't find a branch candidate")
                    # no more branches, call it quits
                    continue
                else:
                    print("found branch candidate: ", branch_candidate)
                    cell_queue.push_back(branch_candidate)
                    remaining_branches -= 1
                    continue
            else:
                print("probably done, cell_queue: ", cell_queue, " remaining_branches: ", remaining_branches)
                # either still have options, or we gave up on branching
                continue
        
        candidates.shuffle()
        var candidate = candidates.pop_front()
        cell_queue.push_back(candidate)
        cell[dir_key(vector_to_direction(candidate["came_from"]))] = true
        candidate[dir_key(vector_to_direction(candidate["came_from"]*-1))] = true

    print("done making the map")

func _find_branchable_cell():
    # only try x times then give up
    for _attempt in range(25):
        var x = rng.randi_range(0, grid_size.x-1)
        var y = rng.randi_range(0, grid_size.y-1)
        var cell = at(x, y)
        if !cell["filled"]:
            continue
        for offset in _dirs():
            var neighbor = offsetv(cell, offset)
            if neighbor != null && !neighbor["filled"]:
                return cell
    return null

func _make_empty_cell(x, y):
    return {"x": x, "y": y, "north": false, "south": false, "east": false, "west": false, "filled": false, "came_from": Vector2.ZERO, "has_item": false, "room_type": "random"}
