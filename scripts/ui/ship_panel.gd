extends Control

signal action_requested(action: String, ship: ShipInstance)
signal ship_selected(ship: ShipInstance)
signal ship_deselected()

# Accordion of the current player's fleet (5 rows). Each row has a header
# Button (ship type name) and a hideable detail VBox containing the dense
# stats / sliders / action buttons that used to live in the single-ship
# Ship Panel pre-I10. Enemy-ship view (clicking a probed enemy on the
# Target Grid) hides the accordion entirely and shows a stripped read-only
# panel in its place; hide_enemy_panel restores the accordion.

var _accordion: VBoxContainer = null
var _enemy_panel: VBoxContainer = null
var _enemy_name_label: Label = null
var _enemy_stats_label: Label = null

# Per-row state. Each entry: {
#   ship: ShipInstance,
#   root: Control, header: Button, detail: VBoxContainer,
#   shield_slider: HSlider, shield_value_label: Label,
#   laser_slider: HSlider, laser_value_label: Label,
#   energy_remaining_label: Label,
#   probe_btn, laser_btn, missile_btn, move_btn: Button,
# }
var _rows: Array = []
var _expanded_ship: ShipInstance = null


func _ready() -> void:
	_build_static_ui()
	refresh_for_turn()


func _build_static_ui() -> void:
	# Accordion column — the always-visible default state.
	_accordion = VBoxContainer.new()
	_accordion.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_accordion.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_accordion)

	# Enemy panel — hidden by default; takes over the panel area when a
	# probed enemy ship is selected on the Target Grid.
	_enemy_panel = VBoxContainer.new()
	_enemy_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_enemy_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_enemy_panel.visible = false
	add_child(_enemy_panel)

	_enemy_name_label = Label.new()
	_enemy_name_label.add_theme_font_size_override("font_size", 14)
	_enemy_name_label.add_theme_color_override("font_color", Color(1.0, 0.55, 0.5))
	_enemy_panel.add_child(_enemy_name_label)

	_enemy_stats_label = Label.new()
	_enemy_stats_label.add_theme_font_size_override("font_size", 11)
	_enemy_stats_label.add_theme_color_override("font_color", Color(0.7, 0.77, 0.8))
	_enemy_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_enemy_panel.add_child(_enemy_stats_label)


# Tear down and rebuild rows for the current player's fleet. Called on
# every turn start so P1's accordion isn't lingering on P2's screen.
func refresh_for_turn() -> void:
	_expanded_ship = null
	for row in _rows:
		(row["root"] as Control).queue_free()
	_rows.clear()

	var fleet: Array = GameState.players[GameState.current_player]["fleet"]
	for ship in fleet:
		_rows.append(_build_row(ship))

	# Default state on every turn start: collapsed, accordion visible.
	hide_enemy_panel()


func _build_row(ship: ShipInstance) -> Dictionary:
	var row: Dictionary = {"ship": ship}

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_accordion.add_child(root)
	row["root"] = root

	var header := Button.new()
	header.text = _row_header_text(ship)
	header.alignment = HORIZONTAL_ALIGNMENT_LEFT
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_theme_font_size_override("font_size", 13)
	if ship.is_destroyed:
		header.modulate = Color(0.5, 0.5, 0.5)
	header.pressed.connect(func() -> void: _on_header_pressed(ship))
	root.add_child(header)
	row["header"] = header

	var detail := VBoxContainer.new()
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail.visible = false
	root.add_child(detail)
	row["detail"] = detail

	_build_detail_panel(detail, row)
	return row


# Builds the dense single-ship widgets — stats label, shield/laser sliders,
# energy-after-use, action buttons — into the given detail VBox. References
# to the live widgets are stashed on `row` so _refresh_row can update them.
func _build_detail_panel(detail: VBoxContainer, row: Dictionary) -> void:
	var ship: ShipInstance = row["ship"]
	var stats: Dictionary = ShipDefinitions.SHIPS[ship.ship_type]

	var stats_label := Label.new()
	stats_label.add_theme_font_size_override("font_size", 11)
	stats_label.add_theme_color_override("font_color", Color(0.7, 0.77, 0.8))
	stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	detail.add_child(stats_label)
	row["stats_label"] = stats_label

	detail.add_child(_make_separator())

	var shield_box := HBoxContainer.new()
	var shield_label := Label.new()
	shield_label.text = "Shield Regen:"
	shield_label.add_theme_font_size_override("font_size", 11)
	shield_box.add_child(shield_label)
	var shield_slider := HSlider.new()
	shield_slider.min_value = 0
	shield_slider.max_value = 250
	shield_slider.step = 50
	shield_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shield_slider.custom_minimum_size = Vector2(60, 0)
	shield_slider.value_changed.connect(func(v: float) -> void: _on_shield_slider_changed(row, v))
	shield_box.add_child(shield_slider)
	var shield_value_label := Label.new()
	shield_value_label.add_theme_font_size_override("font_size", 11)
	shield_value_label.custom_minimum_size = Vector2(35, 0)
	shield_box.add_child(shield_value_label)
	detail.add_child(shield_box)
	row["shield_slider"] = shield_slider
	row["shield_value_label"] = shield_value_label

	var laser_box := HBoxContainer.new()
	var laser_label := Label.new()
	laser_label.text = "Laser Power:"
	laser_label.add_theme_font_size_override("font_size", 11)
	laser_box.add_child(laser_label)
	var laser_slider := HSlider.new()
	laser_slider.min_value = 0
	laser_slider.max_value = stats["laser_max"]
	laser_slider.step = 50
	laser_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	laser_slider.custom_minimum_size = Vector2(60, 0)
	laser_slider.value_changed.connect(func(v: float) -> void: _on_laser_slider_changed(row, v))
	laser_box.add_child(laser_slider)
	var laser_value_label := Label.new()
	laser_value_label.add_theme_font_size_override("font_size", 11)
	laser_value_label.custom_minimum_size = Vector2(35, 0)
	laser_box.add_child(laser_value_label)
	detail.add_child(laser_box)
	row["laser_slider"] = laser_slider
	row["laser_value_label"] = laser_value_label

	var energy_remaining_label := Label.new()
	energy_remaining_label.add_theme_font_size_override("font_size", 11)
	energy_remaining_label.add_theme_color_override("font_color", Color(0.6, 0.9, 0.6))
	detail.add_child(energy_remaining_label)
	row["energy_remaining_label"] = energy_remaining_label

	detail.add_child(_make_separator())

	var actions_label := Label.new()
	actions_label.text = "Actions:"
	actions_label.add_theme_font_size_override("font_size", 12)
	actions_label.add_theme_color_override("font_color", Color(0.8, 0.85, 0.67))
	detail.add_child(actions_label)

	var probe_btn := Button.new()
	probe_btn.text = "Launch Probe"
	probe_btn.pressed.connect(func() -> void: _emit_action("probe", ship))
	detail.add_child(probe_btn)
	row["probe_btn"] = probe_btn

	var laser_btn := Button.new()
	laser_btn.text = "Shoot Laser"
	laser_btn.pressed.connect(func() -> void: _emit_action("laser", ship))
	detail.add_child(laser_btn)
	row["laser_btn"] = laser_btn

	var missile_btn := Button.new()
	missile_btn.text = "Launch Missile"
	missile_btn.pressed.connect(func() -> void: _emit_action("missile", ship))
	detail.add_child(missile_btn)
	row["missile_btn"] = missile_btn

	var move_btn := Button.new()
	move_btn.text = "Move Ship"
	move_btn.pressed.connect(func() -> void: _emit_action("move", ship))
	detail.add_child(move_btn)
	row["move_btn"] = move_btn

	# Bottom rule so the expanded detail visibly closes off before the next
	# row's collapsed header — without this the Move Ship button sits flush
	# against the next ship name and reads like one block.
	detail.add_child(_make_separator())


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

# Headless expand — used by gameplay.gd when a friendly ship is clicked on
# the Command Grid. Does NOT emit ship_selected to avoid feeding back into
# the Command Grid selection caller.
func expand_row_for_ship(ship: ShipInstance) -> void:
	hide_enemy_panel()
	for row in _rows:
		if (row["ship"] as ShipInstance) == ship:
			_expand_row_internal(row)
			return


func collapse_all() -> void:
	for row in _rows:
		(row["detail"] as Control).visible = false
	_expanded_ship = null


func show_enemy_ship(fog: FogShipRecord) -> void:
	collapse_all()
	_accordion.visible = false
	_enemy_panel.visible = true

	var stats: Dictionary = ShipDefinitions.SHIPS[fog.ship_type]
	var display_name: String = (fog.ship_type as String).capitalize()
	_enemy_name_label.text = display_name + " (Enemy)"
	_enemy_stats_label.text = (
		"Shields: %d / %d\n" % [fog.last_shields, stats["max_shields"]] +
		"Armor: %d / %d" % [fog.last_armor, stats["max_armor"]]
	)


func hide_enemy_panel() -> void:
	_enemy_panel.visible = false
	_accordion.visible = true


# Refreshes the currently-expanded row's widgets. Call after any state
# change (action fired, slider auto-clamped, etc.) so the panel reflects
# the live ship state.
func refresh_expanded() -> void:
	if _expanded_ship == null:
		return
	for row in _rows:
		if (row["ship"] as ShipInstance) == _expanded_ship:
			_refresh_row(row)
			_refresh_header(row)
			return


# ---------------------------------------------------------------------------
# Internals
# ---------------------------------------------------------------------------

func _on_header_pressed(ship: ShipInstance) -> void:
	if ship.is_destroyed:
		return  # destroyed rows are inert per spec
	AudioManager.play_sfx("click")
	for row in _rows:
		if (row["ship"] as ShipInstance) != ship:
			continue
		var was_expanded: bool = (row["detail"] as Control).visible
		if was_expanded:
			(row["detail"] as Control).visible = false
			_expanded_ship = null
			ship_deselected.emit()
		else:
			_expand_row_internal(row)
			ship_selected.emit(ship)
		return


func _expand_row_internal(target_row: Dictionary) -> void:
	for row in _rows:
		(row["detail"] as Control).visible = (row == target_row)
	_expanded_ship = target_row["ship"]
	_refresh_row(target_row)
	_refresh_header(target_row)


func _refresh_header(row: Dictionary) -> void:
	var ship: ShipInstance = row["ship"]
	var header: Button = row["header"]
	header.text = _row_header_text(ship)
	if ship.is_destroyed:
		header.modulate = Color(0.5, 0.5, 0.5)
	else:
		header.modulate = Color.WHITE


func _row_header_text(ship: ShipInstance) -> String:
	var name_text: String = (ship.ship_type as String).capitalize()
	if ship.is_destroyed:
		name_text += " (destroyed)"
	return name_text


func _refresh_row(row: Dictionary) -> void:
	var ship: ShipInstance = row["ship"]
	var stats: Dictionary = ShipDefinitions.SHIPS[ship.ship_type]
	var stats_label: Label = row["stats_label"]
	stats_label.text = (
		"Shields: %d / %d\n" % [ship.current_shields, stats["max_shields"]] +
		"Armor: %d / %d\n" % [ship.current_armor, stats["max_armor"]] +
		"Energy: %d / %d\n" % [ship.current_energy, stats["max_energy"]] +
		"Missiles: %d\n" % ship.missiles_remaining +
		"Probes: %d" % ship.probes_remaining
	)

	var laser_slider: HSlider = row["laser_slider"]
	laser_slider.max_value = stats["laser_max"]

	# Cap any combined slider setting that exceeds the ship's current energy
	# (e.g., after an action drained it). Shields take priority.
	var combined: int = ship.shield_regen_setting + ship.laser_power_setting
	if combined > ship.current_energy:
		ship.shield_regen_setting = mini(ship.shield_regen_setting, ship.current_energy)
		ship.laser_power_setting = mini(
			ship.laser_power_setting,
			ship.current_energy - ship.shield_regen_setting)

	var shield_slider: HSlider = row["shield_slider"]
	shield_slider.set_value_no_signal(ship.shield_regen_setting)
	laser_slider.set_value_no_signal(ship.laser_power_setting)
	_update_slider_labels(row)

	var can_move: bool = ship.move_actions_taken < 1 and not ship.action_taken and not ship.is_destroyed
	var can_act: bool = not ship.action_taken and not ship.is_destroyed
	var has_probes: bool = ship.probes_remaining > 0 and ship.current_energy >= stats["probe_cost"]
	var has_missiles: bool = ship.missiles_remaining > 0
	var has_laser_energy: bool = ship.laser_power_setting > 0

	var probe_btn: Button = row["probe_btn"]
	var laser_btn: Button = row["laser_btn"]
	var missile_btn: Button = row["missile_btn"]
	var move_btn: Button = row["move_btn"]
	probe_btn.disabled = not (can_act and has_probes)
	laser_btn.disabled = not (can_act and has_laser_energy)
	missile_btn.disabled = not (can_act and has_missiles)
	move_btn.disabled = not can_move

	probe_btn.tooltip_text = "" if not probe_btn.disabled else "No probes or energy"
	laser_btn.tooltip_text = "" if not laser_btn.disabled else "Set laser power first"
	missile_btn.tooltip_text = "" if not missile_btn.disabled else "No missiles remaining"
	move_btn.tooltip_text = "" if not move_btn.disabled else "No move actions left"


func _update_slider_labels(row: Dictionary) -> void:
	var ship: ShipInstance = row["ship"]
	var shield_slider: HSlider = row["shield_slider"]
	var laser_slider: HSlider = row["laser_slider"]
	(row["shield_value_label"] as Label).text = str(int(shield_slider.value))
	(row["laser_value_label"] as Label).text = str(int(laser_slider.value))
	var used: int = int(shield_slider.value) + int(laser_slider.value)
	var remaining: int = ship.current_energy - used
	(row["energy_remaining_label"] as Label).text = "Energy after use: %d" % remaining


func _on_shield_slider_changed(row: Dictionary, value: float) -> void:
	var ship: ShipInstance = row["ship"]
	# I8-9: any user-driven change locks out the auto-set forever for this ship.
	# Programmatic writes use set_value_no_signal (see _refresh_row), so this
	# only fires on real user interaction.
	ship.shield_regen_manually_set = true
	var shield_val: int = int(value)
	var laser_slider: HSlider = row["laser_slider"]
	var laser_val: int = int(laser_slider.value)
	if shield_val + laser_val > ship.current_energy:
		laser_val = max(ship.current_energy - shield_val, 0)
		laser_slider.set_value_no_signal(laser_val)
	ship.shield_regen_setting = shield_val
	ship.laser_power_setting = laser_val
	_refresh_row(row)


func _on_laser_slider_changed(row: Dictionary, value: float) -> void:
	var ship: ShipInstance = row["ship"]
	var laser_val: int = int(value)
	var shield_slider: HSlider = row["shield_slider"]
	var shield_val: int = int(shield_slider.value)
	if shield_val + laser_val > ship.current_energy:
		laser_val = ship.current_energy - shield_val
		(row["laser_slider"] as HSlider).set_value_no_signal(laser_val)
	ship.shield_regen_setting = shield_val
	ship.laser_power_setting = laser_val
	_refresh_row(row)


func _emit_action(action: String, ship: ShipInstance) -> void:
	AudioManager.play_sfx("click")
	action_requested.emit(action, ship)


func _make_separator() -> HSeparator:
	var sep := HSeparator.new()
	sep.add_theme_constant_override("separation", 6)
	return sep
