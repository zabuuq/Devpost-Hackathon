extends Control

@onready var how_to_play_overlay: Control = $HowToPlayOverlay
@onready var sfx_button: Button = $MenuContainer/SFXToggle
@onready var music_button: Button = $MenuContainer/MusicToggle

func _ready() -> void:
	GameState.phase = GameState.Phase.MENU
	AudioManager.play_music("ambient_space")
	_update_toggle_labels()

func _on_start_pressed() -> void:
	AudioManager.play_sfx("click")
	GameState.reset()
	GameState.current_player = 0
	GameState.phase = GameState.Phase.PLACEMENT
	get_tree().change_scene_to_file("res://scenes/fleet_placement.tscn")

func _on_how_to_play_pressed() -> void:
	AudioManager.play_sfx("click")
	how_to_play_overlay.visible = true

func _on_close_overlay_pressed() -> void:
	AudioManager.play_sfx("click")
	how_to_play_overlay.visible = false

func _on_sfx_toggle_pressed() -> void:
	AudioManager.set_sfx_enabled(not GameState.sfx_enabled)
	_update_toggle_labels()

func _on_music_toggle_pressed() -> void:
	AudioManager.set_music_enabled(not GameState.music_enabled)
	_update_toggle_labels()

func _update_toggle_labels() -> void:
	sfx_button.text = "SFX: ON" if GameState.sfx_enabled else "SFX: OFF"
	music_button.text = "Music: ON" if GameState.music_enabled else "Music: OFF"
