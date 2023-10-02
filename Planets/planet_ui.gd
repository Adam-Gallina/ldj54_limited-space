extends Control

@export var ButtonScene: PackedScene


func _ready():
	hide()

func _on_planet_player_depart():
	hide()

func _on_planet_player_docked():
	show()
