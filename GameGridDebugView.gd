extends Node2D

var game_grid
var cells

var display_bar = 0
var elapsed_time = 0
var seconds_per_increment = 0.1

var NONE = GameGrid.Direction.NONE
var NORTH = GameGrid.Direction.NORTH
var SOUTH = GameGrid.Direction.SOUTH
var EAST = GameGrid.Direction.EAST
var WEST = GameGrid.Direction.WEST

var tile_coords = {
    # tilemap coord: [north, south, east, west]
    NONE: Vector2(0, 0),
    EAST: Vector2(1, 0),
    EAST | WEST: Vector2(2, 0),
    WEST: Vector2(3, 0),
    SOUTH: Vector2(4, 0),
    NORTH | SOUTH: Vector2(5, 0),
    NORTH: Vector2(6, 0),
    NORTH | SOUTH | EAST | WEST: Vector2(7, 0),

    NORTH | EAST: Vector2(0, 1),
    SOUTH | EAST: Vector2(1, 1),
    SOUTH | WEST: Vector2(2, 1),
    NORTH | WEST: Vector2(3, 1),
    NORTH | SOUTH | EAST: Vector2(4, 1),
    NORTH | SOUTH | WEST: Vector2(5, 1),
    SOUTH | EAST | WEST: Vector2(6, 1),
    NORTH | EAST | WEST: Vector2(7, 1),
}

func _ready():
    self.game_grid = GameGrid.new()
    self.cells = game_grid.cells_in_distance_order()

func _process(delta):
    elapsed_time += delta
    if elapsed_time >= seconds_per_increment:
        display_bar += 1
        elapsed_time = 0
        display("distance_from_start", display_bar)

func display(cell_metric, metric_bar):
    for cell in self.cells:
        if cell.filled && cell[cell_metric] < metric_bar:
            $TileMap.set_cell(cell.x, cell.y, 0, false, false, false, tile_coords[cell.connections])
        else:
            $TileMap.set_cell(cell.x, cell.y, -1)
