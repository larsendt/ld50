extends Node2D

func _ready():
    if OS.has_feature("HTML5"):
        find_node("ExitButton").visible = false
    else:
        find_node("ExitButton").connect("pressed", self, "exit")

    find_node("PlayButton").connect("pressed", self, "play")
    find_node("CreditsButton").connect("pressed", self, "credits")



func exit():
    get_tree().quit()

func play():
    get_tree().change_scene("res://Game.tscn")

func credits():
    get_tree().change_scene("res://Credits.tscn")