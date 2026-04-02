extends Control

@onready var message_label: Label = $CenterPanel/MessageLabel

func _ready() -> void:
	GameState.phase = GameState.Phase.HANDOFF
	var player_num: int = GameState.current_player + 1
	var hits: int = GameState.last_turn_hits
	if GameState.turn_number == 0:
		if GameState.current_player == 0:
			# P1 just placed; P2 is up next
			message_label.text = "Player 2 — time to place your fleet.\nPlayer 1, please look away."
		else:
			# P2 just placed; gameplay is about to begin
			message_label.text = "Both fleets are placed!\nPlayer 1, click Next to begin the battle."
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
	# turn_number == 0 means we're still in fleet placement
	if GameState.turn_number == 0:
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
