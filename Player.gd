extends Area2D

export var MOVE_SPEED = 300

func _process(delta):
    var movement = Vector2.ZERO
    if Input.is_action_pressed("move_right"):
        movement.x = 1.0
    elif Input.is_action_pressed("move_left"):
        movement.x = -1.0

    if Input.is_action_pressed("move_up"):
        movement.y = -1.0
    elif Input.is_action_pressed("move_down"):
        movement.y = 1.0

    self.position += movement.normalized() * MOVE_SPEED * delta