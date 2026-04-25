extends Control

const CELL_SIZE: int = 32
const GRID_COLS: int = 80
const GRID_ROWS: int = 20
const GRID_CENTER: Vector2i = Vector2i(40, 10)
const MIN_ZOOM: float = 0.1
const MAX_ZOOM: float = 4.0
const DRAG_THRESHOLD_PX: float = 4.0

const NEBULA_TEXTURE: Texture2D = preload("res://assets/backgrounds/nebula.jpg")
const NEBULA_SRC_RECT: Rect2 = Rect2(0, 900, 5333, 1333)

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
var is_panning: bool = false
var pan_start_mouse: Vector2 = Vector2.ZERO
var pan_start_cam: Vector2 = Vector2.ZERO

# Left-drag click-vs-pan disambiguation state
var mouse_down: bool = false
var mouse_down_pos: Vector2 = Vector2.ZERO
var dragged: bool = false

func _process(_delta: float) -> void:
	if selected_ship_idx >= 0:
		ghost_position = _screen_to_grid()
		grid_node.queue_redraw()

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
		# Tint each ship-type button in its canonical color. Use font color overrides
		# so placement-state signaling via `modulate` (green on placed) still works.
		var tint: Color = GridRenderer.SHIP_COLORS.get(stype, Color.WHITE)
		btn.add_theme_color_override("font_color", tint)
		btn.add_theme_color_override("font_hover_color", tint.lightened(0.2))
		btn.add_theme_color_override("font_pressed_color", tint.lightened(0.3))
		btn.add_theme_color_override("font_focus_color", tint)
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
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if event.ctrl_pressed:
				_zoom_camera_at(1.1)
			elif event.shift_pressed:
				camera.position.x -= float(CELL_SIZE) / camera.zoom.x
				_clamp_camera()
				grid_node.queue_redraw()
			else:
				camera.position.y -= float(CELL_SIZE) / camera.zoom.y
				_clamp_camera()
				grid_node.queue_redraw()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if event.ctrl_pressed:
				_zoom_camera_at(0.9)
			elif event.shift_pressed:
				camera.position.x += float(CELL_SIZE) / camera.zoom.x
				_clamp_camera()
				grid_node.queue_redraw()
			else:
				camera.position.y += float(CELL_SIZE) / camera.zoom.y
				_clamp_camera()
				grid_node.queue_redraw()
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				mouse_down = true
				dragged = false
				mouse_down_pos = event.position
				pan_start_mouse = event.position
				pan_start_cam = camera.position
				is_panning = false
			else:
				var was_dragged: bool = dragged
				mouse_down = false
				dragged = false
				is_panning = false
				if not was_dragged:
					if selected_ship_idx >= 0:
						_try_place_ship()
					else:
						_try_pick_up_ship()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			selected_ship_idx = -1
			grid_node.queue_redraw()
	elif event is InputEventMouseMotion:
		if mouse_down and (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
			if not dragged and event.position.distance_to(mouse_down_pos) >= DRAG_THRESHOLD_PX:
				dragged = true
				is_panning = true
			if is_panning:
				var delta: Vector2 = (pan_start_mouse - event.position) / camera.zoom
				camera.position = pan_start_cam + delta
				_clamp_camera()
				grid_node.queue_redraw()

func _screen_to_grid() -> Vector2i:
	var world_pos: Vector2 = grid_node.get_local_mouse_position()
	var col: int = int(world_pos.x / CELL_SIZE)
	var row: int = int(world_pos.y / CELL_SIZE)
	var mouse_cell := Vector2i(clampi(col, 0, GRID_COLS - 1), clampi(row, 0, GRID_ROWS - 1))
	if selected_ship_idx >= 0:
		var stype: String = ShipDefinitions.FLEET[selected_ship_idx]
		return mouse_cell - ShipDefinitions.get_pivot_offset(stype, ghost_facing)
	return mouse_cell

func _zoom_camera(factor: float) -> void:
	var new_zoom: float = clampf(camera.zoom.x * factor, MIN_ZOOM, MAX_ZOOM)
	camera.zoom = Vector2(new_zoom, new_zoom)
	_clamp_camera()
	grid_node.queue_redraw()

func _zoom_camera_at(factor: float) -> void:
	# Zoom while keeping the world point under the cursor stationary.
	# grid_node is a Node2D at origin so its local mouse position == world space.
	var world_before: Vector2 = grid_node.get_local_mouse_position()
	var old_zoom: float = camera.zoom.x
	var new_zoom: float = clampf(old_zoom * factor, MIN_ZOOM, MAX_ZOOM)
	if is_equal_approx(new_zoom, old_zoom):
		return
	camera.zoom = Vector2(new_zoom, new_zoom)
	var world_after: Vector2 = grid_node.get_local_mouse_position()
	camera.position += world_before - world_after
	_clamp_camera()
	grid_node.queue_redraw()

func _clamp_camera() -> void:
	var grid_w: float = GRID_COLS * CELL_SIZE
	var grid_h: float = GRID_ROWS * CELL_SIZE
	camera.position.x = clampf(camera.position.x, 0.0, grid_w)
	camera.position.y = clampf(camera.position.y, 0.0, grid_h)

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

func _try_pick_up_ship() -> void:
	var world_pos: Vector2 = grid_node.get_local_mouse_position()
	var col: int = clampi(int(world_pos.x / CELL_SIZE), 0, GRID_COLS - 1)
	var row: int = clampi(int(world_pos.y / CELL_SIZE), 0, GRID_ROWS - 1)
	var cell := Vector2i(col, row)
	var idx: int = _find_placed_ship_at(cell)
	if idx < 0:
		return
	var inst: ShipInstance = placed_ships[idx]
	placed_ships.erase(idx)
	ship_buttons[idx].modulate = Color.WHITE
	selected_ship_idx = idx
	ghost_facing = inst.facing
	ghost_position = inst.position
	done_button.disabled = placed_ships.size() < ShipDefinitions.FLEET.size()
	_update_detail_panel(ShipDefinitions.FLEET[idx])
	AudioManager.play_sfx("click")
	grid_node.queue_redraw()

func _find_placed_ship_at(cell: Vector2i) -> int:
	for idx in placed_ships:
		var inst: ShipInstance = placed_ships[idx]
		var cells: Array[Vector2i] = ShipDefinitions.get_ship_cells(inst.ship_type, inst.position, inst.facing)
		if cell in cells:
			return idx
	return -1

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
	grid_node.draw_texture_rect_region(
		NEBULA_TEXTURE,
		Rect2(0, 0, GRID_COLS * CELL_SIZE, GRID_ROWS * CELL_SIZE),
		NEBULA_SRC_RECT
	)
	var line_color := Color(0.15, 0.2, 0.32, 0.6)
	for col in range(GRID_COLS + 1):
		var x: float = col * CELL_SIZE
		grid_node.draw_line(Vector2(x, 0), Vector2(x, GRID_ROWS * CELL_SIZE), line_color, 1.0)
	for row in range(GRID_ROWS + 1):
		var y: float = row * CELL_SIZE
		grid_node.draw_line(Vector2(0, y), Vector2(GRID_COLS * CELL_SIZE, y), line_color, 1.0)
	for idx in placed_ships:
		var inst: ShipInstance = placed_ships[idx]
		var cells := ShipDefinitions.get_ship_cells(inst.ship_type, inst.position, inst.facing)
		var ship_color: Color = GridRenderer.SHIP_COLORS.get(inst.ship_type, Color.WHITE)
		for cell in cells:
			var rect := Rect2(cell.x * CELL_SIZE + 1, cell.y * CELL_SIZE + 1, CELL_SIZE - 2, CELL_SIZE - 2)
			grid_node.draw_rect(rect, ship_color)
		if cells.size() > 0:
			var front := cells[cells.size() - 1]
			_draw_facing_triangle_on_grid(grid_node, front, inst.facing)
	if selected_ship_idx >= 0:
		var stype: String = ShipDefinitions.FLEET[selected_ship_idx]
		ghost_valid = _is_placement_valid(stype, ghost_position, ghost_facing)
		# Valid ghost: blend the ship's tint toward green for a go-signal that still
		# reads as the selected ship type. Invalid ghost stays pure red.
		var ship_tint: Color = GridRenderer.SHIP_COLORS.get(stype, Color.WHITE)
		var valid_ghost: Color = ship_tint.lerp(Color(0.3, 1.0, 0.3, 1.0), 0.5)
		valid_ghost.a = 0.5
		var ghost_color := valid_ghost if ghost_valid else Color(1.0, 0.2, 0.2, 0.5)
		var cells := ShipDefinitions.get_ship_cells(stype, ghost_position, ghost_facing)
		for cell in cells:
			if cell.x >= 0 and cell.x < GRID_COLS and cell.y >= 0 and cell.y < GRID_ROWS:
				var rect := Rect2(cell.x * CELL_SIZE + 1, cell.y * CELL_SIZE + 1, CELL_SIZE - 2, CELL_SIZE - 2)
				grid_node.draw_rect(rect, ghost_color)
		if cells.size() > 0:
			var front := cells[cells.size() - 1]
			if front.x >= 0 and front.x < GRID_COLS and front.y >= 0 and front.y < GRID_ROWS:
				_draw_facing_triangle_on_grid(grid_node, front, ghost_facing)

func _draw_facing_triangle_on_grid(node: Node2D, cell: Vector2i, facing: int) -> void:
	var cx: float = cell.x * CELL_SIZE + CELL_SIZE * 0.5
	var cy: float = cell.y * CELL_SIZE + CELL_SIZE * 0.5
	var h: float = CELL_SIZE * 0.35
	var w: float = CELL_SIZE * 0.2
	var tip: Vector2
	var base_l: Vector2
	var base_r: Vector2
	match facing:
		0:
			tip = Vector2(cx, cy - h)
			base_l = Vector2(cx - w, cy + h)
			base_r = Vector2(cx + w, cy + h)
		1:
			tip = Vector2(cx + h, cy)
			base_l = Vector2(cx - h, cy - w)
			base_r = Vector2(cx - h, cy + w)
		2:
			tip = Vector2(cx, cy + h)
			base_l = Vector2(cx + w, cy - h)
			base_r = Vector2(cx - w, cy - h)
		3:
			tip = Vector2(cx - h, cy)
			base_l = Vector2(cx + h, cy + w)
			base_r = Vector2(cx + h, cy - w)
		_:
			tip = Vector2(cx, cy - h)
			base_l = Vector2(cx - w, cy + h)
			base_r = Vector2(cx + w, cy + h)
	node.draw_colored_polygon(PackedVector2Array([tip, base_l, base_r]), Color(1.0, 1.0, 0.3, 1.0))


func _on_done_pressed() -> void:
	AudioManager.play_sfx("click")
	var fleet: Array = []
	for i in range(ShipDefinitions.FLEET.size()):
		fleet.append(placed_ships[i])
	GameState.players[GameState.current_player]["fleet"] = fleet
	GameState.last_turn_hits = 0
	get_tree().change_scene_to_file("res://scenes/handoff.tscn")

func _on_randomize_pressed() -> void:
	AudioManager.play_sfx("click")
	# Snapshot prior board state so we can restore on the (defensive) failure path
	# where a ship can't be placed within the retry cap.
	var prior_placed: Dictionary = placed_ships.duplicate()
	var prior_modulates: Array[Color] = []
	for btn in ship_buttons:
		prior_modulates.append(btn.modulate)
	# Full board reset.
	placed_ships.clear()
	for btn in ship_buttons:
		btn.modulate = Color.WHITE
	selected_ship_idx = -1
	ghost_position = Vector2i(-1, -1)
	ghost_valid = false
	done_button.disabled = true
	const MAX_ATTEMPTS: int = 200
	for i in range(ShipDefinitions.FLEET.size()):
		var stype: String = ShipDefinitions.FLEET[i]
		var placed: bool = false
		for _attempt in range(MAX_ATTEMPTS):
			var origin := Vector2i(randi_range(0, GRID_COLS - 1), randi_range(0, GRID_ROWS - 1))
			var facing: int = randi_range(0, 3)
			if _is_placement_valid(stype, origin, facing):
				var instance := ShipInstance.create(stype)
				instance.position = origin
				instance.facing = facing
				placed_ships[i] = instance
				ship_buttons[i].modulate = Color(0.4, 1.0, 0.4)
				placed = true
				break
		if not placed:
			# Defensive rollback — should never trigger on an 80x20 grid.
			push_warning("Randomize: failed to place %s after %d attempts; restoring prior board." % [stype, MAX_ATTEMPTS])
			placed_ships = prior_placed
			for j in range(ship_buttons.size()):
				ship_buttons[j].modulate = prior_modulates[j]
			done_button.disabled = placed_ships.size() < ShipDefinitions.FLEET.size()
			grid_node.queue_redraw()
			return
	done_button.disabled = placed_ships.size() < ShipDefinitions.FLEET.size()
	grid_node.queue_redraw()
