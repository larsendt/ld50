extends Node2D

onready var Apple = preload("res://items/Apple.tscn")

export var INITIAL_COUNTDOWN_SECONDS = 10

onready var remaining_time_label = find_node("RemainingTimeLabel")
onready var start_time = OS.get_unix_time()
onready var end_time = start_time + INITIAL_COUNTDOWN_SECONDS

func _ready():
    find_node("TickTimer").connect("timeout", self, "_on_countdown_tick")
    _on_countdown_tick()

    for item_pos in $World.item_positions:
        var apple = Apple.instance()
        apple.position = item_pos
        $Items.add_child(apple)

    $Player.position = $World.starting_position()

func _process(delta):
    if Input.is_action_pressed("zoom"):
        $Camera2D.zoom = Vector2(4.0, 4.0)
    else:
        $Camera2D.zoom = Vector2(1.0, 1.0)


func _input(event):
    if event is InputEventMouseButton && event.is_pressed() && event.button_index == BUTTON_LEFT:
        var pos = get_viewport().canvas_transform.affine_inverse().xform(event.position)
        var debug_info = $World.debug_info_for_position(pos)
        find_node("GridDebugLabel").bbcode_text = debug_info

func do_end_game():
    pass
         
func _on_countdown_tick():
    var now = OS.get_unix_time()
    var total_remaining_sec = end_time - now

    if total_remaining_sec <= 0:
        remaining_time_label.bbcode_text = "[center][color=red]DOOM IS HERE[/color][/center]"
        do_end_game()
        return

    var remaining_min = int((total_remaining_sec) / 60)
    var remaining_sec = (total_remaining_sec) - (remaining_min * 60)

    var clock_color = "#00FF33"
    if total_remaining_sec <= (.2 * INITIAL_COUNTDOWN_SECONDS):
        clock_color = "red"
    elif total_remaining_sec <= (.5 * INITIAL_COUNTDOWN_SECONDS):
        clock_color = "yellow"
    remaining_time_label.bbcode_text = "[center]Doom comes in [color=%s]%02d:%02d[/color][/center]" % [clock_color, remaining_min, remaining_sec]
