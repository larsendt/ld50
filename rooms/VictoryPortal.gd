extends Area2D

signal victory_portal_entered

func _ready():
    connect("body_entered", self, "do_win")

func do_win(body):
    emit_signal("victory_portal_entered")