extends Node

enum Phase { SPLASH, MENU, PLACEMENT, HANDOFF, GAMEPLAY, VICTORY }

var phase: Phase = Phase.SPLASH
var current_player: int = 0
var turn_number: int = 0
var last_turn_hits: int = 0
var last_turn_results: Array = []  # action results from opponent's turn, replayed into battle log
var sfx_enabled: bool = true
var music_enabled: bool = true

var players: Array = [
	{
		"fleet": [],
		"cell_records": {},
		"turn_stats": {
			"probes_launched": 0,
			"hits_scored": 0
		}
	},
	{
		"fleet": [],
		"cell_records": {},
		"turn_stats": {
			"probes_launched": 0,
			"hits_scored": 0
		}
	}
]

func reset() -> void:
	phase = Phase.SPLASH
	current_player = 0
	turn_number = 0
	last_turn_hits = 0
	last_turn_results = []
	players = [
		{
			"fleet": [],
			"cell_records": {},
			"turn_stats": {
				"probes_launched": 0,
				"hits_scored": 0
			}
		},
		{
			"fleet": [],
			"cell_records": {},
			"turn_stats": {
				"probes_launched": 0,
				"hits_scored": 0
			}
		}
	]

func get_opponent_idx() -> int:
	return 1 - current_player

func get_current_player_data() -> Dictionary:
	return players[current_player]

func get_opponent_data() -> Dictionary:
	return players[get_opponent_idx()]
