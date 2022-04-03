extends Node2D

export var INITIAL_COUNTDOWN_SECONDS = 30

onready var Apple = preload("res://items/Apple.tscn")
onready var remaining_time_label = find_node("RemainingTimeLabel")
onready var start_time = OS.get_unix_time()
onready var end_time = start_time + INITIAL_COUNTDOWN_SECONDS

enum CountdownState {
    NOT_STARTED
    BEGUN,
    HALF,
    DIRE,
}
var current_countdown_state = CountdownState.NOT_STARTED

func _ready():
    find_node("TickTimer").connect("timeout", self, "_on_countdown_tick")
    $Ambience.connect("shake_screen", self, "_on_shake_screen")
    find_node("VictoryPortal").connect("victory_portal_entered", self, "do_win")
    _on_countdown_tick()
    $Player.position = $World.starting_position()
    for item in $World.get_items():
        spawn_item(item)

func _process(delta):
    if Input.is_action_just_pressed("ui_page_up"):
        #$Camera2D.zoom *= 2.0
        pass
    elif Input.is_action_just_pressed("ui_page_down"):
        #$Camera2D.zoom /= 2.0
        pass


func _input(event):
    if event is InputEventMouseButton && event.is_pressed() && event.button_index == BUTTON_LEFT:
        var pos = get_viewport().canvas_transform.affine_inverse().xform(event.position)
        var debug_info = $World.debug_info_for_position(pos)
        find_node("GridDebugLabel").bbcode_text = debug_info

func spawn_item(item):
    var world_pos = item["world_pos"]
    var apple = Apple.instance()
    apple.position = world_pos + $World.position
    $Items.add_child(apple)
    apple.connect("item_acquired", self, "_on_item_acquired")

func _on_item_acquired(seconds_added):
    $DingDelay.start()
    yield($DingDelay, "timeout")
    print("Item acquired, gaining time: ", seconds_added)
    $ItemDingPlayer.play()
    end_time += seconds_added
    _on_countdown_tick()

func do_game_over():
    print("END GAME")
    $Ambience.set_ambience(["eerie_thunder", "lots_of_thunder", "earthquake"])
    $TickTimer.stop()
    $EvilLaughPlayer.play()
    $Player.dead = true
    var end_label = find_node("EndLabel")
    end_label.bbcode_text = "[color=red][center]DOOOOOOM[/center][/color]"
    find_node("EndContainer").visible = true

func do_win():
    print("WIN GAME")
    $Ambience.set_ambience(["wind"])
    $TickTimer.stop()
    $Player.dead = true
    var end_label = find_node("EndLabel")
    end_label.bbcode_text = "[color=#00FF33][center]DOOM DEFERRED[/center][/color]"
    find_node("EndContainer").visible = true
    remaining_time_label.bbcode_text = "[center][color=green]NICE JOB[/color][/center]"
         
func _on_countdown_tick():
    var now = OS.get_unix_time()
    var total_remaining_sec = end_time - now

    if total_remaining_sec <= 0:
        remaining_time_label.bbcode_text = "[center][color=red]DOOM IS HERE[/color][/center]"
        do_game_over()
        return

    var remaining_min = int((total_remaining_sec) / 60)
    var remaining_sec = (total_remaining_sec) - (remaining_min * 60)

    var clock_color = "#00FF33"
    if total_remaining_sec <= (.2 * INITIAL_COUNTDOWN_SECONDS):
        clock_color = "red"
        if current_countdown_state != CountdownState.DIRE:
            $GongPlayer.play()
            current_countdown_state = CountdownState.DIRE
            $Ambience.set_ambience(["eerie_thunder", "earthquake", "near_thunder"])
    elif total_remaining_sec <= (.5 * INITIAL_COUNTDOWN_SECONDS):
        clock_color = "yellow"
        if current_countdown_state != CountdownState.HALF:
            $GongPlayer.play()
            current_countdown_state = CountdownState.HALF
            $Ambience.play("eerie_thunder")
            $Ambience.set_ambience(["eerie_thunder", "near_thunder"])
    else:
        clock_color = "#00FF33"
        if current_countdown_state != CountdownState.BEGUN:
            $GongPlayer.play()
            current_countdown_state = CountdownState.BEGUN
            $Ambience.set_ambience(["wind", "near_thunder"])
    remaining_time_label.bbcode_text = "[center]Doom comes in [color=%s]%02d:%02d[/color][/center]" % [clock_color, remaining_min, remaining_sec]
