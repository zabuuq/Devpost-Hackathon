extends Control

const CELL_SIZE: int = 32
const GRID_COLS: int = 80
const GRID_ROWS: int = 20
const MIN_ZOOM: float = 0.1
const MAX_ZOOM: float = 4.0

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
@onready var battle_log_tab_btn: Button = $MainLayout/LeftPanel/TabButtons/BattleLogBtn
@onready var ship_panel_tab_btn: Button = $MainLayout/LeftPanel/TabButtons/ShipPanelBtn
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
	_show_left_tab("battle_log")
	# Replay opponent's last turn results into the battle log
	for result in GameState.last_turn_results:
		battle_log_panel.add_entry(result)
	GameState.last_turn_results = []

	turn_manager.turn_start()
	command_renderer.refresh()
	target_renderer.refresh()

	# Set up ship panel
	_setup_ship_panel()

	# Hide move UI initially
	move_info_label.visible = false
	move_buttons.visible = false

	# Connect move buttons
	move_submit_btn.pressed.connect(_on_move_submit_pressed)
	move_cancel_btn.pressed.connect(_on_move_cancel_pressed)
	confirm_dialog.confirmed.connect(_on_move_confirmed)


func _setup_ship_panel() -> void:
	# The ShipPanelContainer already has a placeholder label child.
	# We attach the ship_panel script to it and let it build UI.
	# First, find or create the ship panel control inside the container.
	var panel_script: Script = preload("res://scripts/ui/ship_panel.gd")
	ship_panel = Control.new()
	ship_panel.set_script(panel_script)
	ship_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ship_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ship_panel_container.add_child(ship_panel)
	ship_panel.action_requested.connect(_on_ship_action_requested)


func _update_player_label() -> void:
	player_turn_label.text = "Player %d — Turn %d" % [GameState.current_player + 1, GameState.turn_number]


func _switch_grid(grid: ActiveGrid) -> void:
	active_grid = grid
	command_viewport.visible = (grid == ActiveGrid.COMMAND)
	target_viewport.visible = (grid == ActiveGrid.TARGET)
	command_tab_btn.modulate = Color.WHITE if grid == ActiveGrid.COMMAND else Color(0.6, 0.6, 0.6)
	target_tab_btn.modulate = Color.WHITE if grid == ActiveGrid.TARGET else Color(0.6, 0.6, 0.6)
	active_camera = command_camera if grid == ActiveGrid.COMMAND else target_camera


func _show_left_tab(tab: String) -> void:
	battle_log_panel.visible = (tab == "battle_log")
	ship_panel_container.visible = (tab == "ship_panel")
	battle_log_tab_btn.modulate = Color.WHITE if tab == "battle_log" else Color(0.6, 0.6, 0.6)
	ship_panel_tab_btn.modulate = Color.WHITE if tab == "ship_panel" else Color(0.6, 0.6, 0.6)


func _on_command_grid_pressed() -> void:
	AudioManager.play_sfx("click")
	if interaction_state == InteractionState.TARGETING:
		_cancel_targeting()
	_switch_grid(ActiveGrid.COMMAND)


func _on_target_grid_pressed() -> void:
	AudioManager.play_sfx("click")
	_switch_grid(ActiveGrid.TARGET)


func _on_battle_log_tab_pressed() -> void:
	_show_left_tab("battle_log")


func _on_ship_panel_tab_pressed() -> void:
	_show_left_tab("ship_panel")


func _on_command_viewport_gui_input(event: InputEvent) -> void:
	_handle_grid_input(event, command_camera, command_viewport, command_subviewport, command_renderer)


func _on_target_viewport_gui_input(event: InputEvent) -> void:
	_handle_grid_input(event, target_camera, target_viewport, target_subviewport, target_renderer)


func _handle_grid_input(event: InputEvent, cam: Camera2D, container: SubViewportContainer,
		vp: SubViewport, renderer: GridRenderer) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_camera(cam, 1.1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_camera(cam, 0.9)
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				is_panning = true
				pan_start_mouse = event.position
				pan_start_cam = cam.position
			else:
				is_panning = false
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			is_panning = false
			var world_pos: Vector2 = _container_to_world(event.position, container, vp, cam)
			var cell := Vector2i(int(world_pos.x / CELL_SIZE), int(world_pos.y / CELL_SIZE))
			_handle_grid_click(cell, renderer == command_renderer)
	elif event is InputEventMouseMotion:
		if is_panning and (event.button_mask & MOUSE_BUTTON_MASK_MIDDLE):
			var delta: Vector2 = (pan_start_mouse - event.position) / cam.zoom
			cam.position = pan_start_cam + delta
			_clamp_camera(cam)
		renderer.set_mouse_world_pos(_container_to_world(event.position, container, vp, cam))


func _handle_grid_click(cell: Vector2i, is_command: bool) -> void:
	# Bounds check
	if cell.x < 0 or cell.x >= GRID_COLS or cell.y < 0 or cell.y >= GRID_ROWS:
		return

	if is_command:
		match interaction_state:
			InteractionState.IDLE, InteractionState.SHIP_SELECTED:
				_try_select_ship(cell)
			InteractionState.MOVE_PREVIEW:
				pass  # clicks don't do anything in move preview; use WASD
	else:
		# Target grid click
		if interaction_state == InteractionState.TARGETING:
			_execute_targeting_action(cell)
		else:
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
	if record.has_probe and record.ship != null:
		# Deselect own ship so clicking it again will re-select properly
		if selected_ship != null:
			selected_ship = null
			interaction_state = InteractionState.IDLE
			command_renderer.clear_selected_ship()
		# Set enemy selection highlight on target grid
		target_renderer.set_selected_enemy(record.ship)
		ship_panel.show_enemy_ship(record.ship)
		_show_left_tab("ship_panel")
	else:
		_clear_enemy_selection()


func _clear_enemy_selection() -> void:
	target_renderer.clear_selected_enemy()


func _select_ship(ship: ShipInstance) -> void:
	selected_ship = ship
	interaction_state = InteractionState.SHIP_SELECTED
	command_renderer.set_selected_ship(ship)
	# Clear any enemy selection when selecting own ship (Bug 3)
	target_renderer.clear_selected_enemy()
	ship_panel.show_ship(ship)
	_show_left_tab("ship_panel")


func _deselect_ship() -> void:
	selected_ship = null
	interaction_state = InteractionState.IDLE
	command_renderer.clear_selected_ship()
	target_renderer.clear_selected_enemy()
	ship_panel.clear_ship()


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

	# Return to command grid
	_cancel_targeting()
	_switch_grid(ActiveGrid.COMMAND)

	# Refresh both grids
	command_renderer.refresh()
	target_renderer.refresh()

	# Refresh ship panel
	if selected_ship != null:
		ship_panel.show_ship(selected_ship)


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
		ship_panel.show_ship(selected_ship)


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

func _on_end_turn_pressed() -> void:
	if interaction_state == InteractionState.MOVE_PREVIEW:
		return  # block end turn during move preview
	AudioManager.play_sfx("click")
	_deselect_ship()
	turn_manager.turn_end()
