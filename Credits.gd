extends Node2D

func _ready():
    find_node("BackButton").connect("pressed", self, "back_to_menu")

func back_to_menu():
    get_tree().change_scene("res://MainMenu.tscn")
