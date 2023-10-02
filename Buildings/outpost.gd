extends "res://Buildings/building.gd"

func _ready():
	super()
	$Area2D/Warning.hide()

func set_planet(planet):
	super(planet)
	
	var s = 1 / get_parent().scale.x
	$Area2D.scale = Vector2(s, s)
	
func _on_completed():
	super()
	$Area2D/Warning.visible = storedAmount <= 0

func _on_player_start():
	if storedAmount > 0:
		storedAmount -= 1
		if storedAmount <= 0:
			$Area2D/Warning.show()
		status_changed.emit()
		
		for p in $Area2D.get_overlapping_areas():
			if p == planet and p.docked_aliens.size() > 0:
				p.docked_aliens[0].destroy()
			elif !p.ProtectAliens and p.docked_aliens.size() > 0:
				p.docked_aliens[0].destroy()

func _on_enemy_start():
	pass

func get_status():
	if !built: return super()
	
	return 'Outpost: %s/%s %s' % [storedAmount, MaxStorage + planet.MaxStorage, Constants.MaterialName(StorageMaterial)]

func can_store_resource(amount): return storedAmount + amount <= MaxStorage + planet.MaxStorage
func store_resource(amount):
	storedAmount += amount
	$Area2D/Warning.hide()
	
	if storedAmount >= MaxStorage + planet.MaxStorage:
		var val = storedAmount - (MaxStorage + planet.MaxStorage)
		storedAmount = MaxStorage + planet.MaxStorage
		return val
		
	return 0
