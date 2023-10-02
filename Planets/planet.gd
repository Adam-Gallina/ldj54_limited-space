extends Node

signal selected
signal hovered
signal unhovered
signal player_docked
signal player_depart


@export_category('Random Planets')
@export var MaxSize = 1.25
@export var MinSize = 1.
@export var SizeStep = 0.05
@export var MaxAnimSpeed = 1.25
@export var MinAnimSpeed = 0.5
@export var AnimStep = 0.1
@export_category("")

@export_category('Production')
@export var ProductionType: Constants.MaterialType = Constants.MaterialType.None
@export var ProductionAmount = 1
var curr_storage = 0
@export var MaxStorage = 3
@export_category('')

@export_category('Building')
@export var ValidBuildings: Array[String]
@export var ValidSingleBuilding: Array[String]
var builtSingleBuilding = false
@export var MaxBuildings = 4
@export_category('')

@export var ProtectAliens = false
@export var TravelMod = 0

var mouse_over = false
var deposit_target = null
var storage_target = null
var buildings = []
var docked_aliens = []
var targeted_aliens = []

func _ready():
	get_parent().player_round_begin.connect(_on_player_start.bind())
	get_parent().enemy_round_begin.connect(_on_enemy_start.bind())
	
	var s = snapped(randf_range(MinSize, MaxSize), SizeStep)
	$Image.scale = Vector2(s, s)
	
	var anims = $Image/AnimatedSprite2D.sprite_frames.get_animation_names()
	$Image/AnimatedSprite2D.play(anims[randi() % anims.size()])
	
	var speed = snapped(randf_range(MinAnimSpeed, MaxAnimSpeed), AnimStep) * (-1 if randi() % 2 == 0 else 1)
	$Image/AnimatedSprite2D.speed_scale = speed if (speed != 0) else speed - AnimStep
	$Image/AnimatedSprite2D.frame = randi() % 8
	if $Image/ResourceAnim.visible:
		$Image/ResourceAnim.play()
		$Image/ResourceAnim.speed_scale = speed if (speed != 0) else speed - AnimStep
		$Image/ResourceAnim.frame = randi() % 8
		
	$Image/SelectorAnim.hide()
	$Image/SelectorAnim.play()
	
	if ProductionType == Constants.MaterialType.None: $UI/planet_ui_button_withdraw.hide()
	set_deposit_target(null)
	set_storage_target(null)
	$StatusBox.hide()

func spawn():
	selected.connect(Constants.Game.player._move_player.bind())
	selected.connect(get_node('/root/Game/GameUI')._on_planet_selected.bind())
	hovered.connect(get_node('/root/Game/GameUI')._on_planet_hovered.bind())
	unhovered.connect(get_node('/root/Game/GameUI')._on_planet_unhovered.bind())

func _unhandled_input(event):
	if Input.is_action_just_pressed("mouse_select") and mouse_over:
		selected.emit(self)
	
	if Input.is_action_just_released("cam_zoom_in") or Input.is_action_just_pressed("cam_zoom_out"):
		var s = 1 / Constants.Game.get_node('Camera2D').zoom.x
		$StatusBox.scale = Vector2(s,s)
		$StatusBox.position.x = -($StatusBox.size.x / 2) * s

func _on_player_start():
	produce_resources()

func _on_enemy_start():
	pass

func produce_resources():
	if ProductionAmount <= 0 or ProductionType == Constants.MaterialType.None:
		$UI/planet_ui_button_withdraw.hide()
		return
	$UI/planet_ui_button_withdraw.show()
	
	if curr_storage < MaxStorage:
		curr_storage += ProductionAmount
	if curr_storage > MaxStorage:
		curr_storage = MaxStorage
	
	update_ui()

func target_player():
	$Image/SelectorAnim.player_docked = true
	$Image/SelectorAnim.update_color()

func dock_player(player):
	player_docked.emit()
	update_ui()

func depart_player(player):
	player_depart.emit()
	
func dock_alien(alien):
	docked_aliens.append(alien)
	targeted_aliens.erase(alien)
	$Image/SelectorAnim.aliens_docked = docked_aliens.size() > 0
	$Image/SelectorAnim.aliens_targeting = targeted_aliens.size() > 0
	$Image/SelectorAnim.update_color()
	
func depart_alien(alien):
	targeted_aliens.erase(alien)
	docked_aliens.erase(alien)
	$Image/SelectorAnim.aliens_docked = docked_aliens.size() > 0
	$Image/SelectorAnim.aliens_targeting = targeted_aliens.size() > 0
	$Image/SelectorAnim.update_color()
	
func target_alien(alien):
	alien.destroyed.connect(depart_alien.bind())
	targeted_aliens.append(alien)
	$Image/SelectorAnim.aliens_targeting = targeted_aliens.size() > 0
	$Image/SelectorAnim.update_color()


func set_deposit_target(target):
	deposit_target = target
	update_ui()
		
func set_storage_target(target):
	storage_target = target
	update_ui()

func display_building(building):
	if building.get_parent():
		building.get_parent().remove_child(building)
	$Image.add_child(building)
	building.position = Vector2()
	var anim = $Image/AnimatedSprite2D
	building.set_animation(anim.speed_scale, 
						   (anim.frame + buildings.size() * 2) % anim.sprite_frames.get_frame_count(anim.animation),
						   anim.frame_progress)

func add_building(building):
	if building.BuildingName in ValidSingleBuilding:
		builtSingleBuilding = true
	buildings.append(building)
	building.set_planet(self)
	building.status_changed.connect(update_ui.bind())
	
func can_add_building(building:String):
	if deposit_target: return false
	elif buildings.size() >= MaxBuildings: return false
	elif building in ValidSingleBuilding:
		if builtSingleBuilding: return false
	elif !(building in ValidBuildings): return false
	return true
	
func update_ui():
	$UI/planet_ui_button_withdraw.disabled = curr_storage <= 0
	$UI/planet_ui_button_withdraw.tooltip_text = 'Take 1 %s' % Constants.MaterialName(ProductionType)
	
	$UI/planet_ui_button_deposit.visible = deposit_target != null
	if deposit_target and Constants.Game.player_bucket:
		$UI/planet_ui_button_deposit.disabled = !Constants.Game.player_bucket.can_withdraw(deposit_target.RequiredMaterial, 1)
		var text = 'Build %s with 1 %s' % [deposit_target.BuildingName, Constants.MaterialName(deposit_target.RequiredMaterial)]
		$UI/planet_ui_button_deposit.tooltip_text = text
		
	$UI/planet_ui_button_store.visible = storage_target != null
	if storage_target and Constants.Game.player_bucket:
		$UI/planet_ui_button_store.disabled = !(storage_target.can_store_resource(1)
			and Constants.Game.player_bucket.can_withdraw(storage_target.StorageMaterial, 1))
		var text = 'Store 1 %s in %s' % [Constants.MaterialName(storage_target.StorageMaterial), storage_target.BuildingName]
		$UI/planet_ui_button_store.tooltip_text = text
		
	$StatusBox/HBoxContainer/StatusLabel.text = get_tooltip_text()

func get_tooltip_text():
	var text = ''
	if ProductionType != Constants.MaterialType.None:
		text += 'Produces %s' % Constants.MaterialName(ProductionType)
		text += '\nStorage: %s/%s %s' % [curr_storage, MaxStorage, Constants.MaterialName(ProductionType)]
	for i in buildings:
		var s = i.get_status()
		if s != null: text += ('\n' if s.length() > 0 else '') + s
	
	return text if text != '' else 'Basic Planet'

func calc_travel_mod():
	var mod = TravelMod
	if docked_aliens.size() > 0: mod += 1
	return mod


func _on_mouse_entered():
	mouse_over = true
	hovered.emit(self)
	$StatusBox.show()

func _on_mouse_exited():
	mouse_over = false
	unhovered.emit(self)
	$StatusBox.hide()

func _on_planet_ui_button_withdraw_pressed():
	if curr_storage > 0:
		get_node('..').player_bucket.deposit_material(ProductionType, 1)
		curr_storage -= 1
	update_ui()

func _on_planet_ui_button_deposit_pressed():
	if deposit_target:
		var mat = deposit_target.RequiredMaterial
		if get_node('/root/Game').player_bucket.can_withdraw(mat, 1):
			if deposit_target.deposit_resource(1) == 0:
				get_node('/root/Game').player_bucket.withdraw_material(mat, 1)
	update_ui()
				
func _on_planet_ui_button_store_pressed():
	if storage_target and storage_target.can_store_resource(1):
		var mat = storage_target.StorageMaterial
		if get_node('/root/Game').player_bucket.can_withdraw(mat, 1):
			if storage_target.store_resource(1) == 0:
				get_node('/root/Game').player_bucket.withdraw_material(mat, 1)
	update_ui()
