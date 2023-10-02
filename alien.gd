extends RigidBody2D

signal destroyed
signal completed_move

@export var Speed = 500
@export var MoveCooldown = 1
var turnsUntilMove = 0
@export var MaxTargetOffset = 50

@export var MinMoveDelay = .5
@export var MaxMoveDelay = 1


var homeworld = null
var next_target = null
var target = null
var target_pos = Vector2()
var velocity = Vector2()
var traveled_planets = []
var available_planets = []
var valid_planets = []
var curr_planet = null

func _ready():
	get_node('/root/Game').player_round_begin.connect(_on_player_start.bind())
	get_node('/root/Game').enemy_round_begin.connect(_on_enemy_start.bind())
	
	turnsUntilMove = MoveCooldown

func set_homeworld(planet):
	homeworld = planet
	position = homeworld.position
	traveled_planets = []
	curr_planet = homeworld

func _physics_process(delta):
	update_movement()
	
	position += velocity * Speed * delta

func update_movement():
	if target == null:
		velocity = Vector2()
		return
		
	if (target_pos - position).length() < 5:
		curr_planet = target
		target.dock_alien(self)
		target = null
		completed_move.emit(self)
		$AudioStreamPlayer2D.stop()
		return
	
	if !$AudioStreamPlayer2D.playing:
		$AudioStreamPlayer2D.play()
	var dir = position.direction_to(target_pos)
	$AnimationPlayer.set_dir(dir)
	velocity = dir 

func _on_player_start():
	pass
	
func _on_enemy_start():
	if turnsUntilMove == 0:
		$MoveDelayTimer.wait_time = randf_range(MinMoveDelay, MaxMoveDelay)
		$MoveDelayTimer.start()
		turnsUntilMove = MoveCooldown
		return
	
	turnsUntilMove -= 1
		
	if turnsUntilMove == 0:
		next_target = get_move_target()
		if next_target:
			next_target.target_alien(self)
			var dir = position.direction_to(next_target.position)
			$AnimationPlayer.set_dir(dir)
			target_pos = Vector2(randi_range(-MaxTargetOffset, MaxTargetOffset),
									randi_range(-MaxTargetOffset, MaxTargetOffset)) + next_target.position
			
	completed_move.emit(self)
		

func _on_timer_timeout():	
	# Find nearest planet, travel to it
	if next_target == null:
		completed_move.emit(self)
		return
		
	target = next_target
		
	curr_planet.depart_alien(self)
	valid_planets.erase(target)
	traveled_planets.append(target)
	

func get_move_target():
	if valid_planets.size() > 0:
		return valid_planets[randi() % valid_planets.size()]
	elif available_planets.size() > 0:
		return valid_planets[randi() % valid_planets.size()]
	else:
		push_error('[alien._on_enemy_start] No valid planet to travel to')
		return null


func destroy():
	if curr_planet:
		curr_planet.depart_alien(self)
	destroyed.emit(self)
	queue_free()


func _on_area_2d_area_entered(area):
	if area.is_in_group('Planet'):
		if area == homeworld:
			return
		elif area in traveled_planets:
			available_planets.append(area)
		else:
			valid_planets.append(area)

func _on_area_2d_area_exited(area):
	if area.is_in_group('Planet'):
		valid_planets.erase(area)
		available_planets.erase(area)


