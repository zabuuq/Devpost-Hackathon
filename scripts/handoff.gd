extends Control

@onready var message_label: Label = $CenterPanel/MessageLabel

func _ready() -> void:
	GameState.phase = GameState.Phase.HANDOFF
	var player_num: int = GameState.current_player + 1
	var hits: int = GameState.last_turn_hits
	if GameState.turn_number == 0:
		message_label.text = "Player %d — place your fleet.\nPlayer %d, look away." % [player_num, 3 - player_num]
	else:
		message_label.text = "Player %d, your turn.\nYou took %d hit%s last turn.\nClick Next to begin." % [
			player_num,
			hits,
			"s" if hits != 1 else ""
		]

func _on_next_pressed() -> void:
	AudioManager.play_sfx("click")
	_advance()

func _advance() -> void:
	if GameState.phase == GameState.Phase.PLACEMENT:
		if GameState.current_player == 0:
			GameState.current_player = 1
			get_tree().change_scene_to_file("res://scenes/fleet_placement.tscn")
		else:
			GameState.current_player = 0
			GameState.phase = GameState.Phase.GAMEPLAY
			GameState.turn_number = 1
			get_tree().change_scene_to_file("res://scenes/gameplay.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/gameplay.tscn")
