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
	await _shot_06_probe_aiming()
	await _shot_07_probe_revealed()
	await _shot_08_ship_panel_sliders()
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


func _fit_placement_camera(scene: Node) -> void:
	var cam: Camera2D = scene.get_node_or_null("HSplitContainer/GridViewport/SubViewport/GridNode/Camera2D")
	var vp: SubViewport = scene.get_node_or_null("HSplitContainer/GridViewport/SubViewport")
	_fit_grid_camera(cam, vp)
	var grid_node: Node2D = scene.get_node_or_null("HSplitContainer/GridViewport/SubViewport/GridNode")
	if grid_node != null:
		grid_node.queue_redraw()


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
	# Stay on the fleet_placement scene from shot 03. Populate the controller's
	# placed_ships dict directly and trigger a redraw so _draw_grid() paints
	# exactly what the real UI would show after five placements.
	var scene: Node = get_tree().current_scene
	if scene == null:
		push_error("[screenshot_runner] shot 04: current_scene is null")
		return
	var placed: Dictionary = {}
	for i in range(P1_POSITIONS.size()):
		var entry: Dictionary = P1_POSITIONS[i]
		placed[i] = _make_ship(entry["type"], entry["pos"], SHIP_FACING)
	scene.set("placed_ships", placed)
	scene.set("selected_ship_idx", -1)
	var done_btn: Button = scene.get_node_or_null("HSplitContainer/LeftPanel/DoneButton")
	if done_btn != null:
		done_btn.disabled = false
	# Tint the ship-list buttons green the way the real placement flow does.
	var ship_buttons: Variant = scene.get("ship_buttons")
	if ship_buttons != null:
		for btn in ship_buttons:
			btn.modulate = Color(0.4, 1.0, 0.4)
	_fit_placement_camera(scene)
	await _capture("04_fleet_placement_full.png")


func _shot_05_command_grid() -> void:
	_reset_state()
	_build_both_fleets()
	GameState.current_player = 0
	GameState.turn_number = 1
	await _change_scene("res://scenes/gameplay.tscn")
	_fit_gameplay_cameras(get_tree().current_scene)
	await _capture("05_command_grid.png")


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


func _shot_09_move_preview() -> void:
	# Deselect the battleship, select the cruiser, enter move preview, and
	# shift the ghost two cells right (equivalent to pressing D twice).
	var gp: Node = get_tree().current_scene
	if gp == null:
		return
	gp.call("_deselect_ship")
	var cruiser: ShipInstance = _p1_ship("cruiser")
	if cruiser == null:
		return
	gp.call("_select_ship", cruiser)
	gp.call("_enter_move_preview", cruiser)
	var current_pos: Vector2i = gp.get("move_preview_position")
	gp.set("move_preview_position", current_pos + Vector2i(2, 0))
	gp.call("_update_move_preview")
	await _capture("09_move_preview.png")


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
