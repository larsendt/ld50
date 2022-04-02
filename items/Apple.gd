extends Area2D

export var SECONDS_ADDED = 30
signal item_acquired(seconds_added)

func _ready():
    self.connect("area_entered", self, "acquire_item")

func acquire_item():
    emit_signal("item_acquired", SECONDS_ADDED)