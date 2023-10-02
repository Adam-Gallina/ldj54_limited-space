extends CanvasLayer

var menuOpen = false

func _ready():
	$Menu.hide()
	$Win.hide()
	$Lose.hide()
	$LoseSatellite.hide()

func _unhandled_input(event):
	if Input.is_action_just_pressed('pause') and !menuOpen:
		$Menu.visible = !$Menu.visible

func _on_restart_pressed():
	get_tree().change_scene_to_file("res://game.tscn")

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://main.tscn")

func _on_game_player_win():
	if menuOpen: return
	menuOpen = true
	$Win.show()

func _on_game_player_lose():
	if menuOpen: return
	menuOpen = true
	$Lose.show()

func _on_game_satellite_lose():
	if menuOpen: return
	menuOpen = true
	$LoseSatellite.show()
