extends "res://Buildings/building.gd"

@export var ExtraStorage = 4

var upgraded_planet = false

func building_completed():
	super()
	
	if !upgraded_planet:
		upgraded_planet = true
		planet.MaxStorage += ExtraStorage
	
