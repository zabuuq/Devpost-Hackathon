extends Node
## Scripted playthrough that drives GameState directly and captures PNGs at 13
## predefined moments from the itch.io screenshot brief. Triggered by passing
## `--screenshot` as a user arg:
##
##     godot --path . -- --screenshot
##
## Saves PNGs to res://assets/screenshots/. Does nothing unless the CLI flag
## is present; main.gd routes around the normal splash flow when it sees it.
##
## This file is opt-in and safe to delete. To remove the feature entirely:
##   1. Delete this file.
##   2. Revert the `--screenshot` check in scripts/main.gd.

const OUT_DIR: String = "res://assets/screenshots"
const CELL_SIZE: int = 32
const GRID_COLS: int = 80
const GRID_ROWS: int = 20

# Fleet positions match the screenshot brief. The brief describes ship bodies
# extending "downward (south)" from the origin, so we use facing=2 (down) in
# the code's convention (0=up, 1=right, 2=down, 3=left).
const P1_POSITIONS: Array = [
	{"type": "battleship", "pos": Vector2i(10, 9)},
	{"type": "probe_ship", "pos": Vector2i(20, 9)},
	{"type": "destroyer",  "pos": Vector2i(30, 9)},
	{"type": "destroyer",  "pos": Vector2i(40, 9)},
	{"type": "cruiser",    "pos": Vector2i(50, 9)},
]
const P2_POSITIONS: Array = [
	{"type": "battleship", "pos": Vector2i(70, 9)},
	{"type": "probe_ship", "pos": Vector2i(60, 9)},
	{"type": "destroyer",  "pos": Vector2i(55, 9)},
	{"type": "destroyer",  "pos": Vector2i(65, 9)},
	{"type": "cruiser",    "pos": Vector2i(75, 9)},
]
const SHIP_FACING: int = 2  # down

# Shot 04 uses a scattered layout with varied facings and a tighter camera, so
# the ships look like a real commander's spread rather than a parade-ground row.
# Not every ship sits inside the visible window; that's intentional (brief asks
# for >50% visible, not all). Facings: 0=up, 1=right, 2=down, 3=left.
const SHOT_04_POSITIONS: Array = [
	{"type": "battleship", "pos": Vector2i(28, 4),  "facing": 1},
	{"type": "probe_ship", "pos": Vector2i(50, 15), "facing": 0},
	{"type": "destroyer",  "pos": Vector2i(38, 2),  "facing": 2},
	{"type": "destroyer",  "pos": Vector2i(70, 10), "facing": 3},
	{"type": "cruiser",    "pos": Vector2i(25, 17), "facing": 1},
]

# Shot 05b needs a tight cluster of ships with varied facings inside the
# 19-cell-wide crop window. These are packed into cols 25-36, rows 7-13 so the
# crop at cam_center (30, 10) catches all five. Shot 05a reuses this fleet for
# its grid-strip context but crops higher up, so only the battleship row shows.
const SHOT_05B_POSITIONS: Array = [
	{"type": "battleship", "pos": Vector2i(25, 7),  "facing": 1},  # right
	{"type": "destroyer",  "pos": Vector2i(32, 7),  "facing": 2},  # down
	{"type": "probe_ship", "pos": Vector2i(30, 10), "facing": 2},  # down
	{"type": "destroyer",  "pos": Vector2i(36, 8),  "facing": 3},  # left
	{"type": "cruiser",    "pos": Vector2i(27, 12), "facing": 1},  # right
]


func _ready() -> void:
	print("[screenshot_runner] starting")
	_ensure_out_dir()
	# Give the window one frame to finish resizing before the first capture.
	await _wait_frames(2)
	await _run_all()
	print("[screenshot_runner] complete")
	get_tree().quit()


func _run_all() -> void:
	await _shot_01_welcome()
	await _shot_02_main_menu()
	await _shot_03_fleet_placement_empty()
	await _shot_04_fleet_placement_full()
	await _shot_05_command_grid()
	await _shot_05a_grid_tabs()
	await _shot_05b_command_ships()
	await _shot_05c_target_grid_mixed()
	await _shot_06_probe_aiming()
	await _shot_07_probe_revealed()
	await _shot_08_ship_panel_sliders()
	await _shot_08a_ship_panel_tight()
	await _shot_09_move_preview()
	await _shot_10_active_probe_enemy_panel()
	await _shot_11_probe_closeup()
	await _shot_12_battle_log_detail()
	await _shot_13_command_overview()


# ---------------------------------------------------------------------------
# Scene / capture helpers
# ---------------------------------------------------------------------------

func _change_scene(path: String) -> void:
	var err: int = get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("[screenshot_runner] change_scene_to_file(%s) failed: %d" % [path, err])
		return
	# Wait for the new scene to enter the tree and _ready to fire, plus a few
	# extra frames so SubViewports have rendered fresh content.
	await _wait_frames(6)


func _wait_frames(count: int) -> void:
	for i in range(count):
		await get_tree().process_frame


func _capture(filename: String) -> void:
	# Let the frame fully render after any state change.
	await _wait_frames(3)
	await RenderingServer.frame_post_draw
	var tex: ViewportTexture = get_viewport().get_texture()
	if tex == null:
		push_error("[screenshot_runner] viewport texture null for %s" % filename)
		return
	var img: Image = tex.get_image()
	if img == null:
		push_error("[screenshot_runner] image null for %s" % filename)
		return
	var out_path: String = OUT_DIR.path_join(filename)
	var err: int = img.save_png(out_path)
	if err != OK:
		push_error("[screenshot_runner] save_png failed for %s: %d" % [out_path, err])
	else:
		print("[screenshot_runner] captured %s" % filename)


# Crop-capture: same as _capture() but saves only the given rect of the
# viewport image. Used for the page-3 triptych where each image is a focused
# slice of a larger scene rather than the whole screen.
func _capture_cropped(filename: String, rect: Rect2i) -> void:
	await _wait_frames(3)
	await RenderingServer.frame_post_draw
	var tex: ViewportTexture = get_viewport().get_texture()
	if tex == null:
		push_error("[screenshot_runner] viewport texture null for %s" % filename)
		return
	var img: Image = tex.get_image()
	if img == null:
		push_error("[screenshot_runner] image null for %s" % filename)
		return
	# Clamp rect to image bounds so a slightly-too-big crop doesn't fail.
	var clamped := Rect2i(rect)
	clamped.position.x = clampi(clamped.position.x, 0, img.get_width())
	clamped.position.y = clampi(clamped.position.y, 0, img.get_height())
	clamped.size.x = clampi(clamped.size.x, 1, img.get_width() - clamped.position.x)
	clamped.size.y = clampi(clamped.size.y, 1, img.get_height() - clamped.position.y)
	var cropped: Image = img.get_region(clamped)
	var out_path: String = OUT_DIR.path_join(filename)
	var err: int = cropped.save_png(out_path)
	if err != OK:
		push_error("[screenshot_runner] save_png failed for %s: %d" % [out_path, err])
	else:
		print("[screenshot_runner] captured %s (%dx%d)" % [
			filename, clamped.size.x, clamped.size.y])


func _ensure_out_dir() -> void:
	var abs_path: String = ProjectSettings.globalize_path(OUT_DIR)
	if not DirAccess.dir_exists_absolute(abs_path):
		var err: int = DirAccess.make_dir_recursive_absolute(abs_path)
		if err != OK:
			push_error("[screenshot_runner] mkdir failed for %s: %d" % [abs_path, err])


# Fit a gameplay camera to the full grid. Neither gameplay.gd nor
# fleet_placement.gd calls their _fit_camera helper on load, so the default
# camera view shows the grid tiny-and-centered. For screenshots we want the
# grid filling the viewport.
func _fit_grid_camera(cam: Camera2D, vp: SubViewport) -> void:
	if cam == null or vp == null:
		return
	var vp_size: Vector2 = Vector2(vp.size)
	if vp_size.x <= 0.0 or vp_size.y <= 0.0:
		return
	var grid_w: float = float(GRID_COLS) * float(CELL_SIZE)
	var grid_h: float = float(GRID_ROWS) * float(CELL_SIZE)
	var zx: float = vp_size.x / grid_w
	var zy: float = vp_size.y / grid_h
	var zoom: float = min(zx, zy)
	cam.zoom = Vector2(zoom, zoom)
	cam.position = Vector2(grid_w / 2.0, grid_h / 2.0)


func _fit_gameplay_cameras(gp: Node) -> void:
	var cmd_cam: Camera2D = gp.get_node_or_null("MainLayout/GridArea/CommandViewport/SubViewport/GridNode/Camera2D")
	var cmd_vp: SubViewport = gp.get_node_or_null("MainLayout/GridArea/CommandViewport/SubViewport")
	var tgt_cam: Camera2D = gp.get_node_or_null("MainLayout/GridArea/TargetViewport/SubViewport/GridNode/Camera2D")
	var tgt_vp: SubViewport = gp.get_node_or_null("MainLayout/GridArea/TargetViewport/SubViewport")
	_fit_grid_camera(cmd_cam, cmd_vp)
	_fit_grid_camera(tgt_cam, tgt_vp)
	var cmd_renderer: Node2D = gp.get_node_or_null("MainLayout/GridArea/CommandViewport/SubViewport/GridNode")
	var tgt_renderer: Node2D = gp.get_node_or_null("MainLayout/GridArea/TargetViewport/SubViewport/GridNode")
	if cmd_renderer != null:
		cmd_renderer.queue_redraw()
	if tgt_renderer != null:
		tgt_renderer.queue_redraw()


func _ship_center_cell(stype: String, origin: Vector2i, facing: int) -> Vector2i:
	var cells: Array[Vector2i] = ShipDefinitions.get_ship_cells(stype, origin, facing)
	if cells.is_empty():
		return origin
	return cells[cells.size() / 2]


# Computes the main-window pixel position of a grid cell's center, walking the
# Camera2D → SubViewport → SubViewportContainer transform chain. Used to place
# overlay sprites (e.g., the cursor in shot 04) in screen space.
func _screen_pos_of_grid_cell(scene: Node, cell: Vector2i) -> Vector2:
	var cam: Camera2D = scene.get_node_or_null(
		"HSplitContainer/GridViewport/SubViewport/GridNode/Camera2D")
	var subvp: SubViewport = scene.get_node_or_null(
		"HSplitContainer/GridViewport/SubViewport")
	var container: Control = scene.get_node_or_null("HSplitContainer/GridViewport")
	if cam == null or subvp == null or container == null:
		return Vector2.ZERO
	var world: Vector2 = Vector2(
		cell.x * CELL_SIZE + CELL_SIZE / 2.0,
		cell.y * CELL_SIZE + CELL_SIZE / 2.0)
	var vp_point: Vector2 = (world - cam.position) * cam.zoom + Vector2(subvp.size) * 0.5
	return container.global_position + vp_point


# Adds a mouse-cursor sprite (white fill, black outline) to the scene at the
# given screen position. The tip of the arrow lands at `screen_pos`.
func _add_cursor_overlay(scene: Node, screen_pos: Vector2) -> void:
	var pts := PackedVector2Array([
		Vector2(0, 0),
		Vector2(0, 36),
		Vector2(9, 28),
		Vector2(14, 40),
		Vector2(18, 38),
		Vector2(13, 26),
		Vector2(24, 26),
	])
	var fill := Polygon2D.new()
	fill.polygon = pts
	fill.color = Color.WHITE
	fill.position = screen_pos
	var outline_pts := pts.duplicate()
	outline_pts.append(pts[0])
	var outline := Line2D.new()
	outline.points = outline_pts
	outline.width = 1.5
	outline.default_color = Color.BLACK
	outline.joint_mode = Line2D.LINE_JOINT_ROUND
	fill.add_child(outline)
	scene.add_child(fill)


func _fit_placement_camera(scene: Node) -> void:
	var cam: Camera2D = scene.get_node_or_null("HSplitContainer/GridViewport/SubViewport/GridNode/Camera2D")
	var vp: SubViewport = scene.get_node_or_null("HSplitContainer/GridViewport/SubViewport")
	_fit_grid_camera(cam, vp)
	var grid_node: Node2D = scene.get_node_or_null("HSplitContainer/GridViewport/SubViewport/GridNode")
	if grid_node != null:
		grid_node.queue_redraw()


# Zooms the placement camera so the grid's 20 rows fill the viewport vertically.
# The 80-column width then overflows, giving a tight horizontal slice rather
# than the letterboxed full-grid view. Used by shot 04 so ship sprites are
# legible in the tutorial overlay.
func _zoom_in_placement_camera(scene: Node) -> void:
	var cam: Camera2D = scene.get_node_or_null("HSplitContainer/GridViewport/SubViewport/GridNode/Camera2D")
	var vp: SubViewport = scene.get_node_or_null("HSplitContainer/GridViewport/SubViewport")
	if cam == null or vp == null:
		return
	var vp_size: Vector2 = Vector2(vp.size)
	if vp_size.x <= 0.0 or vp_size.y <= 0.0:
		return
	var grid_w: float = float(GRID_COLS) * float(CELL_SIZE)
	var grid_h: float = float(GRID_ROWS) * float(CELL_SIZE)
	var zoom: float = vp_size.y / grid_h
	cam.zoom = Vector2(zoom, zoom)
	cam.position = Vector2(grid_w / 2.0, grid_h / 2.0)
	var grid_node: Node2D = scene.get_node_or_null("HSplitContainer/GridViewport/SubViewport/GridNode")
	if grid_node != null:
		grid_node.queue_redraw()


# Zooms the camera so the grid's 20 rows fill the SubViewportContainer
# vertically and centered, killing the letterbox bands that
# _fit_gameplay_cameras' fit-whole-grid zoom leaves above and below the 4:1
# grid in a ~1.64:1 container. The horizontal center is the caller's choice
# (`center_col`) so different shots can frame different slices of the 80-col
# grid. Vertical center is always grid_h/2 — anything else re-introduces a
# top or bottom gray band. The SubViewport doesn't need resizing; with
# stretch=true, the container already syncs the viewport size to its own.
func _gameplay_fill_view(
		gp: Node,
		container_path: String,
		subvp_path: String,
		cam_path: String,
		center_col: int) -> void:
	var container: SubViewportContainer = gp.get_node_or_null(container_path)
	var subvp: SubViewport = gp.get_node_or_null(subvp_path)
	var cam: Camera2D = gp.get_node_or_null(cam_path)
	if container == null or subvp == null or cam == null:
		return
	var cs: Vector2 = container.size
	if cs.x <= 0.0 or cs.y <= 0.0:
		return
	var grid_h: float = float(GRID_ROWS) * float(CELL_SIZE)
	var z: float = cs.y / grid_h
	cam.zoom = Vector2(z, z)
	cam.position = Vector2(
		float(center_col) * float(CELL_SIZE) + float(CELL_SIZE) / 2.0,
		grid_h / 2.0)
	var renderer: Node2D = subvp.get_node_or_null("GridNode")
	if renderer != null:
		renderer.queue_redraw()


# ---------------------------------------------------------------------------
# State builders
# ---------------------------------------------------------------------------

func _reset_state() -> void:
	GameState.reset()


func _make_ship(ship_type: String, pos: Vector2i, facing: int) -> ShipInstance:
	var s: ShipInstance = ShipInstance.create(ship_type)
	s.position = pos
	s.facing = facing
	return s


func _build_both_fleets() -> void:
	var p1_fleet: Array = []
	for entry in P1_POSITIONS:
		p1_fleet.append(_make_ship(entry["type"], entry["pos"], SHIP_FACING))
	var p2_fleet: Array = []
	for entry in P2_POSITIONS:
		p2_fleet.append(_make_ship(entry["type"], entry["pos"], SHIP_FACING))
	GameState.players[0]["fleet"] = p1_fleet
	GameState.players[1]["fleet"] = p2_fleet


func _p1_ship(type_name: String, index: int = 0) -> ShipInstance:
	# Returns the Nth ship of the given type from the P1 fleet (0-indexed,
	# used to disambiguate the two destroyers).
	var n: int = 0
	for ship in GameState.players[0]["fleet"]:
		if ship.ship_type == type_name:
			if n == index:
				return ship
			n += 1
	return null


# ---------------------------------------------------------------------------
# Shots
# ---------------------------------------------------------------------------

func _shot_01_welcome() -> void:
	_reset_state()
	await _change_scene("res://scenes/splash.tscn")
	await _capture("01_welcome.png")


func _shot_02_main_menu() -> void:
	await _change_scene("res://scenes/main_menu.tscn")
	await _capture("02_main_menu.png")


func _shot_03_fleet_placement_empty() -> void:
	_reset_state()
	GameState.current_player = 0
	await _change_scene("res://scenes/fleet_placement.tscn")
	_fit_placement_camera(get_tree().current_scene)
	await _capture("03_fleet_placement_empty.png")


func _shot_04_fleet_placement_full() -> void:
	# Stay on the fleet_placement scene from shot 03. Four of five ships are
	# placed; the remaining one (index GHOST_IDX) is rendered as an authentic
	# green ghost preview, simulating a commander mid-placement. A synthetic
	# mouse-cursor sprite is laid over the ghost's center cell so the shot
	# reads as "hovering to place" even in a headless capture where the OS
	# cursor is invisible.
	var scene: Node = get_tree().current_scene
	if scene == null:
		push_error("[screenshot_runner] shot 04: current_scene is null")
		return
	var ghost_idx: int = 2  # destroyer at (38, 2) facing down
	var placed: Dictionary = {}
	for i in range(SHOT_04_POSITIONS.size()):
		if i == ghost_idx:
			continue
		var entry: Dictionary = SHOT_04_POSITIONS[i]
		placed[i] = _make_ship(entry["type"], entry["pos"], entry["facing"])
	scene.set("placed_ships", placed)
	# Disable _process so fleet_placement.gd doesn't overwrite ghost_position
	# with whatever cell the headless mouse happens to hover over.
	scene.set_process(false)
	var ghost_entry: Dictionary = SHOT_04_POSITIONS[ghost_idx]
	scene.set("selected_ship_idx", ghost_idx)
	scene.set("ghost_position", ghost_entry["pos"])
	scene.set("ghost_facing", ghost_entry["facing"])
	scene.set("ghost_valid", true)
	var done_btn: Button = scene.get_node_or_null("HSplitContainer/LeftPanel/DoneButton")
	if done_btn != null:
		done_btn.disabled = true  # one ship still unplaced
	# Tint placed-ship buttons green the way the real placement flow does;
	# leave the ghost ship's button un-tinted (it's the one we're "placing").
	var ship_buttons: Variant = scene.get("ship_buttons")
	if ship_buttons != null:
		for i in range(ship_buttons.size()):
			if i != ghost_idx:
				ship_buttons[i].modulate = Color(0.4, 1.0, 0.4)
	_zoom_in_placement_camera(scene)
	# Lay a cursor sprite over the center cell of the ghost ship. Coordinates
	# are computed from the live camera transform so the overlay tracks any
	# future camera or viewport size changes.
	var center_cell: Vector2i = _ship_center_cell(
		ghost_entry["type"], ghost_entry["pos"], ghost_entry["facing"])
	var cursor_screen_pos: Vector2 = _screen_pos_of_grid_cell(scene, center_cell)
	_add_cursor_overlay(scene, cursor_screen_pos)
	var grid_node: Node2D = scene.get_node_or_null(
		"HSplitContainer/GridViewport/SubViewport/GridNode")
	if grid_node != null:
		grid_node.queue_redraw()
	await _capture("04_fleet_placement_full.png")


func _shot_05_command_grid() -> void:
	_reset_state()
	_build_both_fleets()
	GameState.current_player = 0
	GameState.turn_number = 1
	await _change_scene("res://scenes/gameplay.tscn")
	_fit_gameplay_cameras(get_tree().current_scene)
	await _capture("05_command_grid.png")


# Page-3 triptych, image 1: top tab row (Command Grid / Target Grid / End Turn)
# with zoomed-in grid visible directly below — no letterbox gray. Crop is
# 800x300 (2.67:1, matches the overlay's 400x150 display slot at 2x). Reuses
# the state from shot 05 (fleet built, gameplay loaded, command grid active).
func _shot_05a_grid_tabs() -> void:
	var gp: Node = get_tree().current_scene
	if gp == null:
		push_error("[screenshot_runner] shot 05a: current_scene is null")
		return
	# Rebuild P1 with the SHOT_05B positions; 05b keeps the same fleet so we
	# don't toggle it twice. At cam center col 30 the crop window catches the
	# top of the battleship's row (y=7) just below the tab strip. Everything
	# below that is empty grid, which is fine — this shot's subject is the
	# tab row itself.
	var p1_fleet: Array = []
	for entry in SHOT_05B_POSITIONS:
		p1_fleet.append(_make_ship(entry["type"], entry["pos"], entry["facing"]))
	GameState.players[0]["fleet"] = p1_fleet
	_gameplay_fill_view(
		gp,
		"MainLayout/GridArea/CommandViewport",
		"MainLayout/GridArea/CommandViewport/SubViewport",
		"MainLayout/GridArea/CommandViewport/SubViewport/GridNode/Camera2D",
		30)
	var renderer: Node2D = gp.get_node_or_null(
		"MainLayout/GridArea/CommandViewport/SubViewport/GridNode")
	if renderer != null:
		renderer.queue_redraw()
	await _capture_cropped("05a_grid_tabs.png", Rect2i(800, 0, 800, 300))


# Page-3 triptych, image 2: a few command-grid ships with varied facings
# visible, cropped to the grid area (no left panel, no top bar). Rebuilds the
# P1 fleet from SHOT_04_POSITIONS so facings aren't all the same. 800x340 crop
# (2.35:1, matches the overlay's 400x170 display slot at 2x).
func _shot_05b_command_ships() -> void:
	var gp: Node = get_tree().current_scene
	if gp == null:
		push_error("[screenshot_runner] shot 05b: current_scene is null")
		return
	# P1 fleet is already in the SHOT_05B layout from shot 05a. Keep the cam
	# center at col 30 (same as 05a); the only change vs 05a is the crop rect,
	# which now samples the middle of the grid where the ships cluster.
	_gameplay_fill_view(
		gp,
		"MainLayout/GridArea/CommandViewport",
		"MainLayout/GridArea/CommandViewport/SubViewport",
		"MainLayout/GridArea/CommandViewport/SubViewport/GridNode/Camera2D",
		30)
	var renderer: Node2D = gp.get_node_or_null(
		"MainLayout/GridArea/CommandViewport/SubViewport/GridNode")
	if renderer != null:
		renderer.queue_redraw()
	# Crop centered on the SHOT_05B ship cluster. With window 1600x900, GridArea
	# starts at (200, 48) and the camera fills it at zoom ~1.33; the cluster's
	# screen-space bounds are roughly (666..1177) x (346..644), so an 800x340
	# crop starting at (521, 325) puts the ships in the middle of the image with
	# ~145px margin on each side and ~21px top/bottom.
	await _capture_cropped("05b_command_ships.png", Rect2i(521, 325, 800, 340))


# Page-3 triptych, image 3: target grid showing (a) a ship visible inside an
# active probe, (b) a ghost marker from an expired probe, (c) a blind-hit cell.
# All three rendered via CellRecords injected into P1's fog state — the runner
# doesn't walk real turns.
func _shot_05c_target_grid_mixed() -> void:
	var gp: Node = get_tree().current_scene
	if gp == null:
		push_error("[screenshot_runner] shot 05c: current_scene is null")
		return
	var cell_records: Dictionary = GameState.players[0]["cell_records"]
	cell_records.clear()
	# Active probe: 6x6 centered on the P2 probe ship at (60, 9-12). The ship
	# sits inside the probe area so each of its cells gets a fog record that
	# renders in full detail on the target grid.
	var probe_ship_p2: ShipInstance = GameState.players[1]["fleet"][1]
	var probe_fog: FogShipRecord = FogShipRecord.from_ship(probe_ship_p2)
	var probe_ship_cells: Array[Vector2i] = ShipDefinitions.get_ship_cells(
		probe_ship_p2.ship_type, probe_ship_p2.position, probe_ship_p2.facing)
	var probe_center := Vector2i(60, 10)
	var half: int = 3
	for y in range(probe_center.y - half, probe_center.y - half + 6):
		for x in range(probe_center.x - half, probe_center.x - half + 6):
			if x < 0 or x >= GRID_COLS or y < 0 or y >= GRID_ROWS:
				continue
			var cell := Vector2i(x, y)
			var fog: FogShipRecord = probe_fog if probe_ship_cells.has(cell) else null
			cell_records[cell] = CellRecord.make_probe(fog, 2)
	# Ghost marker: represent the P2 destroyer at (55, 9) as last-seen intel.
	# make_ship_ghost produces a CellRecord with has_probe=false + a ship fog
	# record — the classic "we saw this here once" appearance.
	var destroyer_p2: ShipInstance = GameState.players[1]["fleet"][2]
	var ghost_fog: FogShipRecord = FogShipRecord.from_ship(destroyer_p2)
	var ghost_cells: Array[Vector2i] = ShipDefinitions.get_ship_cells(
		destroyer_p2.ship_type, destroyer_p2.position, destroyer_p2.facing)
	for cell in ghost_cells:
		cell_records[cell] = CellRecord.make_ship_ghost(ghost_fog)
	# Blind hit: a single cell between the two ships, outside the probe area.
	cell_records[Vector2i(68, 10)] = CellRecord.make_blind_hit()
	# Switch to target grid and frame all three features.
	gp.call("_switch_grid", 1)  # ActiveGrid.TARGET
	_gameplay_fill_view(
		gp,
		"MainLayout/GridArea/TargetViewport",
		"MainLayout/GridArea/TargetViewport/SubViewport",
		"MainLayout/GridArea/TargetViewport/SubViewport/GridNode/Camera2D",
		62)
	var target_renderer: Node2D = gp.get_node_or_null(
		"MainLayout/GridArea/TargetViewport/SubViewport/GridNode")
	if target_renderer != null:
		target_renderer.queue_redraw()
	# Crop centered on the probe area. Probe spans window x (667..922) and
	# y (346..602) at cam center_col=62; an 800x340 crop starting at (394, 304)
	# puts the probe near the image center without clipping the ghost (col 55,
	# window x~582) or the blind hit (col 68, window x~1178).
	await _capture_cropped("05c_target_grid_mixed.png", Rect2i(394, 304, 800, 340))
	# Restore clean state so downstream shots (06+) see the original fleet
	# layout + empty fog. 05b/05c both mutated live state; a scene reload is
	# the simplest way to hand shot 06 the same conditions it would have had
	# if 05a/05b/05c didn't exist.
	_reset_state()
	_build_both_fleets()
	GameState.current_player = 0
	GameState.turn_number = 1
	await _change_scene("res://scenes/gameplay.tscn")
	_fit_gameplay_cameras(get_tree().current_scene)


func _shot_06_probe_aiming() -> void:
	# Stay on the gameplay scene. Select probe ship, enter probe targeting,
	# and position the highlight over cell (70, 11) by setting mouse_world_pos.
	var gp: Node = get_tree().current_scene
	if gp == null:
		push_error("[screenshot_runner] shot 06: current_scene is null")
		return
	var probe_ship: ShipInstance = _p1_ship("probe_ship")
	if probe_ship == null:
		push_error("[screenshot_runner] shot 06: probe_ship not found")
		return
	gp.call("_select_ship", probe_ship)
	gp.call("_enter_targeting", "probe", probe_ship)
	var target_renderer: Node2D = gp.get_node("MainLayout/GridArea/TargetViewport/SubViewport/GridNode")
	var target_world: Vector2 = Vector2(70 * CELL_SIZE + CELL_SIZE / 2.0, 11 * CELL_SIZE + CELL_SIZE / 2.0)
	target_renderer.set("mouse_world_pos", target_world)
	target_renderer.queue_redraw()
	await _capture("06_probe_aiming.png")


func _shot_07_probe_revealed() -> void:
	# Fire the probe, cancel targeting, and stay on the target grid so the
	# resulting illumination + revealed battleship are in frame.
	var gp: Node = get_tree().current_scene
	if gp == null:
		return
	# Use _execute_targeting_action (not resolver.resolve_probe) so the battle
	# log gets the entry and SFX fires — matches the real UI flow. That method
	# auto-switches back to the command grid, so we flip to target grid after.
	gp.call("_execute_targeting_action", Vector2i(70, 11))
	gp.call("_switch_grid", 1)  # ActiveGrid.TARGET
	# Brief wants the battle log visible here, showing the probe entry.
	# _select_ship() in shot 06 auto-switched to the ship panel tab; flip back.
	gp.call("_show_left_tab", "battle_log")
	var target_renderer: Node2D = gp.get_node("MainLayout/GridArea/TargetViewport/SubViewport/GridNode")
	target_renderer.queue_redraw()
	var command_renderer: Node2D = gp.get_node("MainLayout/GridArea/CommandViewport/SubViewport/GridNode")
	command_renderer.queue_redraw()
	await _capture("07_probe_revealed.png")


func _shot_08_ship_panel_sliders() -> void:
	# Switch to command grid, select the battleship, bump its slider settings,
	# and show the ship panel tab on the left.
	var gp: Node = get_tree().current_scene
	if gp == null:
		return
	gp.call("_switch_grid", 0)  # ActiveGrid.COMMAND
	var battleship: ShipInstance = _p1_ship("battleship")
	if battleship == null:
		return
	battleship.laser_power_setting = 250
	battleship.shield_regen_setting = 100
	gp.call("_select_ship", battleship)
	gp.call("_show_left_tab", "ship_panel")
	# Re-run show_ship so the slider widgets reflect the settings we just set.
	var ship_panel: Variant = gp.get("ship_panel")
	if ship_panel != null:
		ship_panel.call("show_ship", battleship)
	await _capture("08_ship_panel_sliders.png")


func _shot_08a_ship_panel_tight() -> void:
	# Reuses shot 08's state (battleship selected, sliders set, Ship Panel tab
	# active) and crops to the LeftPanel region for the How to Play "Ship Panel"
	# page. The crop rect is tuned to the 1600x900 viewport: x=0..200 matches
	# the LeftPanel's width exactly so no grid pixels bleed in on the right;
	# y=40..540 skips the top bar and captures the panel content down through
	# the action buttons.
	var gp: Node = get_tree().current_scene
	if gp == null:
		return
	gp.call("_show_left_tab", "ship_panel")
	var ship_panel: Variant = gp.get("ship_panel")
	if ship_panel != null:
		var battleship: ShipInstance = _p1_ship("battleship")
		if battleship != null:
			ship_panel.call("show_ship", battleship)
	# Workaround for the "empty-state label persists when ship selected" bug
	# (see docs/backlog.md). The ShipPanelEmpty label in gameplay.tscn stays
	# visible above the populated panel whenever a ship is active. Hide it
	# for this capture only; restore afterwards so subsequent shots see the
	# original tree state.
	var empty_label: CanvasItem = gp.get_node_or_null(
		"MainLayout/LeftPanel/ShipPanelContainer/ShipPanelEmpty") as CanvasItem
	var was_visible: bool = true
	if empty_label != null:
		was_visible = empty_label.visible
		empty_label.visible = false
	await _capture_cropped("08a_ship_panel_tight.png", Rect2i(0, 40, 200, 500))
	if empty_label != null:
		empty_label.visible = was_visible


func _shot_09_move_preview() -> void:
	# Rotate the cruiser to face right, enter move preview, and set the ghost to
	# two squares right + one square down with the same facing. Zooms the command
	# camera in on the pair so both hulls read large in the tutorial overlay.
	var gp: Node = get_tree().current_scene
	if gp == null:
		return
	gp.call("_deselect_ship")
	var cruiser: ShipInstance = _p1_ship("cruiser")
	if cruiser == null:
		return
	cruiser.facing = 1  # right (0=up, 1=right, 2=down, 3=left)
	gp.call("_select_ship", cruiser)
	gp.call("_enter_move_preview", cruiser)
	var origin: Vector2i = cruiser.position
	gp.set("move_preview_position", origin + Vector2i(2, 1))
	gp.set("move_preview_new_facing", 1)
	gp.call("_update_move_preview")
	# Zoom in on the cruiser + ghost pair. Center lands between the real hull
	# (origin.x..origin.x+1, origin.y) and the ghost (origin.x+2..origin.x+3,
	# origin.y+1), i.e. cell (origin.x + 2, origin.y + 0.5) in world coords.
	var cam: Camera2D = gp.get_node(
		"MainLayout/GridArea/CommandViewport/SubViewport/GridNode/Camera2D")
	cam.zoom = Vector2(2.5, 2.5)
	cam.position = Vector2(
		float(origin.x + 2) * float(CELL_SIZE) + float(CELL_SIZE) / 2.0,
		(float(origin.y) + 1.0) * float(CELL_SIZE))
	var command_renderer: Node2D = gp.get_node(
		"MainLayout/GridArea/CommandViewport/SubViewport/GridNode")
	command_renderer.queue_redraw()
	# Crop to just the grid slice around the pair. With the 1600x900 window,
	# LeftPanel fills x=0..200 and the MoveInfoLabel/MoveButtons sit around
	# y=830..890; the cruiser (cols 50-51, row 9) lands around screen x=700..860
	# y=394..474 and the ghost (cols 52-53, row 10) lands around x=860..1020
	# y=474..554 at zoom 2.5. An 800x340 crop at (460, 304) frames both hulls
	# with nebula padding and excludes the panel + bottom bar. Aspect 2.353:1
	# matches page 5's 452x192 slot (2.354:1) so the TextureRect stretches
	# without visible distortion.
	await _capture_cropped("09_move_preview.png", Rect2i(460, 304, 800, 340))


func _shot_10_active_probe_enemy_panel() -> void:
	# Rebuild state for "Player 1, Turn 2" with an active probe overlaying the
	# P2 battleship. Damage the battleship slightly so the stat readout isn't
	# just max/max. Load gameplay.tscn fresh, switch to target grid, and use
	# _try_select_enemy_ship to show the enemy ship panel.
	_reset_state()
	_build_both_fleets()
	GameState.current_player = 0
	GameState.turn_number = 2
	var bs_p2: ShipInstance = GameState.players[1]["fleet"][0]  # battleship is first
	bs_p2.current_shields = 750
	bs_p2.current_armor = 1000
	# Pre-populate P1's cell records with a fresh probe around (70, 11).
	# Probe ship probes start at expires_in=3; one age pass → 2, still active.
	var cell_records: Dictionary = GameState.players[0]["cell_records"]
	var fog: FogShipRecord = FogShipRecord.from_ship(bs_p2)
	var bs_cells: Array[Vector2i] = ShipDefinitions.get_ship_cells(
		bs_p2.ship_type, bs_p2.position, bs_p2.facing)
	var half: int = 3  # probe_size = 6 for a probe ship
	for y in range(11 - half, 11 - half + 6):
		for x in range(70 - half, 70 - half + 6):
			if x < 0 or x >= GRID_COLS or y < 0 or y >= GRID_ROWS:
				continue
			var cell := Vector2i(x, y)
			var cell_fog: FogShipRecord = null
			if bs_cells.has(cell):
				cell_fog = fog
			cell_records[cell] = CellRecord.make_probe(cell_fog, 2)
	await _change_scene("res://scenes/gameplay.tscn")
	var gp: Node = get_tree().current_scene
	if gp == null:
		return
	_fit_gameplay_cameras(gp)
	gp.call("_switch_grid", 1)  # TARGET
	gp.call("_try_select_enemy_ship", Vector2i(70, 11))
	await _capture("10_active_probe_enemy_panel.png")


func _shot_11_probe_closeup() -> void:
	# Same scene as shot 10. Zoom the target camera in and recenter it on the
	# probed battleship for a tight marketing shot.
	var gp: Node = get_tree().current_scene
	if gp == null:
		return
	var target_cam: Camera2D = gp.get_node("MainLayout/GridArea/TargetViewport/SubViewport/GridNode/Camera2D")
	target_cam.zoom = Vector2(2.5, 2.5)
	target_cam.position = Vector2(70 * CELL_SIZE + CELL_SIZE / 2.0, 11 * CELL_SIZE + CELL_SIZE / 2.0)
	var target_renderer: Node2D = gp.get_node("MainLayout/GridArea/TargetViewport/SubViewport/GridNode")
	target_renderer.queue_redraw()
	await _capture("11_probe_closeup.png")


func _shot_12_battle_log_detail() -> void:
	# Reuse the shot-10 state, refit the target camera (shot 11 zoomed it in),
	# populate the battle log with three synthetic entries, show battle log tab.
	var gp: Node = get_tree().current_scene
	if gp == null:
		return
	_fit_gameplay_cameras(gp)
	var battle_log: Node = gp.get_node_or_null("MainLayout/LeftPanel/BattleLogPanel")
	if battle_log != null and battle_log.has_method("add_entry"):
		battle_log.call("add_entry", {
			"type": "probe",
			"ship_type": "probe_ship",
			"target": Vector2i(70, 11),
			"ships_detected": 1
		})
		battle_log.call("add_entry", {
			"type": "laser",
			"ship_type": "battleship",
			"target": Vector2i(70, 11),
			"hit": true,
			"has_probe": true,
			"shield_damage": 250,
			"armor_damage": 0,
			"destroyed": false,
			"target_ship_type": "battleship"
		})
		battle_log.call("add_entry", {
			"type": "move",
			"success": true,
			"ship_type": "cruiser",
			"old_position": Vector2i(50, 9),
			"new_position": Vector2i(52, 9),
			"old_facing": 2,
			"new_facing": 2,
			"move_points_used": 1.0,
			"energy_used": 50
		})
	gp.call("_show_left_tab", "battle_log")
	await _capture("12_battle_log_detail.png")


func _shot_13_command_overview() -> void:
	# Clean P1 Turn 1 state, full-grid zoom on the command grid. Marketing shot.
	_reset_state()
	_build_both_fleets()
	GameState.current_player = 0
	GameState.turn_number = 1
	await _change_scene("res://scenes/gameplay.tscn")
	var gp: Node = get_tree().current_scene
	if gp == null:
		return
	gp.call("_switch_grid", 0)  # COMMAND
	var cam: Camera2D = gp.get_node("MainLayout/GridArea/CommandViewport/SubViewport/GridNode/Camera2D")
	var vp: SubViewport = gp.get_node("MainLayout/GridArea/CommandViewport/SubViewport")
	var vp_size: Vector2 = Vector2(vp.size)
	if vp_size.x > 0.0 and vp_size.y > 0.0:
		var grid_w: float = float(GRID_COLS) * float(CELL_SIZE)
		var grid_h: float = float(GRID_ROWS) * float(CELL_SIZE)
		var zx: float = vp_size.x / grid_w
		var zy: float = vp_size.y / grid_h
		var zoom: float = min(zx, zy)
		cam.zoom = Vector2(zoom, zoom)
		cam.position = Vector2(grid_w / 2.0, grid_h / 2.0)
	var command_renderer: Node2D = gp.get_node("MainLayout/GridArea/CommandViewport/SubViewport/GridNode")
	command_renderer.queue_redraw()
	await _capture("13_command_overview.png")
