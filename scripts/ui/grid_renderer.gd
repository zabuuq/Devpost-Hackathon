extends Node2D
class_name GridRenderer

const CELL_SIZE: int = 32
const GRID_COLS: int = 80
const GRID_ROWS: int = 20

const COLOR_BG: Color = Color(0.05, 0.05, 0.15, 1.0)
const COLOR_GRID_LINE: Color = Color(0.15, 0.15, 0.3, 0.8)
const COLOR_PROBE_FILL: Color = Color(0.3, 0.7, 1.0, 0.2)
const COLOR_PROBE_BORDER: Color = Color(0.3, 0.7, 1.0, 0.9)
const COLOR_WRECKAGE: Color = Color(0.35, 0.25, 0.15, 1.0)
const COLOR_WRECKAGE_X: Color = Color(0.55, 0.45, 0.3, 1.0)
const COLOR_BLIND_HIT: Color = Color(1.0, 0.6, 0.2, 1.0)
const COLOR_FACING: Color = Color(1.0, 1.0, 0.3, 1.0)

const SHIP_COLORS: Dictionary = {
	"battleship": Color(0.2, 0.4, 1.0, 1.0),
	"probe_ship": Color(0.2, 0.85, 0.45, 1.0),
	"destroyer": Color(0.3, 0.8, 1.0, 1.0),
	"cruiser": Color(1.0, 0.65, 0.2, 1.0),
}

@export var is_command_grid: bool = true

# Set by gameplay.gd when probe targeting is active; 0 = no highlight
var probe_highlight_size: int = 0
var mouse_world_pos: Vector2 = Vector2.ZERO

func _draw() -> void:
	_draw_background()
	_draw_grid_lines()
	if is_command_grid:
		_draw_command_ships()
	else:
		_draw_target_cells()
	_draw_probe_highlight()

func _draw_background() -> void:
	draw_rect(Rect2(0.0, 0.0, GRID_COLS * CELL_SIZE, GRID_ROWS * CELL_SIZE), COLOR_BG)

func _draw_grid_lines() -> void:
	var grid_w: float = GRID_COLS * CELL_SIZE
	var grid_h: float = GRID_ROWS * CELL_SIZE
	for col in range(GRID_COLS + 1):
		var x: float = col * CELL_SIZE
		draw_line(Vector2(x, 0.0), Vector2(x, grid_h), COLOR_GRID_LINE, 1.0)
	for row in range(GRID_ROWS + 1):
		var y: float = row * CELL_SIZE
		draw_line(Vector2(0.0, y), Vector2(grid_w, y), COLOR_GRID_LINE, 1.0)

# --- Command Grid ---

func _draw_command_ships() -> void:
	var fleet: Array = GameState.players[GameState.current_player]["fleet"]
	for ship: Variant in fleet:
		var s: ShipInstance = ship
		if s.is_destroyed:
			_draw_wreckage_cells(s.get_occupied_cells())
		else:
			_draw_ship_cells(s.get_occupied_cells(), SHIP_COLORS.get(s.ship_type, Color.WHITE), 1.0)
			_draw_facing_arrow(s.position, s.facing)

# --- Target Grid ---

func _draw_target_cells() -> void:
	var cell_records: Dictionary = GameState.players[GameState.current_player]["cell_records"]
	var drawn_fog: Array = []
	for key: Variant in cell_records.keys():
		var cell: Vector2i = key
		var record: CellRecord = cell_records[cell]
		# Blind hit drawn only when no ship record (ship record takes visual priority)
		if record.has_blind_hit and record.ship == null:
			_draw_blind_hit(cell)
		if record.ship != null and not drawn_fog.has(record.ship):
			drawn_fog.append(record.ship)
			var fog: FogShipRecord = record.ship
			# Determine display state from this cell's has_probe flag
			var alpha: float = 1.0 if record.has_probe else 0.35
			_draw_ship_cells(
				ShipDefinitions.get_ship_cells(fog.ship_type, fog.position, fog.facing),
				SHIP_COLORS.get(fog.ship_type, Color.WHITE),
				alpha
			)
			if record.has_probe:
				_draw_facing_arrow(fog.position, fog.facing)

# --- Shared drawing helpers ---

func _draw_ship_cells(cells: Array[Vector2i], color: Color, alpha: float) -> void:
	var c := Color(color.r, color.g, color.b, alpha)
	for cell in cells:
		draw_rect(
			Rect2(cell.x * CELL_SIZE + 1, cell.y * CELL_SIZE + 1, CELL_SIZE - 2, CELL_SIZE - 2),
			c
		)

func _draw_wreckage_cells(cells: Array[Vector2i]) -> void:
	for cell in cells:
		var rx: float = cell.x * CELL_SIZE + 2
		var ry: float = cell.y * CELL_SIZE + 2
		var rw: float = CELL_SIZE - 4
		var rh: float = CELL_SIZE - 4
		draw_rect(Rect2(rx, ry, rw, rh), COLOR_WRECKAGE)
		draw_line(Vector2(rx, ry), Vector2(rx + rw, ry + rh), COLOR_WRECKAGE_X, 2.0)
		draw_line(Vector2(rx + rw, ry), Vector2(rx, ry + rh), COLOR_WRECKAGE_X, 2.0)

func _draw_facing_arrow(origin: Vector2i, facing: int) -> void:
	var cx: float = origin.x * CELL_SIZE + CELL_SIZE * 0.5
	var cy: float = origin.y * CELL_SIZE + CELL_SIZE * 0.5
	var offset: float = CELL_SIZE * 0.32
	var tip: Vector2
	match facing:
		0: tip = Vector2(cx, cy - offset)
		1: tip = Vector2(cx + offset, cy)
		2: tip = Vector2(cx, cy + offset)
		3: tip = Vector2(cx - offset, cy)
		_: tip = Vector2(cx, cy - offset)
	draw_line(Vector2(cx, cy), tip, COLOR_FACING, 3.0)
	draw_circle(tip, 4.0, COLOR_FACING)

func _draw_blind_hit(cell: Vector2i) -> void:
	var cx: float = cell.x * CELL_SIZE + CELL_SIZE * 0.5
	var cy: float = cell.y * CELL_SIZE + CELL_SIZE * 0.5
	draw_circle(Vector2(cx, cy), CELL_SIZE * 0.28, COLOR_BLIND_HIT)

func _draw_probe_highlight() -> void:
	if probe_highlight_size <= 0:
		return
	var cell_x: int = int(mouse_world_pos.x / CELL_SIZE)
	var cell_y: int = int(mouse_world_pos.y / CELL_SIZE)
	var half: int = probe_highlight_size >> 1
	# Clamp so the highlight stays fully within grid bounds
	var start_col: int = clampi(cell_x - half, 0, GRID_COLS - probe_highlight_size)
	var start_row: int = clampi(cell_y - half, 0, GRID_ROWS - probe_highlight_size)
	var rect := Rect2(
		start_col * CELL_SIZE,
		start_row * CELL_SIZE,
		probe_highlight_size * CELL_SIZE,
		probe_highlight_size * CELL_SIZE
	)
	draw_rect(rect, COLOR_PROBE_FILL)
	draw_rect(rect, COLOR_PROBE_BORDER, false, 2.0)

# --- Called by gameplay.gd ---

func set_mouse_world_pos(world_pos: Vector2) -> void:
	mouse_world_pos = world_pos
	if probe_highlight_size > 0:
		queue_redraw()

func refresh() -> void:
	queue_redraw()
