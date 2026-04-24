extends Control

signal action_requested(action: String, ship: ShipInstance)

var _ship: ShipInstance = null
var _container: VBoxContainer = null
var _empty_label: Label = null

# UI references
var _name_label: Label = null
var _stats_label: Label = null
var _shield_slider: HSlider = null
var _shield_value_label: Label = null
var _laser_slider: HSlider = null
var _laser_value_label: Label = null
var _energy_remaining_label: Label = null
var _probe_btn: Button = null
var _laser_btn: Button = null
var _missile_btn: Button = null
var _move_btn: Button = null


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	# Cache sibling "Click a ship..." label so we can hide it whenever a ship
	# is selected (otherwise it bleeds through above the populated panel).
	_empty_label = get_parent().get_node_or_null("ShipPanelEmpty") as Label

	_container = VBoxContainer.new()
	_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_container)

	# Ship name
	_name_label = Label.new()
	_name_label.add_theme_font_size_override("font_size", 14)
	_name_label.add_theme_color_override("font_color", Color(0.36, 0.88, 0.82))
	_container.add_child(_name_label)

	# Stats
	_stats_label = Label.new()
	_stats_label.add_theme_font_size_override("font_size", 11)
	_stats_label.add_theme_color_override("font_color", Color(0.7, 0.77, 0.8))
	_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_container.add_child(_stats_label)

	# Separator
	_container.add_child(_make_separator())

	# Shield regen slider
	var shield_box: HBoxContainer = HBoxContainer.new()
	var shield_label: Label = Label.new()
	shield_label.text = "Shield Regen:"
	shield_label.add_theme_font_size_override("font_size", 11)
	shield_box.add_child(shield_label)
	_shield_slider = HSlider.new()
	_shield_slider.min_value = 0
	_shield_slider.max_value = 250
	_shield_slider.step = 50
	_shield_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_shield_slider.custom_minimum_size = Vector2(60, 0)
	_shield_slider.value_changed.connect(_on_shield_slider_changed)
	shield_box.add_child(_shield_slider)
	_shield_value_label = Label.new()
	_shield_value_label.add_theme_font_size_override("font_size", 11)
	_shield_value_label.custom_minimum_size = Vector2(35, 0)
	shield_box.add_child(_shield_value_label)
	_container.add_child(shield_box)

	# Laser power slider
	var laser_box: HBoxContainer = HBoxContainer.new()
	var laser_label: Label = Label.new()
	laser_label.text = "Laser Power:"
	laser_label.add_theme_font_size_override("font_size", 11)
	laser_box.add_child(laser_label)
	_laser_slider = HSlider.new()
	_laser_slider.min_value = 0
	_laser_slider.max_value = 500
	_laser_slider.step = 50
	_laser_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_laser_slider.custom_minimum_size = Vector2(60, 0)
	_laser_slider.value_changed.connect(_on_laser_slider_changed)
	laser_box.add_child(_laser_slider)
	_laser_value_label = Label.new()
	_laser_value_label.add_theme_font_size_override("font_size", 11)
	_laser_value_label.custom_minimum_size = Vector2(35, 0)
	laser_box.add_child(_laser_value_label)
	_container.add_child(laser_box)

	# Energy remaining after sliders
	_energy_remaining_label = Label.new()
	_energy_remaining_label.add_theme_font_size_override("font_size", 11)
	_energy_remaining_label.add_theme_color_override("font_color", Color(0.6, 0.9, 0.6))
	_container.add_child(_energy_remaining_label)

	# Separator
	_container.add_child(_make_separator())

	# Action buttons
	var action_label: Label = Label.new()
	action_label.text = "Actions:"
	action_label.add_theme_font_size_override("font_size", 12)
	action_label.add_theme_color_override("font_color", Color(0.8, 0.85, 0.67))
	_container.add_child(action_label)

	_probe_btn = Button.new()
	_probe_btn.text = "Launch Probe"
	_probe_btn.pressed.connect(func() -> void: _emit_action("probe"))
	_container.add_child(_probe_btn)

	_laser_btn = Button.new()
	_laser_btn.text = "Shoot Laser"
	_laser_btn.pressed.connect(func() -> void: _emit_action("laser"))
	_container.add_child(_laser_btn)

	_missile_btn = Button.new()
	_missile_btn.text = "Launch Missile"
	_missile_btn.pressed.connect(func() -> void: _emit_action("missile"))
	_container.add_child(_missile_btn)

	_move_btn = Button.new()
	_move_btn.text = "Move Ship"
	_move_btn.pressed.connect(func() -> void: _emit_action("move"))
	_container.add_child(_move_btn)

	# Start hidden until a ship is selected
	_container.visible = false


func show_ship(ship: ShipInstance) -> void:
	_ship = ship
	_container.visible = true
	if _empty_label != null:
		_empty_label.visible = false
	# Restore visibility of controls that show_enemy_ship may have hidden
	_shield_slider.get_parent().visible = true
	_laser_slider.get_parent().visible = true
	_energy_remaining_label.visible = true
	_probe_btn.visible = true
	_laser_btn.visible = true
	_missile_btn.visible = true
	_move_btn.visible = true
	_refresh_display()


func show_enemy_ship(fog: FogShipRecord) -> void:
	_ship = null
	_container.visible = true
	if _empty_label != null:
		_empty_label.visible = false
	var stats: Dictionary = ShipDefinitions.SHIPS[fog.ship_type]
	var display_name: String = fog.ship_type.replace("_", " ").capitalize()

	_name_label.text = display_name + " (Enemy)"
	_stats_label.text = (
		"Shields: %d / %d\n" % [fog.last_shields, stats["max_shields"]] +
		"Armor: %d / %d" % [fog.last_armor, stats["max_armor"]]
	)

	# Hide sliders and action buttons for enemy ships
	_shield_slider.get_parent().visible = false
	_laser_slider.get_parent().visible = false
	_energy_remaining_label.visible = false
	_probe_btn.visible = false
	_laser_btn.visible = false
	_missile_btn.visible = false
	_move_btn.visible = false


func clear_ship() -> void:
	_ship = null
	if _container:
		_container.visible = false
		# Restore visibility of controls hidden by show_enemy_ship
		_shield_slider.get_parent().visible = true
		_laser_slider.get_parent().visible = true
		_energy_remaining_label.visible = true
		_probe_btn.visible = true
		_laser_btn.visible = true
		_missile_btn.visible = true
		_move_btn.visible = true
	if _empty_label != null:
		_empty_label.visible = true


func _refresh_display() -> void:
	if _ship == null:
		return

	var stats: Dictionary = ShipDefinitions.SHIPS[_ship.ship_type]
	var display_name: String = _ship.ship_type.replace("_", " ").capitalize()

	_name_label.text = display_name
	_stats_label.text = (
		"Shields: %d / %d\n" % [_ship.current_shields, stats["max_shields"]] +
		"Armor: %d / %d\n" % [_ship.current_armor, stats["max_armor"]] +
		"Energy: %d / %d\n" % [_ship.current_energy, stats["max_energy"]] +
		"Missiles: %d\n" % _ship.missiles_remaining +
		"Probes: %d" % _ship.probes_remaining
	)

	# Update slider max values based on ship type
	var laser_max: int = stats["laser_max"]
	_laser_slider.max_value = laser_max

	# Recalculate sliders if they exceed available energy after actions
	var combined: int = _ship.shield_regen_setting + _ship.laser_power_setting
	if combined > _ship.current_energy:
		_ship.shield_regen_setting = mini(_ship.shield_regen_setting, _ship.current_energy)
		_ship.laser_power_setting = mini(_ship.laser_power_setting, _ship.current_energy - _ship.shield_regen_setting)

	# Set slider values from ship settings
	_shield_slider.set_value_no_signal(_ship.shield_regen_setting)
	_laser_slider.set_value_no_signal(_ship.laser_power_setting)
	_update_slider_labels()

	# Update action button states
	var can_move: bool = _ship.move_actions_taken < 1 and not _ship.action_taken and not _ship.is_destroyed
	var can_act: bool = not _ship.action_taken and not _ship.is_destroyed
	var has_probes: bool = _ship.probes_remaining > 0 and _ship.current_energy >= stats["probe_cost"]
	var has_missiles: bool = _ship.missiles_remaining > 0
	var has_laser_energy: bool = _ship.laser_power_setting > 0

	_probe_btn.disabled = not (can_act and has_probes)
	_laser_btn.disabled = not (can_act and has_laser_energy)
	_missile_btn.disabled = not (can_act and has_missiles)
	_move_btn.disabled = not can_move

	_probe_btn.tooltip_text = "" if not _probe_btn.disabled else "No probes or energy"
	_laser_btn.tooltip_text = "" if not _laser_btn.disabled else "Set laser power first"
	_missile_btn.tooltip_text = "" if not _missile_btn.disabled else "No missiles remaining"
	_move_btn.tooltip_text = "" if not _move_btn.disabled else "No move actions left"


func _update_slider_labels() -> void:
	if _ship == null:
		return
	_shield_value_label.text = str(int(_shield_slider.value))
	_laser_value_label.text = str(int(_laser_slider.value))
	var used: int = int(_shield_slider.value) + int(_laser_slider.value)
	var remaining: int = _ship.current_energy - used
	_energy_remaining_label.text = "Energy after sliders: %d" % remaining


func _on_shield_slider_changed(value: float) -> void:
	if _ship == null:
		return
	var shield_val: int = int(value)
	var laser_val: int = int(_laser_slider.value)
	# Cap combined to current energy — shields have priority
	if shield_val + laser_val > _ship.current_energy:
		laser_val = max(_ship.current_energy - shield_val, 0)
		_laser_slider.set_value_no_signal(laser_val)
	_ship.shield_regen_setting = shield_val
	_ship.laser_power_setting = laser_val
	_refresh_display()


func _on_laser_slider_changed(value: float) -> void:
	if _ship == null:
		return
	var laser_val: int = int(value)
	var shield_val: int = int(_shield_slider.value)
	# Cap combined to current energy — shields have priority
	if shield_val + laser_val > _ship.current_energy:
		laser_val = _ship.current_energy - shield_val
		_laser_slider.set_value_no_signal(laser_val)
	_ship.shield_regen_setting = shield_val
	_ship.laser_power_setting = laser_val
	_refresh_display()


func _emit_action(action: String) -> void:
	if _ship == null:
		return
	AudioManager.play_sfx("click")
	action_requested.emit(action, _ship)


func _make_separator() -> HSeparator:
	var sep := HSeparator.new()
	sep.add_theme_constant_override("separation", 6)
	return sep
