extends Node

# AudioStreamPlayer nodes — added as children at runtime
var _music_player: AudioStreamPlayer = null

const SFX_PATH: String = "res://assets/audio/sfx/"
const MUSIC_PATH: String = "res://assets/audio/music/"


func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	add_child(_music_player)


func play_sfx(sfx_name: String) -> void:
	if not GameState.sfx_enabled:
		return
	var path: String = SFX_PATH + sfx_name + ".ogg"
	if not ResourceLoader.exists(path):
		return
	var stream: AudioStream = load(path) as AudioStream
	if stream == null:
		return
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = stream
	player.bus = "Master"
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()


func play_music(music_name: String) -> void:
	if not GameState.music_enabled:
		return
	var path: String = MUSIC_PATH + music_name + ".ogg"
	if not ResourceLoader.exists(path):
		return
	var stream: AudioStream = load(path) as AudioStream
	if stream == null:
		return
	_music_player.stream = stream
	# Enable looping via AudioStreamOGGVorbis property
	if stream.has_method("set_loop"):
		stream.set("loop", true)
	elif "loop" in stream:
		stream.set("loop", true)
	_music_player.play()


func stop_music() -> void:
	if _music_player and _music_player.playing:
		_music_player.stop()


func set_sfx_enabled(enabled: bool) -> void:
	GameState.sfx_enabled = enabled


func set_music_enabled(enabled: bool) -> void:
	GameState.music_enabled = enabled
	if not enabled:
		stop_music()


## Convenience: play the appropriate SFX for an action result dictionary.
func play_action_sfx(result: Dictionary) -> void:
	var action_type: String = result.get("type", "")
	match action_type:
		"probe":
			play_sfx("probe")
		"laser":
			if result.get("destroyed", false):
				play_sfx("explosion")
			elif result.get("hit", false):
				play_sfx("hit")
			else:
				play_sfx("laser")
		"missile":
			if result.get("destroyed", false):
				play_sfx("explosion")
			elif result.get("hit", false):
				play_sfx("hit")
			else:
				play_sfx("missile")
