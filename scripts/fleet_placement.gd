extends Control

const CELL_SIZE: int = 32
const GRID_COLS: int = 80
const GRID_ROWS: int = 20
const GRID_CENTER: Vector2i = Vector2i(40, 10)

const SHIP_NAMES: Dictionary = {
	"battleship": "Battleship",
	"probe_ship": "Probe Ship",
	"destroyer": "Destroyer",
	"cruiser": "Cruiser"
}

@onready var ship_list_container: VBoxContainer = $HSplitContainer/LeftPanel/ScrollContainer/ShipList
@onready var done_button: Button = $HSplitContainer/LeftPanel/DoneButton
@onready var grid_node: Node2D = $HSplitContainer/GridViewport/SubViewport/GridNode
@onready var camera: Camera2D = $HSplitContainer/GridViewport/SubViewport/GridNode/Camera2D
@onready var detail_name: Label = $HSplitContainer/RightPanel/DetailPanel/ShipName
@onready var detail_stats: Label = $HSplitContainer/RightPanel/DetailPanel/ShipStats
@onready var player_label: Label = $PlayerLabel
@onready var viewport_container: SubViewportContainer = $HSplitContainer/GridViewport

var placed_ships: Dictionary = {}
var selected_ship_idx: int = -1
var ghost_position: Vector2i = Vector2i(-1, -1)
var ghost_facing: int = 0
var ghost_valid: bool = false
var ship_buttons: Array[Button] = []

func _ready() -> void:
	player_label.text = "Player %d — Place Your Fleet" % (GameState.current_player + 1)
	_setup_ship_list()
	done_button.disabled = true
	grid_node.draw.connect(_draw_grid)
	grid_node.queue_redraw()

func _setup_ship_list() -> void:
	for i in range(ShipDefinitions.FLEET.size()):
		var stype: String = ShipDefinitions.FLEET[i]
		var btn := Button.new()
		var squares: int = ShipDefinitions.SHIPS[stype]["squares"]
		btn.text = "%s (%d sq)" % [SHIP_NAMES.get(stype, stype), squares]
		btn.custom_minimum_size = Vector2(160, 36)
		btn.pressed.connect(_on_ship_button_pressed.bind(i))
		ship_list_container.add_child(btn)
		ship_buttons.append(btn)

func _on_ship_button_pressed(idx: int) -> void:
	AudioManager.play_sfx("click")
	if idx in placed_ships:
		placed_ships.erase(idx)
		ship_buttons[idx].modulate = Color.WHITE
		done_button.disabled = true
	selected_ship_idx = idx
	ghost_facing = 0
	ghost_position = GRID_CENTER
	_update_detail_panel(ShipDefinitions.FLEET[idx])
	grid_node.queue_redraw()

func _update_detail_panel(stype: String) -> void:
	var stats: Dictionary = ShipDefinitions.SHIPS[stype]
	detail_name.text = SHIP_NAMES.get(stype, stype)
	var special_text: String
	match stats.get("special", ""):
		"large_probe": special_text = "Special: 6x6 probe, 50 energy"
		"double_move": special_text = "Special: 2 move actions/turn"
		_: special_text = "Special: —"
	detail_stats.text = "Shields: %d\nArmor: %d\nEnergy: %d\nLaser: %d\nMissiles: %d\nProbes: %d\nSize: %d sq\n%s" % [
		stats["max_shields"], stats["max_armor"], stats["max_energy"],
		stats["laser_strength"], stats["missiles"], stats["probes"],
		stats["squares"], special_text
	]

func _input(event: InputEvent) -> void:
	if selected_ship_idx == -1:
		return
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_Q:
			_rotate_ghost(-1)
		elif event.keycode == KEY_E:
			_rotate_ghost(1)

func _rotate_ghost(delta: int) -> void:
	var stype: String = ShipDefinitions.FLEET[selected_ship_idx]
	# Keep the pivot square fixed in grid space
	var old_pivot: Vector2i = ghost_position + ShipDefinitions.get_pivot_offset(stype, ghost_facing)
	ghost_facing = (ghost_facing + delta + 4) % 4
	var new_pivot_offset: Vector2i = ShipDefinitions.get_pivot_offset(stype, ghost_facing)
	ghost_position = old_pivot - new_pivot_offset
	grid_node.queue_redraw()

func _on_viewport_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		ghost_position = _screen_to_grid(event.position)
		grid_node.queue_redraw()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if selected_ship_idx >= 0:
			_try_place_ship()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		selected_ship_idx = -1
		grid_node.queue_redraw()

func _screen_to_grid(local_pos: Vector2) -> Vector2i:
	# camera.zoom=1, camera centered at (grid_w/2, grid_h/2).
	# With stretch=true: container px maps linearly to SubViewport px = world px.
	var vp_size: Vector2 = viewport_container.size
	if vp_size.x <= 0 or vp_size.y <= 0:
		return Vector2i.ZERO
	var world_pos: Vector2 = local_pos * Vector2(GRID_COLS * CELL_SIZE, GRID_ROWS * CELL_SIZE) / vp_size
	var col: int = int(world_pos.x / CELL_SIZE)
	var row: int = int(world_pos.y / CELL_SIZE)
	return Vector2i(clampi(col, 0, GRID_COLS - 1), clampi(row, 0, GRID_ROWS - 1))

func _try_place_ship() -> void:
	if not ghost_valid:
		return
	var instance := ShipInstance.create(ShipDefinitions.FLEET[selected_ship_idx])
	instance.position = ghost_position
	instance.facing = ghost_facing
	placed_ships[selected_ship_idx] = instance
	ship_buttons[selected_ship_idx].modulate = Color(0.4, 1.0, 0.4)
	selected_ship_idx = -1
	done_button.disabled = placed_ships.size() < ShipDefinitions.FLEET.size()
	grid_node.queue_redraw()

func _is_placement_valid(stype: String, origin: Vector2i, facing: int) -> bool:
	var cells := ShipDefinitions.get_ship_cells(stype, origin, facing)
	for cell in cells:
		if cell.x < 0 or cell.x >= GRID_COLS or cell.y < 0 or cell.y >= GRID_ROWS:
			return false
	var occupied: Array[Vector2i] = []
	for idx in placed_ships:
		var inst: ShipInstance = placed_ships[idx]
		occupied.append_array(ShipDefinitions.get_ship_cells(inst.ship_type, inst.position, inst.facing))
	for cell in cells:
		if cell in occupied:
			return false
	return true

func _draw_grid() -> void:
	grid_node.draw_rect(Rect2(0, 0, GRID_COLS * CELL_SIZE, GRID_ROWS * CELL_SIZE), Color(0.05, 0.05, 0.2, 1.0))
	var line_color := Color(0.2, 0.2, 0.4, 0.6)
	for col in range(GRID_COLS + 1):
		var x: float = col * CELL_SIZE
		grid_node.draw_line(Vector2(x, 0), Vector2(x, GRID_ROWS * CELL_SIZE), line_color, 1.0)
	for row in range(GRID_ROWS + 1):
		var y: float = row * CELL_SIZE
		grid_node.draw_line(Vector2(0, y), Vector2(GRID_COLS * CELL_SIZE, y), line_color, 1.0)
	for idx in placed_ships:
		var inst: ShipInstance = placed_ships[idx]
		var cells := ShipDefinitions.get_ship_cells(inst.ship_type, inst.position, inst.facing)
		for cell in cells:
			var rect := Rect2(cell.x * CELL_SIZE + 1, cell.y * CELL_SIZE + 1, CELL_SIZE - 2, CELL_SIZE - 2)
			grid_node.draw_rect(rect, Color(0.2, 0.6, 1.0, 0.8))
		if cells.size() > 0:
			var fc := cells[0]
			var center := Vector2(fc.x * CELL_SIZE + CELL_SIZE * 0.5, fc.y * CELL_SIZE + CELL_SIZE * 0.5)
			grid_node.draw_circle(center, 4.0, Color(1.0, 1.0, 0.3, 1.0))
	if selected_ship_idx >= 0:
		var stype: String = ShipDefinitions.FLEET[selected_ship_idx]
		ghost_valid = _is_placement_valid(stype, ghost_position, ghost_facing)
		var ghost_color := Color(0.3, 1.0, 0.3, 0.5) if ghost_valid else Color(1.0, 0.2, 0.2, 0.5)
		var cells := ShipDefinitions.get_ship_cells(stype, ghost_position, ghost_facing)
		for cell in cells:
			if cell.x >= 0 and cell.x < GRID_COLS and cell.y >= 0 and cell.y < GRID_ROWS:
				var rect := Rect2(cell.x * CELL_SIZE + 1, cell.y * CELL_SIZE + 1, CELL_SIZE - 2, CELL_SIZE - 2)
				grid_node.draw_rect(rect, ghost_color)

func _on_done_pressed() -> void:
	AudioManager.play_sfx("click")
	var fleet: Array = []
	for i in range(ShipDefinitions.FLEET.size()):
		fleet.append(placed_ships[i])
	GameState.players[GameState.current_player]["fleet"] = fleet
	GameState.last_turn_hits = 0
	get_tree().change_scene_to_file("res://scenes/handoff.tscn")
