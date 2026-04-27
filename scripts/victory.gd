extends Control
## Victory screen — displays winner announcement and per-player stats.

@onready var winner_label: Label = $VBoxContainer/WinnerLabel
@onready var p1_probes: Label = $VBoxContainer/StatsRow/P1Stats/P1Grid/P1Probes
@onready var p1_lasers: Label = $VBoxContainer/StatsRow/P1Stats/P1Grid/P1Lasers
@onready var p1_missiles: Label = $VBoxContainer/StatsRow/P1Stats/P1Grid/P1Missiles
@onready var p1_hits: Label = $VBoxContainer/StatsRow/P1Stats/P1Grid/P1Hits
@onready var p1_damage: Label = $VBoxContainer/StatsRow/P1Stats/P1Grid/P1Damage
@onready var p1_misses: Label = $VBoxContainer/StatsRow/P1Stats/P1Grid/P1Misses
@onready var p2_probes: Label = $VBoxContainer/StatsRow/P2Stats/P2Grid/P2Probes
@onready var p2_lasers: Label = $VBoxContainer/StatsRow/P2Stats/P2Grid/P2Lasers
@onready var p2_missiles: Label = $VBoxContainer/StatsRow/P2Stats/P2Grid/P2Missiles
@onready var p2_hits: Label = $VBoxContainer/StatsRow/P2Stats/P2Grid/P2Hits
@onready var p2_damage: Label = $VBoxContainer/StatsRow/P2Stats/P2Grid/P2Damage
@onready var p2_misses: Label = $VBoxContainer/StatsRow/P2Stats/P2Grid/P2Misses
@onready var play_again_btn: Button = $VBoxContainer/PlayAgainButton


func _ready() -> void:
	var winner: int = GameState.current_player + 1
	winner_label.text = "Player %d Wins!" % winner

	var p1_stats: Dictionary = GameState.players[0].turn_stats
	var p2_stats: Dictionary = GameState.players[1].turn_stats

	p1_probes.text = "%d" % p1_stats.get("probes_launched", 0)
	p1_lasers.text = "%d" % p1_stats.get("laser_shots_fired", 0)
	p1_missiles.text = "%d" % p1_stats.get("missile_shots_fired", 0)
	p1_hits.text = "%d" % p1_stats.get("hits_scored", 0)
	p1_damage.text = "%d" % p1_stats.get("total_damage", 0)
	p1_misses.text = "%d" % p1_stats.get("total_misses", 0)

	p2_probes.text = "%d" % p2_stats.get("probes_launched", 0)
	p2_lasers.text = "%d" % p2_stats.get("laser_shots_fired", 0)
	p2_missiles.text = "%d" % p2_stats.get("missile_shots_fired", 0)
	p2_hits.text = "%d" % p2_stats.get("hits_scored", 0)
	p2_damage.text = "%d" % p2_stats.get("total_damage", 0)
	p2_misses.text = "%d" % p2_stats.get("total_misses", 0)

	play_again_btn.set_theme_type_variation(&"HeaderButton")
	play_again_btn.pressed.connect(_on_play_again)


func _on_play_again() -> void:
	GameState.reset()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
