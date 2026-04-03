class_name ActionResolver
extends Node

const GRID_WIDTH: int = 80
const GRID_HEIGHT: int = 20


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func get_ship_cells(ship: ShipInstance) -> Array[Vector2i]:
	return ShipDefinitions.get_ship_cells(ship.ship_type, ship.position, ship.facing)


func find_ship_at_cell(cell: Vector2i, fleet: Array) -> ShipInstance:
	for ship in fleet:
		if ship.is_destroyed:
			continue
		var cells: Array[Vector2i] = get_ship_cells(ship)
		if cells.has(cell):
			return ship
	return null


# ---------------------------------------------------------------------------
# Probe
# ---------------------------------------------------------------------------

func resolve_probe(acting_ship: ShipInstance, target_cell: Vector2i, player_idx: int) -> Dictionary:
	var stats: Dictionary = ShipDefinitions.SHIPS[acting_ship.ship_type]
	var probe_size: int = stats["probe_area"]
	var probe_cost: int = stats["probe_cost"]
	var expires_in: int = 3 if acting_ship.ship_type == "probe_ship" else 2

	# Deduct energy and probes
	acting_ship.current_energy -= probe_cost
	acting_ship.probes_remaining -= 1

	var player_data: Dictionary = GameState.players[player_idx]
	var cell_records: Dictionary = player_data.cell_records
	var opponent_fleet: Array = GameState.players[1 - player_idx].fleet

	# Build probe area, clamped to grid bounds
	var half: int = probe_size / 2
	var x_min: int = clampi(target_cell.x - half, 0, GRID_WIDTH - 1)
	var x_max: int = clampi(target_cell.x - half + probe_size - 1, 0, GRID_WIDTH - 1)
	var y_min: int = clampi(target_cell.y - half, 0, GRID_HEIGHT - 1)
	var y_max: int = clampi(target_cell.y - half + probe_size - 1, 0, GRID_HEIGHT - 1)

	var ships_detected: int = 0
	var detected_ships: Array = []  # track unique ships found

	for y in range(y_min, y_max + 1):
		for x in range(x_min, x_max + 1):
			var cell := Vector2i(x, y)
			var enemy_ship: ShipInstance = find_ship_at_cell(cell, opponent_fleet)

			var fog_ship: FogShipRecord = null
			if enemy_ship != null:
				fog_ship = FogShipRecord.from_ship(enemy_ship)
				if not detected_ships.has(enemy_ship):
					detected_ships.append(enemy_ship)

			# Create or overwrite the cell record (clears ghost / blind hit data)
			var record := CellRecord.make_probe(fog_ship, expires_in)
			cell_records[cell] = record

	# For each detected ship, also write probe records on ALL cells that ship
	# occupies — even those outside the probe area — so the ship renders fully.
	for ship in detected_ships:
		var fog_ship: FogShipRecord = FogShipRecord.from_ship(ship)
		var ship_cells: Array[Vector2i] = get_ship_cells(ship)
		for cell in ship_cells:
			var record := CellRecord.make_probe(fog_ship, expires_in)
			cell_records[cell] = record

	ships_detected = detected_ships.size()

	# Stats
	player_data.turn_stats.probes_launched += 1

	return {
		"type": "probe",
		"ship_type": acting_ship.ship_type,
		"target": target_cell,
		"ships_detected": ships_detected
	}


# ---------------------------------------------------------------------------
# Laser
# ---------------------------------------------------------------------------

func resolve_laser(acting_ship: ShipInstance, target_cell: Vector2i, opponent_fleet: Array, player_idx: int) -> Dictionary:
	var laser_power: int = acting_ship.laser_power_setting

	# Deduct energy
	acting_ship.current_energy -= laser_power
	acting_ship.action_taken = true

	# Hit check
	var target_ship: ShipInstance = find_ship_at_cell(target_cell, opponent_fleet)
	if target_ship == null:
		return {
			"type": "laser",
			"ship_type": acting_ship.ship_type,
			"target": target_cell,
			"hit": false
		}

	# Damage calculation
	var shields_absorbed: int = mini(target_ship.current_shields, laser_power)
	var overflow: int = laser_power - shields_absorbed
	var armor_damage: int = roundi(overflow * 0.75)

	target_ship.current_shields -= shields_absorbed
	target_ship.current_armor -= armor_damage

	var destroyed: bool = false
	if target_ship.current_armor <= 0:
		target_ship.current_armor = 0
		target_ship.is_destroyed = true
		destroyed = true

	# Blind hit handling
	var player_data: Dictionary = GameState.players[player_idx]
	var cell_records: Dictionary = player_data.cell_records
	var has_active_probe: bool = false
	if cell_records.has(target_cell):
		var record: CellRecord = cell_records[target_cell]
		if record.has_probe:
			has_active_probe = true

	if not has_active_probe:
		var record: CellRecord
		if cell_records.has(target_cell):
			record = cell_records[target_cell]
		else:
			record = CellRecord.new()
			cell_records[target_cell] = record
		record.has_blind_hit = true

	# Stats
	player_data.turn_stats.hits_scored += 1
	GameState.last_turn_hits += 1

	return {
		"type": "laser",
		"ship_type": acting_ship.ship_type,
		"target": target_cell,
		"hit": true,
		"has_probe": has_active_probe,
		"shield_damage": shields_absorbed,
		"armor_damage": armor_damage,
		"destroyed": destroyed,
		"target_ship_type": target_ship.ship_type
	}


# ---------------------------------------------------------------------------
# Missile
# ---------------------------------------------------------------------------

func resolve_missile(acting_ship: ShipInstance, target_cell: Vector2i, opponent_fleet: Array, player_idx: int) -> Dictionary:
	# Deduct missile
	acting_ship.missiles_remaining -= 1
	acting_ship.action_taken = true

	# Hit check
	var target_ship: ShipInstance = find_ship_at_cell(target_cell, opponent_fleet)
	if target_ship == null:
		return {
			"type": "missile",
			"ship_type": acting_ship.ship_type,
			"target": target_cell,
			"hit": false
		}

	# Damage calculation — missiles bypass shields partially
	var shield_damage: int = 0
	var armor_damage: int = 0

	if target_ship.current_shields > 0:
		var shields_absorbed: int = mini(target_ship.current_shields, 125)
		var overflow: int = 125 - shields_absorbed
		shield_damage = shields_absorbed
		armor_damage = overflow  # no percentage multiplier for missiles
	else:
		armor_damage = 250

	target_ship.current_shields -= shield_damage
	target_ship.current_armor -= armor_damage

	var destroyed: bool = false
	if target_ship.current_armor <= 0:
		target_ship.current_armor = 0
		target_ship.is_destroyed = true
		destroyed = true

	# Blind hit handling
	var player_data: Dictionary = GameState.players[player_idx]
	var cell_records: Dictionary = player_data.cell_records
	var has_active_probe: bool = false
	if cell_records.has(target_cell):
		var record: CellRecord = cell_records[target_cell]
		if record.has_probe:
			has_active_probe = true

	if not has_active_probe:
		var record: CellRecord
		if cell_records.has(target_cell):
			record = cell_records[target_cell]
		else:
			record = CellRecord.new()
			cell_records[target_cell] = record
		record.has_blind_hit = true

	# Stats
	player_data.turn_stats.hits_scored += 1
	GameState.last_turn_hits += 1

	return {
		"type": "missile",
		"ship_type": acting_ship.ship_type,
		"target": target_cell,
		"hit": true,
		"has_probe": has_active_probe,
		"shield_damage": shield_damage,
		"armor_damage": armor_damage,
		"destroyed": destroyed,
		"target_ship_type": target_ship.ship_type
	}
