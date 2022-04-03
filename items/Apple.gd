extends Area2D

export var SECONDS_ADDED = 30
signal item_acquired(seconds_added)
var eaten = false

func _ready():
    self.connect("body_entered", self, "acquire_item")

func acquire_item(body):
    if eaten:
        return

    emit_signal("item_acquired", SECONDS_ADDED)
    $EatEffect.play()
    $EatEffect.connect("finished", self, "_on_done_eating")
    self.visible = false
    self.eaten = true

func _on_done_eating():
    queue_free()