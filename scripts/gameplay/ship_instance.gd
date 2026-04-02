class_name ShipInstance

var ship_type: String = ""
var position: Vector2i = Vector2i.ZERO   # grid cell of ship's origin square
var facing: int = 0                       # 0=up, 1=right, 2=down, 3=left

# Current stats
var current_shields: int = 0
var current_armor: int = 0
var current_energy: int = 0
var missiles_remaining: int = 0
var probes_remaining: int = 0

# Slider settings (persist between turns)
var shield_regen_setting: int = 0        # 0–250, increments of 50
var laser_power_setting: int = 0         # 0–500 (or 0–200 for probe_ship), increments of 50

# Turn state (reset each turn_start)
var action_taken: bool = false
var move_actions_taken: int = 0          # Cruiser gets 2; others get 1
var is_destroyed: bool = false

static func create(p_ship_type: String) -> ShipInstance:
	var inst := ShipInstance.new()
	inst.ship_type = p_ship_type
	var stats: Dictionary = ShipDefinitions.SHIPS[p_ship_type]
	inst.current_shields = stats["max_shields"]
	inst.current_armor = stats["max_armor"]
	inst.current_energy = stats["max_energy"]
	inst.missiles_remaining = stats["missiles"]
	inst.probes_remaining = stats["probes"]
	inst.shield_regen_setting = 0
	inst.laser_power_setting = 0
	return inst

func get_occupied_cells() -> Array[Vector2i]:
	return ShipDefinitions.get_ship_cells(ship_type, position, facing)

func is_alive() -> bool:
	return not is_destroyed
