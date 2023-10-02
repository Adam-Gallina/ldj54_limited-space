extends "res://Buildings/building.gd"

func _on_completed():
	super()
	planet.TravelMod-=1
