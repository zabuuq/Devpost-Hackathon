extends ScrollContainer
## Battle log panel — displays a scrollable list of action results.
## Attached to BattleLogPanel (ScrollContainer) in gameplay.tscn.

const SHIP_DISPLAY_NAMES: Dictionary = {
	"battleship": "Battleship",
	"probe_ship": "Probe Ship",
	"destroyer": "Destroyer",
	"cruiser": "Cruiser",
}

const COLOR_HIT: Color = Color(1.0, 0.45, 0.3)
const COLOR_DESTROY: Color = Color(1.0, 0.2, 0.1)
const COLOR_MISS: Color = Color(0.6, 0.6, 0.65)
const COLOR_PROBE: Color = Color(0.4, 0.75, 1.0)
const COLOR_MOVE: Color = Color(0.7, 0.85, 0.7)

var _content: VBoxContainer = null
var _placeholder_cleared: bool = false


func _ready() -> void:
	_content = $BattleLogContent as VBoxContainer


func _ship_name(ship_type: String) -> String:
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
	_clear_placeholder()

	var action_type: String = result.get("type", "")
	var text: String = ""
	var color: Color = COLOR_MISS

	match action_type:
		"probe":
			text = _format_probe(result)
			color = COLOR_PROBE
		"laser", "missile":
			text = _format_fire(result)
			if result.get("destroyed", false):
				color = COLOR_DESTROY
			elif result.get("hit", false):
				color = COLOR_HIT
			else:
				color = COLOR_MISS
		"move":
			text = _format_move(result)
			color = COLOR_MOVE
		_:
			text = str(result)

	var label: Label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 13)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_content.add_child(label)

	# Auto-scroll to bottom after layout updates
	await get_tree().process_frame
	ensure_control_visible(label)


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
