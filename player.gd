extends RigidBody2D

@export var Speed = 400
@export var MaxTravelDist = 650

@export var MaxEnergy = 5
var currEnergy = 0

var currPlanet: Node2D = null
var target: Node2D = null
var velocity: Vector2 = Vector2()

var can_control = false

func _ready():
	get_parent().player_round_begin.connect(_on_player_start.bind())
	get_parent().enemy_round_begin.connect(_on_enemy_start.bind())

func _physics_process(delta):
	update_movement()
	position += velocity * Speed * delta
	
func _process(delta):
	update_ui()
	
func update_movement():
	if target == null:
		velocity = Vector2()
		return
		
	if (target.position - position).length() < 5:
		$AudioStreamPlayer2D.stop()
		currPlanet = target
		target = null
		currPlanet.dock_player(self)
		return
	
	if !$AudioStreamPlayer2D.playing:
		$AudioStreamPlayer2D.play()
	var dir = position.direction_to(target.position)
	$AnimationPlayer.set_dir(dir)
	velocity = dir 

func update_ui():
	Constants.Game.get_node('GameUI').set_inventory($MaterialBucket.stored_materials)
	Constants.Game.get_node('GameUI').set_energy(currEnergy, MaxEnergy)

func _on_player_start():
	can_control = true
	
	currEnergy = MaxEnergy

func _on_enemy_start():
	can_control = false


func _move_player(new_target, force=false):
	if !can_control and !force: return
	elif self.target or currPlanet == new_target: return
	elif currEnergy <= 0: return
	elif Constants.Game.get_node('GameUI').currBuilding: return
	
	var mod = calc_travel_mod(new_target)[0]
	if mod > currEnergy: return
	currEnergy -= mod
	
	if currPlanet:
		currPlanet.depart_player(self)
	
	self.target = new_target
	new_target.target_player()

func calc_travel_mod(planet):
	if currPlanet:
		var dist = int((planet.position - currPlanet.position).length())
		dist = dist / MaxTravelDist + 1
		
		var mod = dist + currPlanet.calc_travel_mod()
		if mod < 0: mod = 0
		if mod > currEnergy:
			return [mod, null]
		return [mod, currPlanet.calc_travel_mod()]
	return [1, 0]
