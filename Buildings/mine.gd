extends "res://Buildings/building.gd"

func _on_player_start():
	if built:
		planet.produce_resources()
	super()

func _on_enemy_start():
	super()
