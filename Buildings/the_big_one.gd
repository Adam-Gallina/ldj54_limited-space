extends "res://Buildings/building.gd"

func store_resource(amount):
	var val = super(amount)
	
	if storedAmount == MaxStorage:
		Constants.Game.player_win.emit()
		
	return val

func get_status():
	return '%s: %s/%s %s' % [BuildingName, storedAmount, MaxStorage, Constants.MaterialName(StorageMaterial)]
