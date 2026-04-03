extends Control
## Victory screen — displays winner announcement and per-player stats.

@onready var winner_label: Label = $VBoxContainer/WinnerLabel
@onready var p1_probes: Label = $VBoxContainer/StatsRow/P1Stats/P1Probes
@onready var p1_hits: Label = $VBoxContainer/StatsRow/P1Stats/P1Hits
@onready var p2_probes: Label = $VBoxContainer/StatsRow/P2Stats/P2Probes
@onready var p2_hits: Label = $VBoxContainer/StatsRow/P2Stats/P2Hits
@onready var play_again_btn: Button = $VBoxContainer/PlayAgainButton


func _ready() -> void:
	var winner: int = GameState.current_player + 1
	winner_label.text = "Player %d Wins!" % winner

	var p1_stats: Dictionary = GameState.players[0].turn_stats
	var p2_stats: Dictionary = GameState.players[1].turn_stats

	p1_probes.text = "Probes launched: %d" % p1_stats.get("probes_launched", 0)
	p1_hits.text = "Hits scored: %d" % p1_stats.get("hits_scored", 0)
	p2_probes.text = "Probes launched: %d" % p2_stats.get("probes_launched", 0)
	p2_hits.text = "Hits scored: %d" % p2_stats.get("hits_scored", 0)

	play_again_btn.pressed.connect(_on_play_again)


func _on_play_again() -> void:
	GameState.reset()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
