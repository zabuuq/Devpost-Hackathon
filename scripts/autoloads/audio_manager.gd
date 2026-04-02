extends Node

func play_sfx(_name: String) -> void:
	pass

func play_music(_name: String) -> void:
	pass

func stop_music() -> void:
	pass

func set_sfx_enabled(_enabled: bool) -> void:
	if GameState:
		GameState.sfx_enabled = _enabled

func set_music_enabled(_enabled: bool) -> void:
	if GameState:
		GameState.music_enabled = _enabled
