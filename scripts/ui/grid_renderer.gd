extends Node2D
class_name GridRenderer

const CELL_SIZE: int = 32
const GRID_COLS: int = 80
const GRID_ROWS: int = 20

const NEBULA_TEXTURE: Texture2D = preload("res://assets/backgrounds/nebula.jpg")
# Source is 5333x3555; grid is 4:1. Horizontal band 5333x1333 centered vertically
# but shifted up (y=900) to keep the bright bottom-right orange star out of frame.
const NEBULA_SRC_RECT: Rect2 = Rect2(0, 900, 5333, 1333)

const COLOR_BG: Color = Color(0.08, 0.06, 0.16, 1.0)
const COLOR_GRID_LINE: Color = Color(0.12, 0.15, 0.25, 0.8)
const COLOR_PROBE_FILL: Color = Color(0.0, 0.0, 0.0, 0.45)
const COLOR_PROBE_BORDER: Color = Color(0.4, 0.88, 0.82, 0.9)
# I7-4: faint "you've looked here" border drawn on cells that were once inside
# an active probe area but no longer have active coverage. Sits below the active
# probe fill so live coverage always reads on top.
const COLOR_HISTORICAL_PROBE: Color = Color(0.5, 0.7, 0.9, 0.25)
const COLOR_WRECKAGE: Color = Color(0.35, 0.25, 0.15, 1.0)
const COLOR_WRECKAGE_X: Color = Color(0.55, 0.45, 0.3, 1.0)
const COLOR_HIT_FULL: Color = Color(0.8, 0.4, 0.4, 0.9)
const COLOR_HIT_FADED: Color = Color(0.6, 0.6, 0.6, 0.4)
const COLOR_MISS_FULL: Color = Color(0.8, 0.4, 0.4, 0.9)
const COLOR_MISS_FADED: Color = Color(0.6, 0.6, 0.6, 0.4)
# I7-5: incoming opponent fire markers on Command Grid. Hits = solid red dot.
# Near misses = orange X. Latest opponent turn draws full alpha; the turn before
# that draws at half alpha; older entries are skipped ("gone on the third").
const COLOR_INCOMING_HIT_FULL: Color = Color(1.0, 0.15, 0.15, 1.0)
const COLOR_INCOMING_HIT_FADED: Color = Color(1.0, 0.15, 0.15, 0.5)
const COLOR_INCOMING_NEAR_MISS_FULL: Color = Color(1.0, 0.6, 0.2, 0.9)
const COLOR_INCOMING_NEAR_MISS_FADED: Color = Color(1.0, 0.6, 0.2, 0.45)
# I7-6: hostile-red contour around opponent active probe areas on the Command
# Grid. Drawn only when at least one cell of any of the viewer's living ships
# sits inside the opponent's probe coverage — presence-based "you're being
# watched" indicator.
const COLOR_OPPONENT_PROBE_BOUNDARY: Color = Color(1.0, 0.3, 0.3, 0.7)
const COLOR_FACING: Color = Color(1.0, 1.0, 0.3, 1.0)

const SHIP_COLORS: Dictionary = {
	"battleship": Color(0.2, 0.4, 1.0, 1.0),
	"probe_ship": Color(0.2, 0.85, 0.45, 1.0),
	"destroyer": Color(0.35, 0.65, 1.0, 1.0),
	"cruiser": Color(1.0, 0.65, 0.2, 1.0),
}

const COLOR_GHOST_SHIP: Color = Color(1.0, 1.0, 1.0, 0.35)
const COLOR_GHOST_SHIP_INVALID: Color = Color(1.0, 0.2, 0.2, 0.35)
const COLOR_SELECTED_SHIP: Color = Color(1.0, 1.0, 0.3, 0.6)

@export var is_command_grid: bool = true

# Set by gameplay.gd when probe targeting is active; 0 = no highlight
var probe_highlight_size: int = 0
var mouse_world_pos: Vector2 = Vector2.ZERO

# Ghost ship for move preview — set by gameplay.gd
var ghost_cells: Array[Vector2i] = []
var ghost_facing: int = 0
var ghost_origin: Vector2i = Vector2i.ZERO
var ghost_valid: bool = true
var ghost_visible: bool = false

# Selected ship highlight — set by gameplay.gd
var selected_ship: ShipInstance = null

# Selected enemy ship highlight (target grid only) — set by gameplay.gd
var selected_enemy_fog: FogShipRecord = null

func _draw() -> void:
	_draw_background()
	_draw_grid_lines()
	if is_command_grid:
		_draw_command_ships()
		_draw_selected_highlight()
		_draw_ghost_ship()
	else:
		_draw_target_cells()
		_draw_selected_enemy_highlight()
	_draw_probe_highlight()

func _draw_background() -> void:
	var dest := Rect2(0.0, 0.0, GRID_COLS * CELL_SIZE, GRID_ROWS * CELL_SIZE)
	draw_texture_rect_region(NEBULA_TEXTURE, dest, NEBULA_SRC_RECT)

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
	# First pass: draw wreckage for destroyed ships so they sit under living ships
	for ship: Variant in fleet:
		var s: ShipInstance = ship
		if s.is_destroyed:
			_draw_wreckage_cells(s.get_occupied_cells())
	# Second pass: draw living ships + facing triangles on top
	for ship: Variant in fleet:
		var s: ShipInstance = ship
		if not s.is_destroyed:
			_draw_ship_cells(s.get_occupied_cells(), SHIP_COLORS.get(s.ship_type, Color.WHITE), 1.0)
			_draw_facing_triangle(_get_front_cell(s.ship_type, s.position, s.facing), s.facing)
	# I7-5: incoming hits + near misses on top of living ships. Selection and
	# ghost-ship overlays are still drawn after _draw_command_ships() returns,
	# so they will sit above these markers if they coincide.
	_draw_incoming_fire()
	# I7-6: contour of opponent active probe areas overlapping viewer's ships.
	# Boundary only — fill stays untouched so the player's ships remain visible.
	_draw_opponent_probe_boundary()

# I7-5: Incoming opponent fire markers on the Command Grid. Reads the current
# player's battle_log (entries pushed in gameplay.gd _ready() with owner == 1
# and turn_number = the opponent's turns_played at fire time). Markers from the
# most recent opponent turn render at full intensity; markers from the turn
# before that render at half alpha. Older entries are skipped — "gone on the
# third" rule from backlog. The I6 near-miss filter already excluded misses
# that aren't 8-way Chebyshev adjacent to a defender ship cell, so every miss
# entry in the log is a near miss by definition.
func _draw_incoming_fire() -> void:
	var log: Array = GameState.players[GameState.current_player]["battle_log"]
	if log.is_empty():
		return
	# Find the most recent opponent fire turn_number across the log.
	var latest_opp_turn: int = -1
	for entry: Variant in log:
		var e: Dictionary = entry
		if e.get("owner", 0) != 1:
			continue
		var t: String = e.get("type", "")
		if t != "laser" and t != "missile":
			continue
		var tn: int = int(e.get("turn_number", 0))
		if tn > latest_opp_turn:
			latest_opp_turn = tn
	if latest_opp_turn <= 0:
		return
	# Draw markers from latest_opp_turn (full) and latest_opp_turn - 1 (faded).
	for entry: Variant in log:
		var e: Dictionary = entry
		if e.get("owner", 0) != 1:
			continue
		var t: String = e.get("type", "")
		if t != "laser" and t != "missile":
			continue
		var tn: int = int(e.get("turn_number", 0))
		var full: bool
		if tn == latest_opp_turn:
			full = true
		elif tn == latest_opp_turn - 1:
			full = false
		else:
			continue
		var target: Vector2i = e.get("target", Vector2i.ZERO)
		var hit: bool = bool(e.get("hit", false))
		if hit:
			_draw_incoming_hit_dot(target, full)
		else:
			_draw_incoming_near_miss_x(target, full)


func _draw_incoming_hit_dot(cell: Vector2i, full_intensity: bool) -> void:
	var cx: float = cell.x * CELL_SIZE + CELL_SIZE * 0.5
	var cy: float = cell.y * CELL_SIZE + CELL_SIZE * 0.5
	var color: Color = COLOR_INCOMING_HIT_FULL if full_intensity else COLOR_INCOMING_HIT_FADED
	draw_circle(Vector2(cx, cy), CELL_SIZE * 0.30, color)


func _draw_incoming_near_miss_x(cell: Vector2i, full_intensity: bool) -> void:
	# Mirror _draw_miss_x stroke + margin, just a different color.
	var margin: float = CELL_SIZE * 0.25
	var x0: float = cell.x * CELL_SIZE + margin
	var y0: float = cell.y * CELL_SIZE + margin
	var x1: float = (cell.x + 1) * CELL_SIZE - margin
	var y1: float = (cell.y + 1) * CELL_SIZE - margin
	var color: Color = COLOR_INCOMING_NEAR_MISS_FULL if full_intensity else COLOR_INCOMING_NEAR_MISS_FADED
	draw_line(Vector2(x0, y0), Vector2(x1, y1), color, 2.0)
	draw_line(Vector2(x1, y0), Vector2(x0, y1), color, 2.0)


# I7-6: Draw a red contour around opponent active probe areas on the viewer's
# Command Grid, but only when at least one cell of one of the viewer's living
# ships overlaps the opponent's probe coverage. Presence-based rule — the
# boundary appears the moment a living ship sits under an active probe and
# disappears the moment the last ship leaves (or the probe expires on the
# opponent's side). Reads the opponent's cell_records as a read-only data
# source. For each cell in the opponent probe set, we draw only the four edges
# whose neighbor in that direction is NOT also a probe cell, so contiguous
# probe regions render as a single outer contour.
func _draw_opponent_probe_boundary() -> void:
	var opponent_idx: int = 1 - GameState.current_player
	var opponent_records: Dictionary = GameState.players[opponent_idx]["cell_records"]
	if opponent_records.is_empty():
		return
	# Collect every opponent cell with an active probe into a Vector2i->true set
	# for O(1) "is this cell probed?" lookups when computing the contour.
	var probe_cells: Dictionary = {}
	for key: Variant in opponent_records.keys():
		var cell: Vector2i = key
		var record: CellRecord = opponent_records[cell]
		if record.has_probe:
			probe_cells[cell] = true
	if probe_cells.is_empty():
		return
	# Gate: at least one cell of one of the viewer's living ships must overlap
	# the probe set. Wreckage doesn't count — _collect_defender_living_cells in
	# gameplay.gd already filters destroyed ships, but this draw path needs its
	# own equivalent walk because GridRenderer doesn't see the gameplay node.
	var fleet: Array = GameState.players[GameState.current_player]["fleet"]
	var gate_open: bool = false
	for ship_v: Variant in fleet:
		var ship: ShipInstance = ship_v
		if ship.is_destroyed:
			continue
		var ship_cells: Array[Vector2i] = ship.get_occupied_cells()
		for sc: Vector2i in ship_cells:
			if probe_cells.has(sc):
				gate_open = true
				break
		if gate_open:
			break
	if not gate_open:
		return
	# Draw each probed cell's outline edges, skipping shared edges with adjacent
	# probe cells so a multi-cell region renders as one closed contour. Off-grid
	# neighbors are treated as not-in-set so the boundary closes along the edge
	# of the grid.
	for key: Variant in probe_cells.keys():
		var cell: Vector2i = key
		var x0: float = cell.x * CELL_SIZE
		var y0: float = cell.y * CELL_SIZE
		var x1: float = (cell.x + 1) * CELL_SIZE
		var y1: float = (cell.y + 1) * CELL_SIZE
		# Top edge: skip if neighbor above is also a probe cell
		if not probe_cells.has(cell + Vector2i(0, -1)):
			draw_line(Vector2(x0, y0), Vector2(x1, y0), COLOR_OPPONENT_PROBE_BOUNDARY, 2.0)
		# Right edge
		if not probe_cells.has(cell + Vector2i(1, 0)):
			draw_line(Vector2(x1, y0), Vector2(x1, y1), COLOR_OPPONENT_PROBE_BOUNDARY, 2.0)
		# Bottom edge
		if not probe_cells.has(cell + Vector2i(0, 1)):
			draw_line(Vector2(x1, y1), Vector2(x0, y1), COLOR_OPPONENT_PROBE_BOUNDARY, 2.0)
		# Left edge
		if not probe_cells.has(cell + Vector2i(-1, 0)):
			draw_line(Vector2(x0, y1), Vector2(x0, y0), COLOR_OPPONENT_PROBE_BOUNDARY, 2.0)


# --- Target Grid ---

func _draw_target_cells() -> void:
	var cell_records: Dictionary = GameState.players[GameState.current_player]["cell_records"]
	# I7-4: historical probe overlay. Cells previously inside an active probe
	# area (was_probed = true) keep a faint interior border once the probe expires
	# so the player can see where they've already looked. Cells with active
	# coverage skip this layer — the active fill below them takes precedence.
	for key: Variant in cell_records.keys():
		var cell: Vector2i = key
		var record: CellRecord = cell_records[cell]
		if record.was_probed and not record.has_probe:
			_draw_historical_probe_border(cell)
	# Draw probe illumination overlay on all actively probed cells
	for key: Variant in cell_records.keys():
		var cell: Vector2i = key
		var record: CellRecord = cell_records[cell]
		if record.has_probe:
			draw_rect(
				Rect2(cell.x * CELL_SIZE, cell.y * CELL_SIZE, CELL_SIZE, CELL_SIZE),
				COLOR_PROBE_FILL
			)
	# Collect fog ships once (dedupe) with their cells + probed state
	var collected_fogs: Array = []
	var fog_cells_list: Array = []
	var fog_probed_list: Array = []
	var seen_fog: Array = []
	for key: Variant in cell_records.keys():
		var cell: Vector2i = key
		var record: CellRecord = cell_records[cell]
		if record.ship != null and not seen_fog.has(record.ship):
			seen_fog.append(record.ship)
			var fog: FogShipRecord = record.ship
			var ship_cells: Array[Vector2i] = ShipDefinitions.get_ship_cells(fog.ship_type, fog.position, fog.facing)
			# Ship is active if ANY of its cells have an active probe
			var any_probed: bool = false
			for sc: Vector2i in ship_cells:
				if cell_records.has(sc):
					var sc_rec: CellRecord = cell_records[sc]
					if sc_rec.has_probe:
						any_probed = true
						break
			collected_fogs.append(fog)
			fog_cells_list.append(ship_cells)
			fog_probed_list.append(any_probed)
	# First: wreckage for destroyed fog ships (below everything else)
	for i in range(collected_fogs.size()):
		var fog: FogShipRecord = collected_fogs[i]
		var any_probed: bool = fog_probed_list[i]
		if fog.last_armor <= 0 and any_probed:
			_draw_wreckage_cells(fog_cells_list[i])
	# Next: blind hits (unchanged rule — suppressed on cells with an active probe)
	# Miss X markers drawn before blind hits so blind hits sit on top
	var current_turn_number: int = GameState.players[GameState.current_player]["turns_played"] + 1
	for key: Variant in cell_records.keys():
		var cell: Vector2i = key
		var record: CellRecord = cell_records[cell]
		if record.has_miss:
			_draw_miss_x(cell, record.miss_turn == current_turn_number)
	for key: Variant in cell_records.keys():
		var cell: Vector2i = key
		var record: CellRecord = cell_records[cell]
		if record.has_blind_hit and not record.has_probe:
			var full_hit: bool = record.hit_turn == 0 or record.hit_turn == current_turn_number
			_draw_blind_hit(cell, full_hit)
	# Finally: living fog ships + facing triangles on top. Cells with a miss
	# marker are subtracted from the ghost — a miss is the latest intel for
	# that one cell and supersedes the prior ghost rendering there.
	for i in range(collected_fogs.size()):
		var fog: FogShipRecord = collected_fogs[i]
		var any_probed: bool = fog_probed_list[i]
		if fog.last_armor <= 0 and any_probed:
			continue  # already drawn as wreckage
		var alpha: float = 1.0 if any_probed else 0.35
		var visible_cells: Array[Vector2i] = []
		for sc: Vector2i in fog_cells_list[i]:
			# Cell still belongs to the ghost only if its record points at this
			# fog ref. A miss or any other clear sets record.ship = null and
			# permanently removes that cell from the ghost — even if a later hit
			# clears has_miss on the same cell.
			if not cell_records.has(sc) or cell_records[sc].ship != fog:
				continue
			visible_cells.append(sc)
		_draw_ship_cells(
			visible_cells,
			SHIP_COLORS.get(fog.ship_type, Color.WHITE),
			alpha
		)
		if any_probed:
			var front_cell: Vector2i = _get_front_cell(fog.ship_type, fog.position, fog.facing)
			if cell_records.has(front_cell) and cell_records[front_cell].ship == fog:
				_draw_facing_triangle(front_cell, fog.facing)

# --- Ghost ship + selection overlays ---

func _draw_selected_highlight() -> void:
	if selected_ship == null or selected_ship.is_destroyed:
		return
	var cells: Array[Vector2i] = selected_ship.get_occupied_cells()
	for cell in cells:
		draw_rect(
			Rect2(cell.x * CELL_SIZE, cell.y * CELL_SIZE, CELL_SIZE, CELL_SIZE),
			COLOR_SELECTED_SHIP, false, 2.0
		)

func _draw_selected_enemy_highlight() -> void:
	if selected_enemy_fog == null:
		return
	# Check the fog record still has a valid position (ship_type must be known)
	var cells: Array[Vector2i] = ShipDefinitions.get_ship_cells(
		selected_enemy_fog.ship_type, selected_enemy_fog.position, selected_enemy_fog.facing)
	for cell in cells:
		draw_rect(
			Rect2(cell.x * CELL_SIZE, cell.y * CELL_SIZE, CELL_SIZE, CELL_SIZE),
			COLOR_SELECTED_SHIP, false, 2.0
		)

func _draw_ghost_ship() -> void:
	if not ghost_visible or ghost_cells.is_empty():
		return
	var color: Color = COLOR_GHOST_SHIP if ghost_valid else COLOR_GHOST_SHIP_INVALID
	for cell in ghost_cells:
		draw_rect(
			Rect2(cell.x * CELL_SIZE + 1, cell.y * CELL_SIZE + 1, CELL_SIZE - 2, CELL_SIZE - 2),
			color
		)
	# Draw facing arrow on ghost front cell
	if selected_ship != null:
		_draw_facing_triangle(_get_front_cell(selected_ship.ship_type, ghost_origin, ghost_facing), ghost_facing)

# --- Shared drawing helpers ---

func _draw_ship_cells(cells: Array[Vector2i], color: Color, alpha: float) -> void:
	var c := Color(color.r, color.g, color.b, alpha)
	for cell in cells:
		draw_rect(
			Rect2(cell.x * CELL_SIZE + 1, cell.y * CELL_SIZE + 1, CELL_SIZE - 2, CELL_SIZE - 2),
			c
		)

func _draw_historical_probe_border(cell: Vector2i) -> void:
	# Thin 1px border drawn inside the cell, leaving a 1px inset so it doesn't
	# fight the grid lines. Four draw_line calls form the rectangle.
	var x0: float = cell.x * CELL_SIZE + 1.0
	var y0: float = cell.y * CELL_SIZE + 1.0
	var x1: float = (cell.x + 1) * CELL_SIZE - 1.0
	var y1: float = (cell.y + 1) * CELL_SIZE - 1.0
	draw_line(Vector2(x0, y0), Vector2(x1, y0), COLOR_HISTORICAL_PROBE, 1.0)
	draw_line(Vector2(x1, y0), Vector2(x1, y1), COLOR_HISTORICAL_PROBE, 1.0)
	draw_line(Vector2(x1, y1), Vector2(x0, y1), COLOR_HISTORICAL_PROBE, 1.0)
	draw_line(Vector2(x0, y1), Vector2(x0, y0), COLOR_HISTORICAL_PROBE, 1.0)

func _draw_wreckage_cells(cells: Array[Vector2i]) -> void:
	for cell in cells:
		var rx: float = cell.x * CELL_SIZE + 2
		var ry: float = cell.y * CELL_SIZE + 2
		var rw: float = CELL_SIZE - 4
		var rh: float = CELL_SIZE - 4
		draw_rect(Rect2(rx, ry, rw, rh), COLOR_WRECKAGE)
		draw_line(Vector2(rx, ry), Vector2(rx + rw, ry + rh), COLOR_WRECKAGE_X, 2.0)
		draw_line(Vector2(rx + rw, ry), Vector2(rx, ry + rh), COLOR_WRECKAGE_X, 2.0)

func _get_front_cell(ship_type: String, origin: Vector2i, facing: int) -> Vector2i:
	var squares: int = ShipDefinitions.SHIPS[ship_type]["squares"]
	var dir: Vector2i
	match facing:
		0: dir = Vector2i(0, -1)
		1: dir = Vector2i(1, 0)
		2: dir = Vector2i(0, 1)
		3: dir = Vector2i(-1, 0)
		_: dir = Vector2i(0, -1)
	return origin + dir * (squares - 1)

func _draw_facing_triangle(cell: Vector2i, facing: int) -> void:
	var cx: float = cell.x * CELL_SIZE + CELL_SIZE * 0.5
	var cy: float = cell.y * CELL_SIZE + CELL_SIZE * 0.5
	var h: float = CELL_SIZE * 0.35  # half-length along facing axis (elongated)
	var w: float = CELL_SIZE * 0.2   # half-width perpendicular to facing
	var tip: Vector2
	var base_l: Vector2
	var base_r: Vector2
	match facing:
		0:  # up
			tip = Vector2(cx, cy - h)
			base_l = Vector2(cx - w, cy + h)
			base_r = Vector2(cx + w, cy + h)
		1:  # right
			tip = Vector2(cx + h, cy)
			base_l = Vector2(cx - h, cy - w)
			base_r = Vector2(cx - h, cy + w)
		2:  # down
			tip = Vector2(cx, cy + h)
			base_l = Vector2(cx + w, cy - h)
			base_r = Vector2(cx - w, cy - h)
		3:  # left
			tip = Vector2(cx - h, cy)
			base_l = Vector2(cx + h, cy + w)
			base_r = Vector2(cx + h, cy - w)
		_:
			tip = Vector2(cx, cy - h)
			base_l = Vector2(cx - w, cy + h)
			base_r = Vector2(cx + w, cy + h)
	draw_colored_polygon(PackedVector2Array([tip, base_l, base_r]), COLOR_FACING)

func _draw_blind_hit(cell: Vector2i, full_intensity: bool) -> void:
	var cx: float = cell.x * CELL_SIZE + CELL_SIZE * 0.5
	var cy: float = cell.y * CELL_SIZE + CELL_SIZE * 0.5
	var color: Color = COLOR_HIT_FULL if full_intensity else COLOR_HIT_FADED
	draw_circle(Vector2(cx, cy), CELL_SIZE * 0.28, color)

func _draw_miss_x(cell: Vector2i, full_intensity: bool) -> void:
	var margin: float = CELL_SIZE * 0.25
	var x0: float = cell.x * CELL_SIZE + margin
	var y0: float = cell.y * CELL_SIZE + margin
	var x1: float = (cell.x + 1) * CELL_SIZE - margin
	var y1: float = (cell.y + 1) * CELL_SIZE - margin
	var color: Color = COLOR_MISS_FULL if full_intensity else COLOR_MISS_FADED
	draw_line(Vector2(x0, y0), Vector2(x1, y1), color, 2.0)
	draw_line(Vector2(x1, y0), Vector2(x0, y1), color, 2.0)

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

func set_ghost_ship(cells: Array[Vector2i], origin: Vector2i, facing: int, valid: bool) -> void:
	ghost_cells = cells
	ghost_origin = origin
	ghost_facing = facing
	ghost_valid = valid
	ghost_visible = true
	queue_redraw()

func clear_ghost_ship() -> void:
	ghost_cells = []
	ghost_visible = false
	queue_redraw()

func set_selected_ship(ship: ShipInstance) -> void:
	selected_ship = ship
	queue_redraw()

func clear_selected_ship() -> void:
	selected_ship = null
	queue_redraw()

func set_selected_enemy(fog: FogShipRecord) -> void:
	selected_enemy_fog = fog
	queue_redraw()

func clear_selected_enemy() -> void:
	selected_enemy_fog = null
	queue_redraw()

func refresh() -> void:
	queue_redraw()
