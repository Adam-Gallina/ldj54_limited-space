extends "res://Buildings/building.gd"

@export var ProducedMaterial = Constants.MaterialType.Electronic

func _on_completed():
	planet.ProductionType = ProducedMaterial
	super()

func _on_player_start():
	if built:
		planet.produce_resources()
	super()

func _on_enemy_start():
	super()
