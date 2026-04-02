extends Node

enum Phase { SPLASH, MENU, PLACEMENT, HANDOFF, GAMEPLAY, VICTORY }

var phase: Phase = Phase.SPLASH
var current_player: int = 0
var turn_number: int = 0
var last_turn_hits: int = 0
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
