extends Node

signal player_round_begin
signal enemy_round_begin
signal player_win
signal player_lose
signal satellite_lose

@export var PlayerScene: PackedScene
@export var Satellite: NodePath

var player = null
var player_bucket =  null
var turn = 0
var player_turn = true

var alien_homeworlds = []
var completed = 0

func _ready():
	# Show loading screen
	
	player = PlayerScene.instantiate()
	add_child(player)
	player_bucket = $Player/MaterialBucket
	player.currPlanet = $Satellite
	await $MapSpawner.GenerateMap(self, $Satellite)
	get_tree().call_group('Planet', 'spawn')
	alien_homeworlds = $MapSpawner.alien_planets
	for i in alien_homeworlds:
		i.moves_completed.connect(_on_planet_turn_complete.bind())
	# Hide loading screen
	
	var lim = ($MapSpawner.OuterRadius + 1) * $MapSpawner.GridSize
	$Camera2D.limit_bottom = lim
	$Camera2D.limit_top = -lim
	$Camera2D.limit_left = -lim
	$Camera2D.limit_right = lim
	
	$GameUI.end_btn.pressed.connect(_on_end_player_round.bind())
	
	player_round_begin.emit()

func start_player_round():
	player_turn = true
	$GameUI.end_btn.disabled = false
	turn += 1
	
	player_round_begin.emit()

func _on_end_player_round():
	if player.currPlanet.docked_aliens.size() > 0:
		player_lose.emit()
	#elif $Satellite.docked_aliens.size() > 0:
	#	satellite_lose.emit()
	else:
		start_enemy_round()

func start_enemy_round():
	player_turn = false
	completed = 0
	$GameUI.end_btn.disabled = true
	$LabelTimer.start()
	
	enemy_round_begin.emit()
	
func _on_end_enemy_round():
	start_player_round()
	$EnemyTurnTimeout.stop()


func _on_planet_turn_complete(planet):
	completed += 1
	if completed == alien_homeworlds.size() and !player_turn:
		if !$LabelTimer.is_stopped():
			await $LabelTimer.timeout
		_on_end_enemy_round()

func _on_label_timer_timeout(): 
	$EnemyTurnTimeout.start()
func _on_enemy_turn_timeout_timeout():
	if !player_turn:
		_on_end_enemy_round()

