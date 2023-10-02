extends "res://Planets/planet.gd"

signal moves_completed

@export_category('Spawning')
@export var AlienSpawnSpeed = .4
@export var StartSpawnAmount = .4
@export var AlienScene: PackedScene
@export_category('')

var spawned_aliens = []
var new_aliens = []
var completed = 0

func _ready():
	super()
	$Image/AnimatedSprite2D.play('Red')

func _on_enemy_start():
	new_aliens = []
	completed = 0
	StartSpawnAmount += CalcSpawnAmount()
	while StartSpawnAmount > 1:
		StartSpawnAmount -= 1
		var a = AlienScene.instantiate()
		get_parent().add_child(a)
		a.set_homeworld(self)
		new_aliens.append(a)
		a.destroyed.connect(_on_alien_destroyed.bind())
		a.completed_move.connect(_on_alien_completed_move.bind())
	
	if spawned_aliens.size() == 0:
		moves_completed.emit(self)
		spawned_aliens += new_aliens

func CalcSpawnAmount(): return AlienSpawnSpeed


func _on_alien_destroyed(alien):
	spawned_aliens.erase(alien)
	new_aliens.erase(alien)

func _on_alien_completed_move(alien):
	completed += 1
	if completed == spawned_aliens.size():
		spawned_aliens += new_aliens
		moves_completed.emit(self)
		
func get_tooltip_text():
	return '''Alien Homeworld
	Current charge: %s%%
	Will charge %s%% next turn''' % [roundi(StartSpawnAmount * 100), roundi(CalcSpawnAmount() * 100)]
