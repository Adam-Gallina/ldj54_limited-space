extends Node

signal status_changed

@export var BuildingName: String = 'None'
@export var StartAnimation: String = 'Constructing'
@export var BuiltAnimation: String = 'Factory'
@export var RequiredMaterial: Constants.MaterialType
@export var RequiredAmount: int
var recievedAmount = 0
@export var StorageMaterial = Constants.MaterialType.None
@export var MaxStorage = 0
var storedAmount = 0

@export var BuildAudio: AudioStream

var planet = null
@export var built = false

func _ready():
	$AnimatedSprite2D.play(BuiltAnimation)
	
func set_animation(speed, frame, progress):
	$AnimatedSprite2D.speed_scale = speed
	$AnimatedSprite2D.set_frame_and_progress(frame, progress)

func swap_animation(anim):
	var f = $AnimatedSprite2D.frame
	var p = $AnimatedSprite2D.frame_progress
	$AnimatedSprite2D.play(anim)
	$AnimatedSprite2D.set_frame_and_progress(f, p)

func set_planet(planet):
	self.planet = planet
	swap_animation(StartAnimation)
	planet.set_deposit_target(self)
	
	get_node('/root/Game').player_round_begin.connect(_on_player_start.bind())
	get_node('/root/Game').enemy_round_begin.connect(_on_enemy_start.bind())
	
	$AudioStreamPlayer2D.play()

func deposit_resource(amount):
	recievedAmount += amount
	
	if recievedAmount >= RequiredAmount:
		building_completed()
		return recievedAmount - RequiredAmount
	
	return 0

func can_store_resource(amount): return storedAmount + amount <= MaxStorage
func store_resource(amount):
	storedAmount += amount
	
	if storedAmount >= MaxStorage:
		var val = storedAmount - MaxStorage
		storedAmount = MaxStorage
		return val
		
	return 0

func building_completed():
	if planet.deposit_target == self:
		planet.set_deposit_target(null)
	
	if StorageMaterial != Constants.MaterialType.None:
		planet.set_storage_target(self)
	
	swap_animation(BuiltAnimation)
	
	if !built:
		_on_completed()
	built = true
	
func _on_completed():
	$AudioStreamPlayer2D.stream = BuildAudio
	$AudioStreamPlayer2D.play()


func _on_player_start():
	pass

func _on_enemy_start():
	pass
	
func get_status():
	if (built): return null
	
	return '%s Construction: %s/%s %s' % [BuildingName, recievedAmount, RequiredAmount, Constants.MaterialName(RequiredMaterial)]
