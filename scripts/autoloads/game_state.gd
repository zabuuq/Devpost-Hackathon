extends Node

enum Phase { SPLASH, MENU, PLACEMENT, HANDOFF, GAMEPLAY, VICTORY }

var phase: Phase = Phase.SPLASH
var current_player: int = 0
var turn_number: int = 0
var last_turn_hits: int = 0
var last_turn_results: Array = []  # action results from opponent's turn, replayed into battle log
var sfx_enabled: bool = true
var music_enabled: bool = true

const BATTLE_LOG_CAP: int = 200

var players: Array = [
	{
		"fleet": [],
		"cell_records": {},
		"turn_stats": {
			"probes_launched": 0,
			"hits_scored": 0
		},
		"command_camera": {},
		"target_camera": {},
		"battle_log": [],
		"turns_played": 0
	},
	{
		"fleet": [],
		"cell_records": {},
		"turn_stats": {
			"probes_launched": 0,
			"hits_scored": 0
		},
		"command_camera": {},
		"target_camera": {},
		"battle_log": [],
		"turns_played": 0
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
			},
			"command_camera": {},
			"target_camera": {},
			"battle_log": [],
			"turns_played": 0
		},
		{
			"fleet": [],
			"cell_records": {},
			"turn_stats": {
				"probes_launched": 0,
				"hits_scored": 0
			},
			"command_camera": {},
			"target_camera": {},
			"battle_log": [],
			"turns_played": 0
		}
	]

func append_battle_log(player_idx: int, entry: Dictionary) -> void:
	var log: Array = players[player_idx]["battle_log"]
	log.append(entry)
	while log.size() > BATTLE_LOG_CAP:
		log.pop_front()

func append_battle_log_divider(player_idx: int, turn_number_arg: int, is_opponent: bool) -> void:
	var entry: Dictionary = {
		"type": "divider",
		"turn_number": turn_number_arg,
		"is_opponent": is_opponent
	}
	append_battle_log(player_idx, entry)

func get_opponent_idx() -> int:
	return 1 - current_player

func get_current_player_data() -> Dictionary:
	return players[current_player]

func get_opponent_data() -> Dictionary:
	return players[get_opponent_idx()]
