extends KinematicBody2D 

export var MOVE_SPEED = 300
onready var sprite = $AnimatedSprite
var dead = false

func _physics_process(delta):
    if dead:
        sprite.play("idle")
        sprite.speed_scale = 1.0
        return

    var movement = Vector2.ZERO
    var current_anim = "idle"
    sprite.speed_scale = 1.0
    if Input.is_action_pressed("ui_right"):
        movement.x = 1.0
        current_anim = "walk_right"
        sprite.speed_scale = 2.0
    elif Input.is_action_pressed("ui_left"):
        current_anim = "walk_left"
        sprite.speed_scale = 2.0
        movement.x = -1.0

    if Input.is_action_pressed("ui_up"):
        current_anim = "walk_up"
        sprite.speed_scale = 2.0
        movement.y = -1.0
    elif Input.is_action_pressed("ui_down"):
        current_anim = "walk_down"
        sprite.speed_scale = 2.0
        movement.y = 1.0

    move_and_slide(movement.normalized() * MOVE_SPEED)
    sprite.play(current_anim)