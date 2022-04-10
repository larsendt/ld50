extends Node2D

var game_grid
var cells
var player_cell = Vector2.ZERO

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

var ITEM_TILE = Vector2(0, 2)
var END_TILE = Vector2(1, 2)
var START_TILE = Vector2(2, 2)

func _ready():
    self.game_grid = GameGrid.new()
    self.cells = game_grid.cells_in_grid_order()
    display()

func display():
    for cell in self.cells:
        if cell.filled:
            $BaseMap.set_cell(cell.x, cell.y, 0, false, false, false, tile_coords[cell.connections])
            if cell.room_type == "starting_room":
                $SpecialRoomMap.set_cell(cell.x, cell.y, 0, false, false, false, START_TILE)
            elif cell.room_type == "last_room":
                $SpecialRoomMap.set_cell(cell.x, cell.y, 0, false, false, false, END_TILE)
            elif cell.has_item:
                $SpecialRoomMap.set_cell(cell.x, cell.y, 0, false, false, false, ITEM_TILE)
        else:
            $BaseMap.set_cell(cell.x, cell.y, -1)
            $SpecialRoomMap.set_cell(cell.x, cell.y, -1)
