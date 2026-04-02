extends Control

func _ready() -> void:
	GameState.phase = GameState.Phase.SPLASH

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		AudioServer.unlock()
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file.call_deferred("res://scenes/main_menu.tscn")
	elif event is InputEventMouseButton and event.pressed:
		AudioServer.unlock()
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file.call_deferred("res://scenes/main_menu.tscn")
