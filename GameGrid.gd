class_name GameGrid

enum Direction {
    NONE = 0x0,
    NORTH = 0x1,
    SOUTH = 0x2,
    EAST = 0x4,
    WEST = 0x8,
}

class Cell:
    var x: int
    var y: int
    var connections: int
    var filled: bool
    var has_item: bool
    var room_type: String
    var distance_from_start: int
    var parent: Cell
    var placement_index: int

    func _init(_x: int, _y: int):
        self.x = _x
        self.y = _y
        self.connections = Direction.NONE
        self.filled = false
        self.has_item = false
        self.room_type = "random"
        self.distance_from_start = -1
        self.parent = null
        self.placement_index = -1

    func north():
        return self.connections & Direction.NORTH

    func south():
        return self.connections & Direction.SOUTH

    func east():
        return self.connections & Direction.EAST

    func west():
        return self.connections & Direction.WEST

    func is_branch():
        var conn_count = 0
        for dir in [Direction.NORTH, Direction.SOUTH, Direction.EAST, Direction.WEST]:
            if self.connections & dir:
                conn_count += 1
        return conn_count >= 3

export var item_probability = 0.15

var grid_size
var game_grid = []
var rng = RandomNumberGenerator.new()
var starting_cell = null

func _init(_grid_size = Vector2(8, 8)):
    grid_size = _grid_size
    randomize()
    self.game_grid = _init_game_grid()
    _make_map()

func cells_in_grid_order() -> Array:
    var cells = []
    for x in range(0, grid_size.x):
        for y in range(0, grid_size.y):
            cells.push_back(at(x, y))
    return cells

func cells_in_distance_order() -> Array:
    var cells = cells_in_grid_order()
    cells.sort_custom(self, "_sort_distance")
    return cells

func cells_in_placement() -> Array:
    var cells = cells_in_grid_order()
    cells.sort_custom(self, "_sort_placement")
    return cells

func _sort_distance(a: Cell, b: Cell) -> bool:
    return a.distance_from_start < b.distance_from_start

func _sort_placement(a: Cell, b: Cell) -> bool:
    return a.placement_index < b.placement_index

func at(x, y) -> Dictionary:
    return self.game_grid[y][x]

func atv(v) -> Dictionary:
    return self.game_grid[v.y][v.x]

func extents() -> Vector2:
    return self.grid_size

func offsetv(cell: Cell, offset_vector: Vector2) -> Dictionary:
    return offset(cell, int(offset_vector.x), int(offset_vector.y))

func offset(cell: Cell, x_off: int, y_off: int):
    var new_x = cell.x + x_off
    var new_y = cell.y + y_off
    if new_x < 0 || new_x >= grid_size.x || new_y < 0 || new_y >= grid_size.y:
        return null
    return at(new_x, new_y)

func _init_game_grid():
    var grid = []
    for y in range(0, grid_size.y):
        var row = []
        for x in range(0, grid_size.x):
            row.push_back(Cell.new(x, y))
        grid.push_back(row)
    return grid

func all_directions() -> Array:
    return [Direction.NORTH, Direction.SOUTH, Direction.EAST, Direction.WEST]

func fmt_connections(connection_bitfield: int) -> String:
    var s = ""
    if connection_bitfield & Direction.NORTH:
        s += "n"

    if connection_bitfield & Direction.SOUTH:
        s += "s"

    if connection_bitfield & Direction.EAST:
        s += "e"

    if connection_bitfield & Direction.WEST:
        s += "w"
    
    return s

func invert_connection(connection_bitfield: int) -> int:
    var newdir = Direction.NONE
    if connection_bitfield & Direction.NORTH:
        newdir |= Direction.SOUTH

    if connection_bitfield & Direction.SOUTH:
        newdir |= Direction.NORTH

    if connection_bitfield & Direction.EAST:
        newdir |= Direction.WEST

    if connection_bitfield & Direction.WEST:
        newdir |= Direction.EAST

    return newdir

func direction_to_vector(direction: int) -> Vector2:
    match (direction):
        Direction.NORTH:
            return Vector2(0, -1)
        Direction.SOUTH:
            return Vector2(0, 1)
        Direction.EAST:
            return Vector2(1, 0)
        Direction.WEST:
            return Vector2(-1, 0)
    return Vector2(0, 0)

func _make_map():
    self.starting_cell = self.game_grid[grid_size.x / 2][grid_size.y / 2]
    self.starting_cell.room_type = "starting_room"
    self.starting_cell.has_item = true
    self.starting_cell.distance_from_start = 0

    print("Starting map generation from ", self.starting_cell)
    var cell_stack = [self.starting_cell]
    var last_cell = null
    var placement_index = 0

    while !cell_stack.empty():
        var cell = cell_stack.pop_back()
        last_cell = cell
        cell.filled = true
        cell.placement_index = placement_index
        placement_index += 1
        if rng.randf() <= item_probability:
            cell.has_item = true

        var candidates = get_available_neighbors(cell)

        if candidates.size() == 0:
            print("no candidates, finding a branch")
            var branch_candidate = backtrack(cell)
            if branch_candidate != null:
                cell_stack.push_back(branch_candidate)
            else:
                print("No branchable cell found, giving up")
        else:
            var cdir = candidates[rng.randi_range(0, candidates.size()-1)]
            var candidate = cdir[0]
            var dir = cdir[1]
            cell_stack.push_back(candidate)
            cell.connections |= dir
            candidate.connections |= invert_connection(dir)
            candidate.distance_from_start = cell.distance_from_start + 1
            candidate.parent = cell

    last_cell.room_type = "last_room"
    print("done making the map")

func backtrack(cell: Cell) -> Cell:
    var parent = cell.parent
    while parent != null:
        var neighbors = get_available_neighbors(parent)
        if neighbors.size() > 0:
            print("Found a branch: %d,%d" % [parent.x, parent.y])
            return parent
        else:
            parent = parent.parent
    print("Failed to find a branch")
    return null

func get_available_neighbors(cell) -> Array:
    var neighbors = []
    for dir in all_directions():
        var dir_v = direction_to_vector(dir)
        var candidate = offsetv(cell, dir_v)
        if candidate != null && !candidate.filled:
            neighbors.push_back([candidate, dir])
    return neighbors
