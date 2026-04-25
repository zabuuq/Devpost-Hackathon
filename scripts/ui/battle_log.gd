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
	vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER


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
	# Ensure only the topmost entry is emphasized after a full render.
	for i in range(_content.get_child_count()):
		var child: Node = _content.get_child(i)
		if child is RichTextLabel:
			_apply_emphasis(child as RichTextLabel, i == 0)


func _insert_entry_at_top(entry: Dictionary) -> void:
	var label: RichTextLabel = _build_entry_label(entry)
	if label == null:
		return
	# Downgrade the previously-top child before inserting the new one.
	if _content.get_child_count() > 0:
		var previous_top: Node = _content.get_child(0)
		if previous_top is RichTextLabel:
			_apply_emphasis(previous_top as RichTextLabel, false)
	_content.add_child(label)
	_content.move_child(label, 0)
	_apply_emphasis(label, true)
	await get_tree().process_frame
	scroll_vertical = 0


func _append_entry_label(entry: Dictionary) -> void:
	var label: RichTextLabel = _build_entry_label(entry)
	if label == null:
		return
	_content.add_child(label)


func _build_entry_label(entry: Dictionary) -> RichTextLabel:
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
			if entry.get("destroyed", false) and entry.get("has_probe", false):
				color = COLOR_DESTROY
			elif entry.get("hit", false):
				color = COLOR_HIT
			else:
				color = COLOR_MISS
		"move":
			text = _format_move(entry)
			color = COLOR_MOVE
		"empty_report":
			text = "Nothing to report."
			color = COLOR_MISS
		_:
			text = str(entry)

	var label: RichTextLabel = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.scroll_active = false
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_color_override("default_color", color)
	label.add_theme_font_size_override("normal_font_size", 13)
	label.add_theme_font_size_override("bold_font_size", 13)
	label.set_meta("plain_text", text)
	label.set_meta("is_divider", action_type == "divider")
	if action_type == "divider":
		label.add_theme_font_size_override("normal_font_size", 12)
		label.add_theme_font_size_override("bold_font_size", 12)
	label.text = _escape_bbcode(text)
	return label


func _apply_emphasis(label: RichTextLabel, emphasized: bool) -> void:
	if label == null:
		return
	var plain: String = str(label.get_meta("plain_text", ""))
	var is_divider: bool = bool(label.get_meta("is_divider", false))
	var escaped: String = _escape_bbcode(plain)
	if emphasized and not is_divider:
		label.text = "[b]%s[/b]" % escaped
	else:
		label.text = escaped


func _escape_bbcode(s: String) -> String:
	return s.replace("[", "[lb]")


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
	var owner: int = result.get("owner", 0)
	var target: Vector2i = result.get("target", Vector2i.ZERO)

	if not hit:
		if owner == 1:
			var near_ships: Array = result.get("near_miss_ships", [])
			if near_ships.is_empty():
				return "%s %s fired at (%d, %d). Miss." % [ship, weapon, target.x, target.y]
			var counts: Dictionary = {}
			var order: Array[String] = []
			for ship_type in near_ships:
				var key: String = str(ship_type)
				if counts.has(key):
					counts[key] = int(counts[key]) + 1
				else:
					counts[key] = 1
					order.append(key)
			var names: Array[String] = []
			for key in order:
				var display: String = _ship_name(key)
				if int(counts[key]) > 1:
					display += "s"
				names.append(display)
			return "%s %s fired at (%d, %d). Miss. Near miss to your %s." % [ship, weapon, target.x, target.y, _join_names(names)]
		return "%s %s fired. Miss." % [ship, weapon]

	var has_probe: bool = result.get("has_probe", false)
	var destroyed: bool = result.get("destroyed", false)
	var shields_depleted: bool = result.get("shields_depleted", false)

	if owner == 1:
		var defender_text: String = "%s %s fired at (%d, %d). Hit." % [ship, weapon, target.x, target.y]
		if destroyed:
			var destroyed_name: String = _ship_name(result.get("target_ship_type", ""))
			defender_text += " Your %s was destroyed." % destroyed_name
		else:
			var hit_name: String = _ship_name(result.get("target_ship_type", ""))
			defender_text += " Your %s was hit." % hit_name
		return defender_text

	var text: String
	if has_probe:
		var shield_dmg: int = result.get("shield_damage", 0)
		var armor_dmg: int = result.get("armor_damage", 0)
		if shield_dmg > 0 and armor_dmg > 0:
			if shields_depleted:
				text = "%s %s fired at (%d, %d). Hit — %d shield damage. Shields down! %d armor damage." % [ship, weapon, target.x, target.y, shield_dmg, armor_dmg]
			else:
				text = "%s %s fired at (%d, %d). Hit — %d shield damage, %d armor damage." % [ship, weapon, target.x, target.y, shield_dmg, armor_dmg]
		elif shield_dmg > 0:
			if shields_depleted:
				text = "%s %s fired at (%d, %d). Hit — %d shield damage. Shields down!" % [ship, weapon, target.x, target.y, shield_dmg]
			else:
				text = "%s %s fired at (%d, %d). Hit — %d shield damage." % [ship, weapon, target.x, target.y, shield_dmg]
		else:
			text = "%s %s fired at (%d, %d). Hit — %d armor damage." % [ship, weapon, target.x, target.y, armor_dmg]
	else:
		text = "%s %s fired. Hit." % [ship, weapon]

	if destroyed and has_probe:
		var target_name: String = _ship_name(result.get("target_ship_type", ""))
		text += " %s destroyed." % target_name

	return text


func _join_names(names: Array[String]) -> String:
	if names.size() == 0:
		return ""
	if names.size() == 1:
		return names[0]
	if names.size() == 2:
		return "%s and %s" % [names[0], names[1]]
	var head: String = ", ".join(names.slice(0, names.size() - 1))
	return "%s, and %s" % [head, names[names.size() - 1]]


func _format_move(result: Dictionary) -> String:
	var ship: String = _ship_name(result.get("ship_type", ""))
	return "%s moved." % ship
