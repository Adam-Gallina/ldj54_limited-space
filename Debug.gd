extends Node

func _unhandled_key_input(event):
	if event.is_pressed() and !event.is_echo():
		match (event.as_text()):
			'E': Constants.Game.player.currEnergy += 1
			'N': Constants.Game._on_end_enemy_round()
			'1': Constants.Game.player_bucket.deposit_material(Constants.MaterialType.Food, 1)
			'2': Constants.Game.player_bucket.deposit_material(Constants.MaterialType.Metal, 1)
			'3': Constants.Game.player_bucket.deposit_material(Constants.MaterialType.Electronic, 1)
