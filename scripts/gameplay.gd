extends Control

const CELL_SIZE: int = 32
const GRID_COLS: int = 80
const GRID_ROWS: int = 20
const MIN_ZOOM: float = 0.1
const MAX_ZOOM: float = 4.0

enum ActiveGrid { COMMAND, TARGET }

@onready var command_viewport: SubViewportContainer = $MainLayout/GridArea/CommandViewport
@onready var target_viewport: SubViewportContainer = $MainLayout/GridArea/TargetViewport
@onready var command_camera: Camera2D = $MainLayout/GridArea/CommandViewport/SubViewport/GridNode/Camera2D
@onready var target_camera: Camera2D = $MainLayout/GridArea/TargetViewport/SubViewport/GridNode/Camera2D
@onready var command_tab_btn: Button = $TopBar/CommandGridBtn
@onready var target_tab_btn: Button = $TopBar/TargetGridBtn
@onready var battle_log_tab_btn: Button = $MainLayout/LeftPanel/TabButtons/BattleLogBtn
@onready var ship_panel_tab_btn: Button = $MainLayout/LeftPanel/TabButtons/ShipPanelBtn
@onready var battle_log_panel: ScrollContainer = $MainLayout/LeftPanel/BattleLogPanel
@onready var ship_panel: Control = $MainLayout/LeftPanel/ShipPanelContainer
@onready var player_turn_label: Label = $TopBar/PlayerTurnLabel
@onready var end_turn_button: Button = $TopBar/EndTurnButton

var active_grid: ActiveGrid = ActiveGrid.COMMAND
var is_panning: bool = false
var pan_start_mouse: Vector2 = Vector2.ZERO
var pan_start_cam: Vector2 = Vector2.ZERO
var active_camera: Camera2D

func _ready() -> void:
	GameState.phase = GameState.Phase.GAMEPLAY
	_update_player_label()
	_switch_grid(ActiveGrid.COMMAND)
	_show_left_tab("battle_log")
	# TurnManager not yet implemented — placeholder
	print("TurnManager.turn_start() — not yet implemented")

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
	ship_panel.visible = (tab == "ship_panel")
	battle_log_tab_btn.modulate = Color.WHITE if tab == "battle_log" else Color(0.6, 0.6, 0.6)
	ship_panel_tab_btn.modulate = Color.WHITE if tab == "ship_panel" else Color(0.6, 0.6, 0.6)

func _on_command_grid_pressed() -> void:
	AudioManager.play_sfx("click")
	_switch_grid(ActiveGrid.COMMAND)

func _on_target_grid_pressed() -> void:
	AudioManager.play_sfx("click")
	_switch_grid(ActiveGrid.TARGET)

func _on_battle_log_tab_pressed() -> void:
	_show_left_tab("battle_log")

func _on_ship_panel_tab_pressed() -> void:
	_show_left_tab("ship_panel")

func _on_command_viewport_gui_input(event: InputEvent) -> void:
	_handle_grid_input(event, command_camera)

func _on_target_viewport_gui_input(event: InputEvent) -> void:
	_handle_grid_input(event, target_camera)

func _handle_grid_input(event: InputEvent, cam: Camera2D) -> void:
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
	elif event is InputEventMouseMotion:
		if is_panning and (event.button_mask & MOUSE_BUTTON_MASK_MIDDLE):
			var delta: Vector2 = (pan_start_mouse - event.position) / cam.zoom
			cam.position = pan_start_cam + delta
			_clamp_camera(cam)

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
	AudioManager.play_sfx("click")
	# TurnManager.turn_end() — not yet implemented
	print("TurnManager.turn_end() — not yet implemented")
	GameState.last_turn_hits = 0
	GameState.current_player = 1 - GameState.current_player
	get_tree().change_scene_to_file("res://scenes/handoff.tscn")
