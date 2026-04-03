class_name TurnManager
extends Node

func turn_start() -> void:
	var player: Dictionary = GameState.players[GameState.current_player]
	GameState.last_turn_hits = 0
	age_cell_records(player.cell_records)
	for ship in player.fleet:
		if not ship.is_destroyed:
			ship.current_energy += 50
			ship.action_taken = false
			ship.move_actions_taken = 0
			recalculate_sliders(ship)

func turn_end() -> void:
	var player: Dictionary = GameState.players[GameState.current_player]
	for ship in player.fleet:
		if not ship.is_destroyed:
			fire_shield_regen(ship)
	if check_win_condition():
		get_tree().change_scene_to_file("res://scenes/victory.tscn")
	else:
		GameState.current_player = 1 - GameState.current_player
		get_tree().change_scene_to_file("res://scenes/handoff.tscn")

func fire_shield_regen(ship: ShipInstance) -> void:
	var regen_amount: int = min(ship.shield_regen_setting, ship.current_energy)
	ship.current_shields = min(
		ship.current_shields + regen_amount,
		ShipDefinitions.SHIPS[ship.ship_type]["max_shields"]
	)
	ship.current_energy -= regen_amount

func check_win_condition() -> bool:
	var opponent: Dictionary = GameState.players[1 - GameState.current_player]
	return opponent.fleet.all(func(s: ShipInstance) -> bool: return s.is_destroyed)

func age_cell_records(cell_records: Dictionary) -> void:
	var to_delete: Array = []
	for cell in cell_records.keys():
		var record: CellRecord = cell_records[cell]
		if record.has_probe:
			record.expires_in -= 1
			if record.expires_in <= 0:
				record.has_probe = false
				if record.ship == null:
					to_delete.append(cell)
				# ship != null: stays as ghost (has_probe=false, ship persists)
	for cell in to_delete:
		cell_records.erase(cell)

func recalculate_sliders(ship: ShipInstance) -> void:
	var available: int = ship.current_energy
	ship.shield_regen_setting = min(ship.shield_regen_setting, available)
	ship.laser_power_setting = min(ship.laser_power_setting, available - ship.shield_regen_setting)
