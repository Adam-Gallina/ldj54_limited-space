extends Node

func _ready():
	get_node('/root/BackgroundAudio').play()
	$AnimatedSprite2D.play()

func _on_tutorial_pressed():
	get_tree().change_scene_to_file("res://tutorial.tscn")
	
func _on_start_pressed():
	get_tree().change_scene_to_file("res://game.tscn")

func _on_quit_pressed():
	get_tree().quit()
