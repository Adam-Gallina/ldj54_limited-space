extends "res://Planets/planet.gd"

func _ready():
	super()
	
	$TheBigOne.set_planet(self)
	set_deposit_target(null)
	set_storage_target($TheBigOne)
	buildings.append($TheBigOne) 
	update_ui()

func get_tooltip_text():
	var text = ''
	for i in buildings:
		var s = i.get_status()
		if s != null: text += s
	
	return text if text != '' else 'Basic Planet'
