class_name TurnManager
extends Node

func turn_start() -> void:
	var player: Dictionary = GameState.players[GameState.current_player]
	GameState.last_turn_hits = 0
	age_cell_records(player.cell_records)
	for ship in player.fleet:
		if not ship.is_destroyed:
			var max_energy: int = ShipDefinitions.SHIPS[ship.ship_type]["max_energy"]
			ship.current_energy = mini(ship.current_energy + 50, max_energy)
			ship.action_taken = false
			ship.move_actions_taken = 0
			recalculate_sliders(ship)

func turn_end() -> void:
	var player: Dictionary = GameState.players[GameState.current_player]
	for ship in player.fleet:
		if not ship.is_destroyed:
			fire_shield_regen(ship)
	# Refresh opponent's probe records so they see updated shield values
	_refresh_opponent_probes_after_regen()
	GameState.players[GameState.current_player]["turns_played"] += 1
	var turns_played: int = GameState.players[GameState.current_player]["turns_played"]
	GameState.append_battle_log_divider(GameState.current_player, turns_played, false)
	if check_win_condition():
		get_tree().change_scene_to_file("res://scenes/victory.tscn")
	else:
		GameState.current_player = 1 - GameState.current_player
		get_tree().change_scene_to_file("res://scenes/handoff.tscn")

func fire_shield_regen(ship: ShipInstance) -> void:
	var max_shields: int = ShipDefinitions.SHIPS[ship.ship_type]["max_shields"]
	var damage_needed: int = max_shields - ship.current_shields
	var regen_amount: int = mini(ship.shield_regen_setting, mini(ship.current_energy, damage_needed))
	ship.current_shields += regen_amount
	ship.current_energy -= regen_amount

func check_win_condition() -> bool:
	var opponent: Dictionary = GameState.players[1 - GameState.current_player]
	return opponent.fleet.all(func(s: ShipInstance) -> bool: return s.is_destroyed)

func age_cell_records(cell_records: Dictionary) -> void:
	var to_delete: Array = []
	var destroyed_fogs: Array = []  # FogShipRecords of destroyed ships losing probe coverage
	for cell in cell_records.keys():
		var record: CellRecord = cell_records[cell]
		if record.has_probe:
			record.expires_in -= 1
			if record.expires_in <= 0:
				record.has_probe = false
				if record.ship == null:
					to_delete.append(cell)
				elif record.ship.last_armor <= 0:
					# Destroyed ship — no point ghosting wreckage, remove it
					if not destroyed_fogs.has(record.ship):
						destroyed_fogs.append(record.ship)
					to_delete.append(cell)
				# living ship != null: stays as ghost (has_probe=false, ship persists)
	# Also clean up ghost cells (outside probe area) for destroyed ships
	if not destroyed_fogs.is_empty():
		for cell in cell_records.keys():
			var record: CellRecord = cell_records[cell]
			if record.ship != null and destroyed_fogs.has(record.ship) and not to_delete.has(cell):
				to_delete.append(cell)
	for cell in to_delete:
		cell_records.erase(cell)

func _refresh_opponent_probes_after_regen() -> void:
	var opponent_idx: int = 1 - GameState.current_player
	var opponent_records: Dictionary = GameState.players[opponent_idx]["cell_records"]
	var current_fleet: Array = GameState.players[GameState.current_player].fleet
	for ship in current_fleet:
		if ship.is_destroyed:
			continue
		var fog: FogShipRecord = FogShipRecord.from_ship(ship)
		var ship_cells: Array[Vector2i] = ShipDefinitions.get_ship_cells(
			ship.ship_type, ship.position, ship.facing)
		for cell in ship_cells:
			if opponent_records.has(cell):
				var record: CellRecord = opponent_records[cell]
				if record.ship != null:
					record.ship = fog

func recalculate_sliders(ship: ShipInstance) -> void:
	var available: int = ship.current_energy
	ship.shield_regen_setting = min(ship.shield_regen_setting, available)
	ship.laser_power_setting = min(ship.laser_power_setting, available - ship.shield_regen_setting)
