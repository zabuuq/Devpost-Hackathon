extends Control

const CELL_SIZE: int = 32
const GRID_COLS: int = 80
const GRID_ROWS: int = 20
const MIN_ZOOM: float = 0.1
const MAX_ZOOM: float = 4.0
const DRAG_THRESHOLD_PX: float = 4.0

enum ActiveGrid { COMMAND, TARGET }
enum InteractionState { IDLE, SHIP_SELECTED, MOVE_PREVIEW, TARGETING }

@onready var command_viewport: SubViewportContainer = $MainLayout/GridArea/CommandViewport
@onready var target_viewport: SubViewportContainer = $MainLayout/GridArea/TargetViewport
@onready var command_subviewport: SubViewport = $MainLayout/GridArea/CommandViewport/SubViewport
@onready var target_subviewport: SubViewport = $MainLayout/GridArea/TargetViewport/SubViewport
@onready var command_camera: Camera2D = $MainLayout/GridArea/CommandViewport/SubViewport/GridNode/Camera2D
@onready var target_camera: Camera2D = $MainLayout/GridArea/TargetViewport/SubViewport/GridNode/Camera2D
@onready var command_renderer: GridRenderer = $MainLayout/GridArea/CommandViewport/SubViewport/GridNode
@onready var target_renderer: GridRenderer = $MainLayout/GridArea/TargetViewport/SubViewport/GridNode
@onready var command_tab_btn: Button = $TopBar/CommandGridBtn
@onready var target_tab_btn: Button = $TopBar/TargetGridBtn
@onready var battle_log_panel: ScrollContainer = $MainLayout/LeftPanel/BattleLogPanel  # has battle_log.gd script
@onready var ship_panel_container: VBoxContainer = $MainLayout/LeftPanel/ShipPanelContainer
@onready var player_turn_label: Label = $TopBar/PlayerTurnLabel
@onready var end_turn_button: Button = $TopBar/EndTurnButton
@onready var turn_manager: TurnManager = $TurnManager
@onready var action_resolver: ActionResolver = $ActionResolver
@onready var move_info_label: Label = $MoveInfoLabel
@onready var move_submit_btn: Button = $MoveButtons/SubmitMoveBtn
@onready var move_cancel_btn: Button = $MoveButtons/CancelMoveBtn
@onready var move_buttons: HBoxContainer = $MoveButtons
@onready var confirm_dialog: ConfirmationDialog = $ConfirmMoveDialog

var active_grid: ActiveGrid = ActiveGrid.COMMAND
var is_panning: bool = false
var pan_start_mouse: Vector2 = Vector2.ZERO
var pan_start_cam: Vector2 = Vector2.ZERO
var active_camera: Camera2D

# Left-drag click-vs-pan disambiguation state
var mouse_down: bool = false
var mouse_down_pos: Vector2 = Vector2.ZERO
var dragged: bool = false

# Interaction state machine
var interaction_state: InteractionState = InteractionState.IDLE
var selected_ship: ShipInstance = null
var ship_panel: Control = null  # the ship_panel.gd script instance

# Move preview state
var move_preview_origin: Vector2i = Vector2i.ZERO
var move_preview_facing: int = 0
var move_preview_position: Vector2i = Vector2i.ZERO
var move_preview_new_facing: int = 0

# Targeting state (for probe/laser/missile)
var targeting_action: String = ""
var targeting_ship: ShipInstance = null


func _ready() -> void:
	GameState.phase = GameState.Phase.GAMEPLAY
	_update_player_label()
	_switch_grid(ActiveGrid.COMMAND)

	var opponent_turn_number: int = GameState.players[1 - GameState.current_player]["turns_played"]
	if opponent_turn_number > 0:
		var entries_pushed: int = 0
		if not GameState.last_turn_results.is_empty():
			var defender_cells: Array[Vector2i] = _collect_defender_living_cells()
			for result in GameState.last_turn_results:
				var entry: Dictionary = _filter_opponent_entry(result, defender_cells)
				if entry.is_empty():
					continue
				entry["turn_number"] = opponent_turn_number
				entry["owner"] = 1
				GameState.append_battle_log(GameState.current_player, entry)
				entries_pushed += 1
		if entries_pushed == 0:
			GameState.append_battle_log(GameState.current_player, {
				"type": "empty_report",
				"turn_number": opponent_turn_number,
				"owner": 1,
			})
		GameState.append_battle_log_divider(GameState.current_player, opponent_turn_number, true)
	GameState.last_turn_results = []
	battle_log_panel.render_from_state()

	turn_manager.turn_start()
	command_renderer.refresh()
	target_renderer.refresh()

	# Restore per-player camera state (or fall back to fit-to-grid default).
	_restore_camera_state(command_camera, command_subviewport, true)
	_restore_camera_state(target_camera, target_subviewport, false)

	# Set up ship panel
	_setup_ship_panel()
	# I11-2: prime collapsed-row mini bars and reset gray-when-acted state for
	# the new turn (action_taken flags were cleared by turn_start above).
	ship_panel.refresh_all_headers()

	# Hide move UI initially
	move_info_label.visible = false
	move_buttons.visible = false

	# Connect move buttons
	move_submit_btn.pressed.connect(_on_move_submit_pressed)
	move_cancel_btn.pressed.connect(_on_move_cancel_pressed)
	confirm_dialog.confirmed.connect(_on_move_confirmed)


func _collect_defender_living_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var fleet: Array = GameState.players[GameState.current_player]["fleet"]
	for ship in fleet:
		if ship.is_destroyed:
			continue
		cells.append_array(ShipDefinitions.get_ship_cells(ship.ship_type, ship.position, ship.facing))
	return cells


func _filter_opponent_entry(result: Dictionary, defender_cells: Array[Vector2i]) -> Dictionary:
	var entry: Dictionary = result.duplicate()
	var action_type: String = entry.get("type", "")

	if action_type == "probe":
		if int(entry.get("ships_detected", 0)) == 0:
			return {}
		entry["ship_type"] = "enemy"
		return entry

	if action_type == "laser" or action_type == "missile":
		var hit: bool = entry.get("hit", false)
		if not hit:
			var target: Vector2i = entry.get("target", Vector2i.ZERO)
			var near: bool = false
			var near_types: Array[String] = []
			var fleet: Array = GameState.players[GameState.current_player]["fleet"]
			for ship in fleet:
				if ship.is_destroyed:
					continue
				var ship_cells: Array[Vector2i] = ShipDefinitions.get_ship_cells(
					ship.ship_type, ship.position, ship.facing)
				var ship_is_near: bool = false
				for cell in ship_cells:
					var dx: int = absi(cell.x - target.x)
					var dy: int = absi(cell.y - target.y)
					var cheby: int = maxi(dx, dy)
					if cheby == 1:
						ship_is_near = true
						break
				if ship_is_near:
					near = true
					near_types.append(ship.ship_type)
			if not near:
				return {}
			entry["near_miss_ships"] = near_types
		entry["ship_type"] = "enemy"
		return entry

	entry["ship_type"] = "enemy"
	return entry


func _setup_ship_panel() -> void:
	# I10-1: ship_panel is now an always-visible accordion of the current
	# player's fleet. ship_panel.gd's _ready calls refresh_for_turn() to
	# build the rows from GameState — so by the time _setup_ship_panel
	# returns, the accordion is already populated and collapsed.
	var panel_script: Script = preload("res://scripts/ui/ship_panel.gd")
	ship_panel = Control.new()
	ship_panel.set_script(panel_script)
	ship_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ship_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ship_panel_container.add_child(ship_panel)
	ship_panel.action_requested.connect(_on_ship_action_requested)
	ship_panel.ship_selected.connect(_on_panel_ship_selected)
	ship_panel.ship_deselected.connect(_on_panel_ship_deselected)


func _update_player_label() -> void:
	var turn_display: int = GameState.players[GameState.current_player]["turns_played"] + 1
	player_turn_label.text = "Player %d — Turn %d" % [GameState.current_player + 1, turn_display]


func _switch_grid(grid: ActiveGrid) -> void:
	active_grid = grid
	command_viewport.visible = (grid == ActiveGrid.COMMAND)
	target_viewport.visible = (grid == ActiveGrid.TARGET)
	command_tab_btn.modulate = Color.WHITE if grid == ActiveGrid.COMMAND else Color(0.6, 0.6, 0.6)
	target_tab_btn.modulate = Color.WHITE if grid == ActiveGrid.TARGET else Color(0.6, 0.6, 0.6)
	active_camera = command_camera if grid == ActiveGrid.COMMAND else target_camera


func _on_command_grid_pressed() -> void:
	AudioManager.play_sfx("click")
	if interaction_state == InteractionState.TARGETING:
		_cancel_targeting()
	_switch_grid(ActiveGrid.COMMAND)
	if ship_panel != null:
		ship_panel.hide_enemy_panel()


func _on_target_grid_pressed() -> void:
	AudioManager.play_sfx("click")
	_switch_grid(ActiveGrid.TARGET)


func _on_panel_ship_selected(ship: ShipInstance) -> void:
	# Header click in the accordion. Mirror the selection on the Command Grid
	# and force-switch to it so the player can see what they just expanded.
	# Move-preview locks the active ship: revert the accordion so it matches
	# the moving ship rather than letting the user yank selection mid-preview.
	if interaction_state == InteractionState.MOVE_PREVIEW:
		if selected_ship != null:
			ship_panel.expand_row_for_ship(selected_ship)
		return
	if interaction_state == InteractionState.TARGETING:
		_cancel_targeting()
	selected_ship = ship
	interaction_state = InteractionState.SHIP_SELECTED
	command_renderer.set_selected_ship(ship)
	target_renderer.clear_selected_enemy()
	if active_grid != ActiveGrid.COMMAND:
		_switch_grid(ActiveGrid.COMMAND)
	# Side-menu selection means the player likely can't see the ship — pan
	# the Command Grid camera so it lands in view. Click-on-grid selection
	# (_select_ship) skips this since the ship is already on screen.
	_center_command_camera_on_ship(ship)


func _center_command_camera_on_ship(ship: ShipInstance) -> void:
	var cells: Array[Vector2i] = ship.get_occupied_cells()
	if cells.is_empty():
		return
	var center_cell: Vector2i = cells[cells.size() / 2]
	command_camera.position = Vector2(
		float(center_cell.x) * float(CELL_SIZE) + float(CELL_SIZE) / 2.0,
		float(center_cell.y) * float(CELL_SIZE) + float(CELL_SIZE) / 2.0)
	_clamp_camera(command_camera)
	_save_camera_state(command_camera, true)


func _on_panel_ship_deselected() -> void:
	# Header re-click collapses the row — clear the Command Grid selection
	# but stay on the current grid (deselecting shouldn't yank the view).
	# Don't drop the selection mid-move-preview; the submit/cancel buttons
	# need a live selected_ship reference.
	if interaction_state == InteractionState.MOVE_PREVIEW:
		if selected_ship != null:
			ship_panel.expand_row_for_ship(selected_ship)
		return
	selected_ship = null
	interaction_state = InteractionState.IDLE
	command_renderer.clear_selected_ship()


func _on_command_viewport_gui_input(event: InputEvent) -> void:
	_handle_grid_input(event, command_camera, command_viewport, command_subviewport, command_renderer)


func _on_target_viewport_gui_input(event: InputEvent) -> void:
	_handle_grid_input(event, target_camera, target_viewport, target_subviewport, target_renderer)


func _handle_grid_input(event: InputEvent, cam: Camera2D, container: SubViewportContainer,
		vp: SubViewport, renderer: GridRenderer) -> void:
	var is_command: bool = renderer == command_renderer
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if event.ctrl_pressed:
				_zoom_camera_at(cam, 1.1, event.position, container, vp)
				_save_camera_state(cam, is_command)
			elif event.shift_pressed:
				# Shift+wheel-up → camera moves left (x decreases)
				cam.position.x -= float(CELL_SIZE) / cam.zoom.x
				_clamp_camera(cam)
				_save_camera_state(cam, is_command)
			else:
				# Plain wheel-up → camera moves up (y decreases)
				cam.position.y -= float(CELL_SIZE) / cam.zoom.y
				_clamp_camera(cam)
				_save_camera_state(cam, is_command)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if event.ctrl_pressed:
				_zoom_camera_at(cam, 0.9, event.position, container, vp)
				_save_camera_state(cam, is_command)
			elif event.shift_pressed:
				# Shift+wheel-down → camera moves right (x increases)
				cam.position.x += float(CELL_SIZE) / cam.zoom.x
				_clamp_camera(cam)
				_save_camera_state(cam, is_command)
			else:
				# Plain wheel-down → camera moves down (y increases)
				cam.position.y += float(CELL_SIZE) / cam.zoom.y
				_clamp_camera(cam)
				_save_camera_state(cam, is_command)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Begin potential drag-pan; defer click decision until release.
				mouse_down = true
				dragged = false
				mouse_down_pos = event.position
				pan_start_mouse = event.position
				pan_start_cam = cam.position
				is_panning = false
			else:
				# Release: if we crossed the drag threshold, suppress the click.
				var was_dragged: bool = dragged
				mouse_down = false
				dragged = false
				is_panning = false
				if not was_dragged:
					var world_pos: Vector2 = _container_to_world(event.position, container, vp, cam)
					var cell := Vector2i(int(world_pos.x / CELL_SIZE), int(world_pos.y / CELL_SIZE))
					_handle_grid_click(cell, is_command)
	elif event is InputEventMouseMotion:
		# Promote a held left-button to a drag-pan once we cross the threshold.
		if mouse_down and (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
			if not dragged and event.position.distance_to(mouse_down_pos) >= DRAG_THRESHOLD_PX:
				dragged = true
				is_panning = true
			if is_panning:
				var delta: Vector2 = (pan_start_mouse - event.position) / cam.zoom
				cam.position = pan_start_cam + delta
				_clamp_camera(cam)
				_save_camera_state(cam, is_command)
		renderer.set_mouse_world_pos(_container_to_world(event.position, container, vp, cam))


func _handle_grid_click(cell: Vector2i, is_command: bool) -> void:
	# Bounds gate: probe targeting is the one path that accepts off-grid clicks
	# (the probe center clamp in _execute_targeting_action keeps the probe area
	# fully on-grid). Selection, laser, and missile clicks all need a real cell.
	var in_bounds: bool = cell.x >= 0 and cell.x < GRID_COLS and cell.y >= 0 and cell.y < GRID_ROWS

	if is_command:
		if not in_bounds:
			return
		match interaction_state:
			InteractionState.IDLE, InteractionState.SHIP_SELECTED:
				_try_select_ship(cell)
			InteractionState.MOVE_PREVIEW:
				pass  # clicks don't do anything in move preview; use WASD
	else:
		# Target grid click
		if interaction_state == InteractionState.TARGETING:
			if targeting_action == "probe":
				_execute_targeting_action(cell)  # off-grid OK; probe center is clamped
			else:
				if not in_bounds:
					return
				_execute_targeting_action(cell)
		else:
			if not in_bounds:
				return
			_try_select_enemy_ship(cell)


func _try_select_ship(cell: Vector2i) -> void:
	var fleet: Array = GameState.players[GameState.current_player]["fleet"]
	var clicked_ship: ShipInstance = null
	for ship in fleet:
		if ship.is_destroyed:
			continue
		var cells: Array[Vector2i] = ship.get_occupied_cells()
		if cells.has(cell):
			clicked_ship = ship
			break

	if clicked_ship == null:
		_deselect_ship()
		return

	if clicked_ship == selected_ship:
		# Click same ship again — deselect
		_deselect_ship()
		return

	_select_ship(clicked_ship)


func _try_select_enemy_ship(cell: Vector2i) -> void:
	var cell_records: Dictionary = GameState.players[GameState.current_player]["cell_records"]
	if not cell_records.has(cell):
		_clear_enemy_selection()
		return
	var record: CellRecord = cell_records[cell]
	if record.ship == null:
		_clear_enemy_selection()
		return
	# Selection is allowed if ANY cell of the referenced ship currently has an
	# active probe — covers cells outside the probe area on a partially probed
	# ship (ActionResolver writes ship refs there without has_probe = true).
	var ship_cells: Array[Vector2i] = ShipDefinitions.get_ship_cells(
		record.ship.ship_type, record.ship.position, record.ship.facing)
	var has_active_probe: bool = false
	for c in ship_cells:
		if cell_records.has(c) and (cell_records[c] as CellRecord).has_probe:
			has_active_probe = true
			break
	if has_active_probe:
		# Deselect own ship so clicking it again will re-select properly
		if selected_ship != null:
			selected_ship = null
			interaction_state = InteractionState.IDLE
			command_renderer.clear_selected_ship()
			ship_panel.collapse_all()
		# Set enemy selection highlight on target grid
		target_renderer.set_selected_enemy(record.ship)
		ship_panel.show_enemy_ship(record.ship)
	else:
		_clear_enemy_selection()


func _clear_enemy_selection() -> void:
	target_renderer.clear_selected_enemy()
	if ship_panel != null:
		ship_panel.hide_enemy_panel()


func _select_ship(ship: ShipInstance) -> void:
	selected_ship = ship
	interaction_state = InteractionState.SHIP_SELECTED
	command_renderer.set_selected_ship(ship)
	# Clear any enemy selection when selecting own ship (Bug 3)
	target_renderer.clear_selected_enemy()
	ship_panel.expand_row_for_ship(ship)


func _deselect_ship() -> void:
	selected_ship = null
	interaction_state = InteractionState.IDLE
	command_renderer.clear_selected_ship()
	target_renderer.clear_selected_enemy()
	ship_panel.collapse_all()
	ship_panel.hide_enemy_panel()


# ---------------------------------------------------------------------------
# Action dispatch from ship panel
# ---------------------------------------------------------------------------

func _on_ship_action_requested(action: String, ship: ShipInstance) -> void:
	match action:
		"move":
			_enter_move_preview(ship)
		"probe":
			_enter_targeting("probe", ship)
		"laser":
			_enter_targeting("laser", ship)
		"missile":
			_enter_targeting("missile", ship)


# ---------------------------------------------------------------------------
# Targeting mode (probe / laser / missile)
# ---------------------------------------------------------------------------

func _enter_targeting(action: String, ship: ShipInstance) -> void:
	targeting_action = action
	targeting_ship = ship
	interaction_state = InteractionState.TARGETING
	_switch_grid(ActiveGrid.TARGET)

	# If probe, show probe highlight
	if action == "probe":
		var stats: Dictionary = ShipDefinitions.SHIPS[ship.ship_type]
		target_renderer.probe_highlight_size = stats["probe_area"]
	else:
		target_renderer.probe_highlight_size = 0


func _cancel_targeting() -> void:
	targeting_action = ""
	targeting_ship = null
	interaction_state = InteractionState.SHIP_SELECTED if selected_ship != null else InteractionState.IDLE
	target_renderer.probe_highlight_size = 0
	target_renderer.refresh()


func _execute_targeting_action(cell: Vector2i) -> void:
	if targeting_ship == null:
		return

	var player_idx: int = GameState.current_player
	var opponent_fleet: Array = GameState.players[1 - player_idx]["fleet"]
	var result: Dictionary = {}

	match targeting_action:
		"probe":
			# Clamp probe center so the full probe area stays on-grid,
			# matching the visual highlight clamping in GridRenderer.
			var stats: Dictionary = ShipDefinitions.SHIPS[targeting_ship.ship_type]
			var probe_size: int = stats["probe_area"]
			var half: int = probe_size / 2
			var clamped_cell := Vector2i(
				clampi(cell.x, half, GRID_COLS - 1 - (probe_size - 1 - half)),
				clampi(cell.y, half, GRID_ROWS - 1 - (probe_size - 1 - half))
			)
			result = action_resolver.resolve_probe(targeting_ship, clamped_cell, player_idx)
		"laser":
			result = action_resolver.resolve_laser(targeting_ship, cell, opponent_fleet, player_idx)
		"missile":
			result = action_resolver.resolve_missile(targeting_ship, cell, opponent_fleet, player_idx)

	# Log result and play SFX
	battle_log_panel.add_entry(result)
	AudioManager.play_action_sfx(result)
	GameState.last_turn_results.append(result)

	# Stay on Target Grid; just clear targeting state.
	_cancel_targeting()

	# Refresh both grids
	command_renderer.refresh()
	target_renderer.refresh()

	# Refresh whichever accordion row is currently expanded so the post-action
	# stat readouts (energy, missiles, etc.) reflect the resolver's writes.
	if selected_ship != null:
		ship_panel.refresh_expanded()
	# I11-2: also refresh every collapsed header so the just-acted ship grays
	# out (action_taken cue) and any shield/armor bar changes are visible even
	# if the player collapses or scrolls past the active row.
	ship_panel.refresh_all_headers()

	# I8-6: Instant win on last kill. If this action destroyed the opponent's
	# final living ship, jump straight to victory — skip end-of-turn shield
	# regen and skip the handoff. Stats are already in players[*].turn_stats
	# (resolvers update them mid-call), and last_turn_hits has already been
	# incremented for this hit. The shooter (current_player) is the winner;
	# victory.gd reads winner from GameState.current_player.
	if result.get("match_over", false):
		get_tree().change_scene_to_file("res://scenes/victory.tscn")


# ---------------------------------------------------------------------------
# Move Preview
# ---------------------------------------------------------------------------

func _enter_move_preview(ship: ShipInstance) -> void:
	interaction_state = InteractionState.MOVE_PREVIEW
	selected_ship = ship
	move_preview_origin = ship.position
	move_preview_facing = ship.facing
	move_preview_position = ship.position
	move_preview_new_facing = ship.facing
	# Show move UI
	move_info_label.visible = true
	move_buttons.visible = true
	end_turn_button.disabled = true

	_update_move_preview()


func _exit_move_preview() -> void:
	interaction_state = InteractionState.SHIP_SELECTED if selected_ship != null else InteractionState.IDLE
	move_info_label.visible = false
	move_buttons.visible = false
	end_turn_button.disabled = false
	command_renderer.clear_ghost_ship()


func _update_move_preview() -> void:
	if selected_ship == null:
		return

	# Use pivot displacement so rotation-induced origin shifts don't count as movement
	var old_pivot: Vector2i = move_preview_origin + ShipDefinitions.get_pivot_offset(selected_ship.ship_type, move_preview_facing)
	var new_pivot: Vector2i = move_preview_position + ShipDefinitions.get_pivot_offset(selected_ship.ship_type, move_preview_new_facing)
	var net_displacement: Vector2i = new_pivot - old_pivot
	var net_rotation: int = 0
	var facing_diff: int = (move_preview_new_facing - move_preview_facing + 4) % 4
	if facing_diff == 1:
		net_rotation = 1
	elif facing_diff == 3:
		net_rotation = -1

	# Use move_preview_new_facing (post-rotation) so the 0.5-pt forward discount
	# tracks the ship's CURRENT heading during preview, not its pre-rotation heading.
	var cost: Dictionary = ActionResolver.calc_move_cost(move_preview_new_facing, net_displacement, net_rotation)
	var available: float = ActionResolver.get_available_move_points(selected_ship)

	var pts_used: float = cost["move_points"]
	var energy_cost: int = cost["energy"]
	var valid: bool = pts_used <= available + 0.001 and energy_cost <= selected_ship.current_energy

	# Check bounds and collision
	var new_cells: Array[Vector2i] = ShipDefinitions.get_ship_cells(
		selected_ship.ship_type, move_preview_position, move_preview_new_facing)

	if not ActionResolver.cells_in_bounds(new_cells):
		valid = false

	if valid:
		var blocker: ShipInstance = action_resolver.check_move_collision(selected_ship, new_cells)
		if blocker != null:
			valid = false

	# Update ghost on renderer
	command_renderer.set_ghost_ship(new_cells, move_preview_position, move_preview_new_facing, valid)

	# Update info label
	move_info_label.text = "Move Points: %.1f / %.1f | Energy cost: %d" % [pts_used, available, energy_cost]
	if not valid:
		move_info_label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.4))
	else:
		move_info_label.add_theme_color_override("font_color", Color(0.6, 1.0, 0.6))

	move_submit_btn.disabled = not valid or (net_displacement == Vector2i.ZERO and net_rotation == 0)


func _unhandled_input(event: InputEvent) -> void:
	# Escape during targeting cancels the queued probe/laser/missile action.
	# Mirrors the cancel path used by _on_command_grid_pressed (gameplay.gd:204).
	if interaction_state == InteractionState.TARGETING:
		if event is InputEventKey and event.pressed and not event.echo \
				and event.keycode == KEY_ESCAPE:
			_cancel_targeting()
			get_viewport().set_input_as_handled()
		return

	if interaction_state != InteractionState.MOVE_PREVIEW:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		var handled: bool = true
		match event.keycode:
			KEY_W:
				move_preview_position += Vector2i(0, -1)
			KEY_S:
				move_preview_position += Vector2i(0, 1)
			KEY_A:
				move_preview_position += Vector2i(-1, 0)
			KEY_D:
				move_preview_position += Vector2i(1, 0)
			KEY_Q:
				var q_facing_diff: int = (move_preview_new_facing - move_preview_facing + 4) % 4
				# Allow CCW if net rotation is currently 0 or +1 (result would be -1 or 0)
				if q_facing_diff == 0 or q_facing_diff == 1:
					var old_facing_for_adjust: int = move_preview_new_facing
					move_preview_new_facing = (move_preview_new_facing + 3) % 4  # CCW
					_adjust_position_for_rotation(old_facing_for_adjust, move_preview_new_facing)
				else:
					handled = false
			KEY_E:
				var e_facing_diff: int = (move_preview_new_facing - move_preview_facing + 4) % 4
				# Allow CW if net rotation is currently 0 or -1 (result would be +1 or 0)
				if e_facing_diff == 0 or e_facing_diff == 3:
					var old_facing_for_adjust: int = move_preview_new_facing
					move_preview_new_facing = (move_preview_new_facing + 1) % 4  # CW
					_adjust_position_for_rotation(old_facing_for_adjust, move_preview_new_facing)
				else:
					handled = false
			KEY_ESCAPE:
				_on_move_cancel_pressed()
			KEY_ENTER, KEY_KP_ENTER:
				_on_move_submit_pressed()
			_:
				handled = false

		if handled:
			_update_move_preview()
			get_viewport().set_input_as_handled()


func _adjust_position_for_rotation(old_facing: int, new_facing: int) -> void:
	# When rotating, the pivot square stays fixed. We need to adjust the origin
	# so that the pivot cell position is preserved.
	if selected_ship == null:
		return
	var old_pivot_offset: Vector2i = ShipDefinitions.get_pivot_offset(selected_ship.ship_type, old_facing)
	var new_pivot_offset: Vector2i = ShipDefinitions.get_pivot_offset(selected_ship.ship_type, new_facing)
	# Pivot world position = origin + old_pivot_offset
	# New origin = pivot_world - new_pivot_offset
	var pivot_world: Vector2i = move_preview_position + old_pivot_offset
	move_preview_position = pivot_world - new_pivot_offset


func _on_move_submit_pressed() -> void:
	if move_submit_btn.disabled:
		return
	AudioManager.play_sfx("click")
	confirm_dialog.dialog_text = "Are you sure you want to move this ship?"
	confirm_dialog.popup_centered()


func _on_move_cancel_pressed() -> void:
	AudioManager.play_sfx("click")
	_exit_move_preview()
	command_renderer.refresh()


func _on_move_confirmed() -> void:
	if selected_ship == null:
		return

	var result: Dictionary = action_resolver.resolve_move(
		selected_ship, move_preview_position, move_preview_new_facing, GameState.current_player)

	battle_log_panel.add_entry(result)
	AudioManager.play_action_sfx(result)
	GameState.last_turn_results.append(result)
	_exit_move_preview()

	# Refresh
	command_renderer.refresh()
	target_renderer.refresh()
	if selected_ship != null:
		ship_panel.refresh_expanded()
	# I11-2: collapsed-row headers need to recolor + update bars after a move
	# (action_taken flips, ship may have taken damage from collisions, etc.).
	ship_panel.refresh_all_headers()


# ---------------------------------------------------------------------------
# Grid / Camera helpers
# ---------------------------------------------------------------------------

func _container_to_world(container_pos: Vector2, container: SubViewportContainer,
		vp: SubViewport, cam: Camera2D) -> Vector2:
	var container_size := container.size
	if container_size.x <= 0.0 or container_size.y <= 0.0:
		return Vector2.ZERO
	var vp_size := Vector2(vp.size)
	var vp_pos := container_pos / container_size * vp_size
	return cam.position + (vp_pos - vp_size * 0.5) / cam.zoom

func _zoom_camera(cam: Camera2D, factor: float) -> void:
	var new_zoom: float = clampf(cam.zoom.x * factor, MIN_ZOOM, MAX_ZOOM)
	cam.zoom = Vector2(new_zoom, new_zoom)
	_clamp_camera(cam)

func _zoom_camera_at(cam: Camera2D, factor: float, container_pos: Vector2,
		container: SubViewportContainer, vp: SubViewport) -> void:
	# Zoom while keeping the world point under the cursor stationary.
	var world_before: Vector2 = _container_to_world(container_pos, container, vp, cam)
	var old_zoom: float = cam.zoom.x
	var new_zoom: float = clampf(old_zoom * factor, MIN_ZOOM, MAX_ZOOM)
	if is_equal_approx(new_zoom, old_zoom):
		return
	cam.zoom = Vector2(new_zoom, new_zoom)
	var world_after: Vector2 = _container_to_world(container_pos, container, vp, cam)
	cam.position += world_before - world_after
	_clamp_camera(cam)

func _clamp_camera(cam: Camera2D) -> void:
	var grid_w: float = GRID_COLS * CELL_SIZE
	var grid_h: float = GRID_ROWS * CELL_SIZE
	cam.position.x = clampf(cam.position.x, 0.0, grid_w)
	cam.position.y = clampf(cam.position.y, 0.0, grid_h)

func _fit_camera(cam: Camera2D, vp_size: Vector2) -> void:
	var grid_w: float = GRID_COLS * CELL_SIZE
	var grid_h: float = GRID_ROWS * CELL_SIZE
	cam.position = Vector2(grid_w / 2.0, grid_h / 2.0)
	if vp_size.x > 0 and vp_size.y > 0:
		var zoom_x: float = vp_size.x / grid_w
		var zoom_y: float = vp_size.y / grid_h
		var fit_zoom: float = min(zoom_x, zoom_y)
		cam.zoom = Vector2(fit_zoom, fit_zoom)

# ---------------------------------------------------------------------------
# Per-player camera state persistence (I5-2)
# ---------------------------------------------------------------------------

func _save_camera_state(cam: Camera2D, is_command: bool) -> void:
	var key: String = "command_camera" if is_command else "target_camera"
	var state: Dictionary = {
		"position": cam.position,
		"zoom": cam.zoom.x,
	}
	GameState.players[GameState.current_player][key] = state

func _restore_camera_state(cam: Camera2D, _vp: SubViewport, is_command: bool) -> void:
	# When there's no saved state for this player, leave the scene's camera
	# defaults (zoom 1.0, position (1280, 320), matching fleet_placement.tscn)
	# untouched. Per-input saves capture every pan/zoom, so the saved-state
	# branch covers everything else.
	var key: String = "command_camera" if is_command else "target_camera"
	var saved: Dictionary = GameState.players[GameState.current_player][key]
	if saved.is_empty():
		return
	var saved_position: Vector2 = saved["position"]
	var saved_zoom: float = saved["zoom"]
	cam.position = saved_position
	cam.zoom = Vector2(saved_zoom, saved_zoom)
	_clamp_camera(cam)

# No _exit_tree safety-net: turn_manager.turn_end() flips GameState.current_player
# BEFORE change_scene_to_file, so a save here would write the outgoing player's
# camera state into the incoming player's slot. Per-input saves cover the normal
# pan/zoom path; the only thing we'd miss is a frame between the last pan and
# end-turn, which is a non-issue.

func _on_end_turn_pressed() -> void:
	if interaction_state == InteractionState.MOVE_PREVIEW:
		return  # block end turn during move preview
	AudioManager.play_sfx("click")
	_deselect_ship()
	turn_manager.turn_end()
