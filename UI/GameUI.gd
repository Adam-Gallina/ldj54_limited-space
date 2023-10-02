extends CanvasLayer

@export var buildingScenes: Dictionary

@export var DefaultEnergyCol: Color
@export var BoostedEnergyCol: Color
@export var SlowedEnergyCol: Color
@export var ExhaustedEnergyCol: Color

@onready var end_btn = $EndRoundBtn

var currBuildingName = ''
var currBuilding = null
var hoveringPlanet = false

func _ready():
	$BuildingOptions.hide()
	$EnergyIndicator.hide()

func _process(delta):
	if currBuilding and !hoveringPlanet:
		#var mouse: Vector2 = get_viewport().get_canvas_transform().affine_inverse().xform(get_viewport.get_mouse_position())

		currBuilding.position = currBuilding.get_global_mouse_position()


func set_inventory(materials):
	$Inventory.text = 'Inventory:'
	for i in materials:
		$Inventory.text += '\n%s: %s' % [Constants.MaterialType.keys()[i], materials[i]]

func set_energy(amount, max_energy):
	$EnergyBG/Energy.text = '%s' % amount


func _on_building_selected(building:String):
	if currBuilding:
		currBuilding.queue_free()
	currBuildingName = building
	currBuilding = buildingScenes[building].instantiate()
	add_child(currBuilding)
	$EnergyIndicator.hide()

func _on_new_building_pressed():
	$BuildingOptions.visible = !$BuildingOptions.visible
	if !$BuildingOptions.visible and currBuilding:
		currBuilding.queue_free()
		currBuilding = null

func _on_planet_selected(planet:Node):
	if currBuilding != null:
		if !planet.can_add_building(currBuildingName):
			return
		planet.add_building(currBuilding)
		currBuilding = null
		_on_new_building_pressed()

func _on_planet_hovered(planet:Node):
	if currBuilding != null:
		if !planet.can_add_building(currBuildingName):
			return
			
		hoveringPlanet = true
		if currBuilding != null:
			planet.display_building(currBuilding)
	elif planet != Constants.Game.player.currPlanet:
		$EnergyIndicator.show()
		$EnergyIndicator.position = planet.get_global_transform_with_canvas().origin
		var vals = Constants.Game.player.calc_travel_mod(planet)
		var cost = vals[0]; var mod = vals[1]
		$EnergyIndicator/Label.text = str(cost)
		if mod == null:
			$EnergyIndicator/Label.self_modulate = ExhaustedEnergyCol
		elif mod == 0:
			$EnergyIndicator/Label.self_modulate = DefaultEnergyCol
		elif mod < 0:
			$EnergyIndicator/Label.self_modulate = BoostedEnergyCol
		elif mod > 0:
			$EnergyIndicator/Label.self_modulate = SlowedEnergyCol
	
func _on_planet_unhovered(planet:Node):
	hoveringPlanet = false
	if currBuilding != null and currBuilding.get_parent() != self:
		currBuilding.get_parent().remove_child(currBuilding)
		add_child(currBuilding)
		
	$EnergyIndicator.hide()


func _on_popup_timer_timeout():
	$TurnIndicators/Aliens.hide()
	$TurnIndicators/Player.hide()

func _on_game_enemy_round_begin():
	$TurnIndicators/Aliens.show()
	$TurnIndicators/PopupTimer.start()

func _on_game_player_round_begin():
	$TurnIndicators/Player.show()
	$TurnIndicators/PopupTimer.start()
