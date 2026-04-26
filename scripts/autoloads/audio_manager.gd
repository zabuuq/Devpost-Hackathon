extends Node

const SFX_PATH: String = "res://assets/audio/sfx/"


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


func set_sfx_enabled(enabled: bool) -> void:
	GameState.sfx_enabled = enabled


## Convenience: play the appropriate SFX for an action result dictionary.
## For laser/missile hits, plays the weapon sound first, then the impact sound after a delay.
func play_action_sfx(result: Dictionary) -> void:
	var action_type: String = result.get("type", "")
	match action_type:
		"probe":
			play_sfx("probe")
		"laser":
			play_sfx("laser")
			if result.get("destroyed", false) and result.get("has_probe", false):
				_play_sfx_delayed("explosion", 0.5)
			elif result.get("hit", false):
				_play_sfx_delayed("hit", 0.5)
		"missile":
			play_sfx("missile")
			if result.get("destroyed", false) and result.get("has_probe", false):
				_play_sfx_delayed("explosion", 0.8)
			elif result.get("hit", false):
				_play_sfx_delayed("hit", 0.8)


## Play an SFX after a delay (seconds). Used to sequence weapon + impact sounds.
func _play_sfx_delayed(sfx_name: String, delay: float) -> void:
	var timer: SceneTreeTimer = get_tree().create_timer(delay)
	timer.timeout.connect(play_sfx.bind(sfx_name))
