class_name ShipDefinitions

const SHIPS: Dictionary = {
	"battleship": {
		"squares": 5,
		"max_energy": 1000,
		"max_shields": 1000,
		"max_armor": 1000,
		"laser_strength": 250,
		"missiles": 24,
		"probes": 10,
		"probe_area": 4,
		"probe_cost": 50,
		"laser_max": 500,
		"base_move_points": 1.0,
		"special": ""
	},
	"probe_ship": {
		"squares": 4,
		"max_energy": 1000,
		"max_shields": 750,
		"max_armor": 750,
		"laser_strength": 100,
		"missiles": 0,
		"probes": 24,
		"probe_area": 7,
		"probe_cost": 50,
		"laser_max": 200,
		"base_move_points": 1.0,
		"special": "large_probe"
	},
	"destroyer": {
		"squares": 3,
		"max_energy": 750,
		"max_shields": 750,
		"max_armor": 750,
		"laser_strength": 250,
		"missiles": 12,
		"probes": 12,
		"probe_area": 4,
		"probe_cost": 50,
		"laser_max": 500,
		"base_move_points": 1.0,
		"special": ""
	},
	"cruiser": {
		"squares": 2,
		"max_energy": 500,
		"max_shields": 500,
		"max_armor": 500,
		"laser_strength": 250,
		"missiles": 10,
		"probes": 10,
		"probe_area": 4,
		"probe_cost": 50,
		"laser_max": 500,
		"base_move_points": 2.0,
		"special": ""
	}
}

# Fleet composition per player — two destroyers
const FLEET: Array = ["battleship", "probe_ship", "destroyer", "destroyer", "cruiser"]

static func get_ship_cells(ship_type: String, origin: Vector2i, facing: int) -> Array[Vector2i]:
	var squares: int = SHIPS[ship_type]["squares"]
	var cells: Array[Vector2i] = []
	var dir: Vector2i
	match facing:
		0: dir = Vector2i(0, -1)  # up
		1: dir = Vector2i(1, 0)   # right
		2: dir = Vector2i(0, 1)   # down
		3: dir = Vector2i(-1, 0)  # left
		_: dir = Vector2i(0, -1)
	for i in range(squares):
		cells.append(origin + dir * i)
	return cells

static func get_pivot_offset(ship_type: String, facing: int) -> Vector2i:
	# Returns the offset from origin to pivot square
	var pivot_idx: int
	match ship_type:
		"battleship": pivot_idx = 2   # square 3 (0-indexed = 2)
		"probe_ship": pivot_idx = 2   # square 3 (0-indexed = 2)
		"destroyer": pivot_idx = 1    # square 2 (0-indexed = 1)
		"cruiser": pivot_idx = 0      # square 2 (back) — origin is the back cell
		_: pivot_idx = 0
	var dir: Vector2i
	match facing:
		0: dir = Vector2i(0, -1)
		1: dir = Vector2i(1, 0)
		2: dir = Vector2i(0, 1)
		3: dir = Vector2i(-1, 0)
		_: dir = Vector2i(0, -1)
	return dir * pivot_idx
