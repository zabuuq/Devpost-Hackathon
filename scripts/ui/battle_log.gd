extends ScrollContainer
## Battle log panel — displays a scrollable list of action results.
## Attached to BattleLogPanel (ScrollContainer) in gameplay.tscn.

const SHIP_DISPLAY_NAMES: Dictionary = {
	"battleship": "Battleship",
	"probe_ship": "Probe Ship",
	"destroyer": "Destroyer",
	"cruiser": "Cruiser",
}

const COLOR_HIT: Color = Color(1.0, 0.6, 0.5)
const COLOR_DESTROY: Color = Color(1.0, 0.3, 0.2)
const COLOR_MISS: Color = Color(0.6, 0.6, 0.65)
const COLOR_PROBE: Color = Color(0.4, 0.85, 0.82)
const COLOR_MOVE: Color = Color(0.7, 0.85, 0.7)
const COLOR_DIVIDER: Color = Color(0.45, 0.5, 0.55)

var _content: VBoxContainer = null
var _placeholder_cleared: bool = false


func _ready() -> void:
	_content = $BattleLogContent as VBoxContainer


func _ship_name(ship_type: String) -> String:
	if ship_type == "enemy":
		return "Enemy"
	if SHIP_DISPLAY_NAMES.has(ship_type):
		return SHIP_DISPLAY_NAMES[ship_type]
	return ship_type.capitalize()


func _clear_placeholder() -> void:
	if _placeholder_cleared:
		return
	_placeholder_cleared = true
	var placeholder: Label = _content.get_node_or_null("BattleLogEmpty")
	if placeholder:
		placeholder.queue_free()


func add_entry(result: Dictionary) -> void:
	var entry: Dictionary = result.duplicate()
	if not entry.has("turn_number"):
		entry["turn_number"] = GameState.turn_number
	if not entry.has("owner"):
		entry["owner"] = 0
	GameState.append_battle_log(GameState.current_player, entry)
	_clear_placeholder()
	_insert_entry_at_top(entry)


func render_from_state() -> void:
	if _content == null:
		return
	for child in _content.get_children():
		child.queue_free()
	_placeholder_cleared = true

	var log: Array = GameState.players[GameState.current_player]["battle_log"]
	if log.is_empty():
		var empty_label: Label = Label.new()
		empty_label.name = "BattleLogEmpty"
		empty_label.text = "No events yet."
		empty_label.add_theme_font_size_override("font_size", 12)
		empty_label.add_theme_color_override("font_color", Color(0.5, 0.58, 0.62))
		_content.add_child(empty_label)
		_placeholder_cleared = false
		return

	for i in range(log.size() - 1, -1, -1):
		_append_entry_label(log[i])


func _insert_entry_at_top(entry: Dictionary) -> void:
	var label: Label = _build_entry_label(entry)
	if label == null:
		return
	_content.add_child(label)
	_content.move_child(label, 0)
	await get_tree().process_frame
	scroll_vertical = 0


func _append_entry_label(entry: Dictionary) -> void:
	var label: Label = _build_entry_label(entry)
	if label == null:
		return
	_content.add_child(label)


func _build_entry_label(entry: Dictionary) -> Label:
	var action_type: String = entry.get("type", "")
	var text: String = ""
	var color: Color = COLOR_MISS

	match action_type:
		"divider":
			text = _format_divider(entry)
			color = COLOR_DIVIDER
		"probe":
			text = _format_probe(entry)
			color = COLOR_PROBE
		"laser", "missile":
			text = _format_fire(entry)
			if entry.get("destroyed", false):
				color = COLOR_DESTROY
			elif entry.get("hit", false):
				color = COLOR_HIT
			else:
				color = COLOR_MISS
		"move":
			text = _format_move(entry)
			color = COLOR_MOVE
		_:
			text = str(entry)

	var label: Label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 13)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if action_type == "divider":
		label.add_theme_font_size_override("font_size", 12)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label


func _format_divider(entry: Dictionary) -> String:
	var turn_num: int = entry.get("turn_number", 0)
	var is_opponent: bool = entry.get("is_opponent", false)
	if is_opponent:
		return "— Enemy Turn %d —" % turn_num
	return "— Turn %d —" % turn_num


func _format_probe(result: Dictionary) -> String:
	var ship: String = _ship_name(result.get("ship_type", ""))
	var target: Vector2i = result.get("target", Vector2i.ZERO)
	var detected: int = result.get("ships_detected", 0)
	return "%s probe deployed at (%d, %d). %d ships detected." % [ship, target.x, target.y, detected]


func _format_fire(result: Dictionary) -> String:
	var ship: String = _ship_name(result.get("ship_type", ""))
	var weapon: String = result.get("type", "laser")
	var hit: bool = result.get("hit", false)

	if not hit:
		return "%s %s fired. Miss." % [ship, weapon]

	var has_probe: bool = result.get("has_probe", false)
	var destroyed: bool = result.get("destroyed", false)
	var target: Vector2i = result.get("target", Vector2i.ZERO)

	var text: String
	if has_probe:
		var shield_dmg: int = result.get("shield_damage", 0)
		var armor_dmg: int = result.get("armor_damage", 0)
		if shield_dmg > 0 and armor_dmg > 0:
			text = "%s %s fired at (%d, %d). Hit — %d shield damage, %d armor damage." % [ship, weapon, target.x, target.y, shield_dmg, armor_dmg]
		elif shield_dmg > 0:
			text = "%s %s fired at (%d, %d). Hit — %d shield damage." % [ship, weapon, target.x, target.y, shield_dmg]
		else:
			text = "%s %s fired at (%d, %d). Hit — %d armor damage." % [ship, weapon, target.x, target.y, armor_dmg]
	else:
		text = "%s %s fired. Hit." % [ship, weapon]

	if destroyed:
		var target_name: String = _ship_name(result.get("target_ship_type", ""))
		text += " %s destroyed." % target_name

	return text


func _format_move(result: Dictionary) -> String:
	var ship: String = _ship_name(result.get("ship_type", ""))
	return "%s moved." % ship
