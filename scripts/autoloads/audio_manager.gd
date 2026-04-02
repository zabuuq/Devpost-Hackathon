extends Node

# AudioStreamPlayer nodes — added as children at runtime
var _music_player: AudioStreamPlayer = null
var _sfx_players: Dictionary = {}

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	add_child(_music_player)

func play_sfx(sfx_name: String) -> void:
	if not GameState.sfx_enabled:
		return
	# TODO: load and play res://assets/audio/sfx/{sfx_name}.ogg
	# Placeholder — audio assets not yet present
	pass

func play_music(music_name: String) -> void:
	if not GameState.music_enabled:
		return
	# TODO: load and play res://assets/audio/music/{music_name}.ogg
	# Placeholder — audio assets not yet present
	pass

func stop_music() -> void:
	if _music_player and _music_player.playing:
		_music_player.stop()

func set_sfx_enabled(enabled: bool) -> void:
	GameState.sfx_enabled = enabled

func set_music_enabled(enabled: bool) -> void:
	GameState.music_enabled = enabled
	if not enabled:
		stop_music()
