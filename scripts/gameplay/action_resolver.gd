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
	acting_ship.action_taken = true

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

	# For each detected ship, write ship references on cells OUTSIDE the probe
	# area so the ship renders fully. These cells do NOT get has_probe = true —
	# they're ghost references that will be cleared when the ship moves away.
	for ship in detected_ships:
		var fog_ship: FogShipRecord = FogShipRecord.from_ship(ship)
		var ship_cells: Array[Vector2i] = get_ship_cells(ship)
		for cell in ship_cells:
			if not cell_records.has(cell) or not cell_records[cell].has_probe:
				# Cell is outside the probe area — add a ghost ship reference only
				cell_records[cell] = CellRecord.make_ship_ghost(fog_ship)
			elif cell_records[cell].ship == null:
				# Cell is inside probe area but wasn't on this ship — set the ref
				cell_records[cell].ship = fog_ship

	# Destroyed enemy ships: any cells overlapping the probe area get a fresh
	# probe record (so wreckage renders), and remaining hull cells get a ghost
	# reference so the wreckage outline spans the whole ship.
	for wreck in opponent_fleet:
		if not wreck.is_destroyed:
			continue
		var wreck_cells: Array[Vector2i] = get_ship_cells(wreck)
		var overlaps_probe: bool = false
		for cell in wreck_cells:
			if cell.x >= x_min and cell.x <= x_max and cell.y >= y_min and cell.y <= y_max:
				overlaps_probe = true
				break
		if not overlaps_probe:
			continue
		var wreck_fog: FogShipRecord = FogShipRecord.from_ship(wreck)
		for cell in wreck_cells:
			var inside: bool = cell.x >= x_min and cell.x <= x_max and cell.y >= y_min and cell.y <= y_max
			if inside:
				cell_records[cell] = CellRecord.make_probe(wreck_fog, expires_in)
			else:
				if not cell_records.has(cell) or not cell_records[cell].has_probe:
					cell_records[cell] = CellRecord.make_ship_ghost(wreck_fog)
				elif cell_records[cell].ship == null:
					cell_records[cell].ship = wreck_fog

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
	var player_data: Dictionary = GameState.players[player_idx]
	player_data.turn_stats.laser_shots_fired += 1

	# Deduct energy
	acting_ship.current_energy -= laser_power
	acting_ship.action_taken = true

	# Hit check
	var target_ship: ShipInstance = find_ship_at_cell(target_cell, opponent_fleet)
	if target_ship == null:
		player_data.turn_stats.total_misses += 1
		var miss_turn_number: int = player_data["turns_played"] + 1
		var cell_records_miss: Dictionary = player_data.cell_records
		if cell_records_miss.has(target_cell):
			var existing: CellRecord = cell_records_miss[target_cell]
			existing.has_miss = true
			existing.miss_turn = miss_turn_number
			existing.has_blind_hit = false
			existing.hit_turn = 0
			existing.ship = null
		else:
			cell_records_miss[target_cell] = CellRecord.make_miss(miss_turn_number)
		return {
			"type": "laser",
			"ship_type": acting_ship.ship_type,
			"target": target_cell,
			"hit": false
		}

	# Damage calculation
	var pre_shields: int = target_ship.current_shields
	var shields_absorbed: int = mini(target_ship.current_shields, laser_power)
	var overflow: int = laser_power - shields_absorbed
	var armor_damage: int = roundi(overflow * 0.75)

	target_ship.current_shields -= shields_absorbed
	target_ship.current_armor -= armor_damage
	var shields_depleted: bool = pre_shields > 0 and target_ship.current_shields == 0

	var destroyed: bool = false
	var match_over: bool = false
	if target_ship.current_armor <= 0:
		target_ship.current_armor = 0
		target_ship.is_destroyed = true
		destroyed = true
		# I8-6: instant win — if the killing blow finishes off the opponent's
		# last living ship, signal gameplay.gd to skip end-of-turn and load victory.
		match_over = opponent_fleet.all(func(s: ShipInstance) -> bool: return s.is_destroyed)

	# Blind hit handling
	var cell_records: Dictionary = player_data.cell_records
	var has_active_probe: bool = false
	if cell_records.has(target_cell):
		var record: CellRecord = cell_records[target_cell]
		if record.has_probe:
			has_active_probe = true

	var hit_turn_number: int = player_data["turns_played"] + 1
	if not has_active_probe:
		var record: CellRecord
		if cell_records.has(target_cell):
			record = cell_records[target_cell]
		else:
			record = CellRecord.new()
			cell_records[target_cell] = record
		record.has_blind_hit = true
		record.hit_turn = hit_turn_number
		record.has_miss = false
	else:
		var record: CellRecord = cell_records[target_cell]
		record.has_miss = false

	# Refresh probe records so the attacker sees updated shields/armor
	_refresh_probe_records_for_ship(target_ship, player_idx)

	# Stats
	player_data.turn_stats.hits_scored += 1
	player_data.turn_stats.total_damage += shields_absorbed + armor_damage
	GameState.last_turn_hits += 1

	return {
		"type": "laser",
		"ship_type": acting_ship.ship_type,
		"target": target_cell,
		"hit": true,
		"has_probe": has_active_probe,
		"shield_damage": shields_absorbed,
		"armor_damage": armor_damage,
		"shields_depleted": shields_depleted,
		"destroyed": destroyed,
		"target_ship_type": target_ship.ship_type,
		"match_over": match_over
	}


# ---------------------------------------------------------------------------
# Missile
# ---------------------------------------------------------------------------

func resolve_missile(acting_ship: ShipInstance, target_cell: Vector2i, opponent_fleet: Array, player_idx: int) -> Dictionary:
	var player_data: Dictionary = GameState.players[player_idx]
	player_data.turn_stats.missile_shots_fired += 1

	# Deduct missile
	acting_ship.missiles_remaining -= 1
	acting_ship.action_taken = true

	# Hit check
	var target_ship: ShipInstance = find_ship_at_cell(target_cell, opponent_fleet)
	if target_ship == null:
		player_data.turn_stats.total_misses += 1
		var miss_turn_number: int = player_data["turns_played"] + 1
		var cell_records_miss: Dictionary = player_data.cell_records
		if cell_records_miss.has(target_cell):
			var existing: CellRecord = cell_records_miss[target_cell]
			existing.has_miss = true
			existing.miss_turn = miss_turn_number
			existing.has_blind_hit = false
			existing.hit_turn = 0
			existing.ship = null
		else:
			cell_records_miss[target_cell] = CellRecord.make_miss(miss_turn_number)
		return {
			"type": "missile",
			"ship_type": acting_ship.ship_type,
			"target": target_cell,
			"hit": false
		}

	# Damage calculation — missiles bypass shields partially
	var pre_shields: int = target_ship.current_shields
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
	var shields_depleted: bool = pre_shields > 0 and target_ship.current_shields == 0

	var destroyed: bool = false
	var match_over: bool = false
	if target_ship.current_armor <= 0:
		target_ship.current_armor = 0
		target_ship.is_destroyed = true
		destroyed = true
		# I8-6: instant win — if the killing blow finishes off the opponent's
		# last living ship, signal gameplay.gd to skip end-of-turn and load victory.
		match_over = opponent_fleet.all(func(s: ShipInstance) -> bool: return s.is_destroyed)

	# Blind hit handling
	var cell_records: Dictionary = player_data.cell_records
	var has_active_probe: bool = false
	if cell_records.has(target_cell):
		var record: CellRecord = cell_records[target_cell]
		if record.has_probe:
			has_active_probe = true

	var hit_turn_number: int = player_data["turns_played"] + 1
	if not has_active_probe:
		var record: CellRecord
		if cell_records.has(target_cell):
			record = cell_records[target_cell]
		else:
			record = CellRecord.new()
			cell_records[target_cell] = record
		record.has_blind_hit = true
		record.hit_turn = hit_turn_number
		record.has_miss = false
	else:
		var record: CellRecord = cell_records[target_cell]
		record.has_miss = false

	# Refresh probe records so the attacker sees updated shields/armor
	_refresh_probe_records_for_ship(target_ship, player_idx)

	# Stats
	player_data.turn_stats.hits_scored += 1
	player_data.turn_stats.total_damage += shield_damage + armor_damage
	GameState.last_turn_hits += 1

	return {
		"type": "missile",
		"ship_type": acting_ship.ship_type,
		"target": target_cell,
		"hit": true,
		"has_probe": has_active_probe,
		"shield_damage": shield_damage,
		"armor_damage": armor_damage,
		"shields_depleted": shields_depleted,
		"destroyed": destroyed,
		"target_ship_type": target_ship.ship_type,
		"match_over": match_over
	}


# ---------------------------------------------------------------------------
# Move
# ---------------------------------------------------------------------------

## Calculate available move points for a ship based on energy and base stats.
static func get_available_move_points(ship: ShipInstance) -> float:
	var base: float = ShipDefinitions.SHIPS[ship.ship_type]["base_move_points"]
	var energy_pts: float = floor(ship.current_energy / 25.0) * 0.5
	return minf(base, energy_pts)


## Calculate the move cost (points and energy) for a net displacement + rotation.
## facing: the ship's POST-rotation facing (i.e. starting facing rotated by
##   net_rotation). "Forward" is evaluated against this facing so that
##   displacement aligned with the new heading gets the 0.5-pt discount.
## net_displacement: total grid offset from current position.
## net_rotation: -1, 0, or 1 (CCW, none, CW).
## Returns { "move_points": float, "energy": int, "valid": bool }
static func calc_move_cost(facing: int, net_displacement: Vector2i, net_rotation: int) -> Dictionary:
	var pts: float = 0.0
	var energy: int = 0

	# Rotation cost
	if net_rotation != 0:
		pts += 1.0
		energy += 50

	# Direction vector for "forward" based on post-rotation facing
	var forward: Vector2i
	match facing:
		0: forward = Vector2i(0, -1)
		1: forward = Vector2i(1, 0)
		2: forward = Vector2i(0, 1)
		3: forward = Vector2i(-1, 0)
		_: forward = Vector2i(0, -1)

	# Break displacement into forward component and non-forward component.
	# Forward dot = how much of the displacement aligns with facing.
	var dx: int = net_displacement.x
	var dy: int = net_displacement.y

	# Project displacement onto forward axis
	var forward_amount: int = dx * forward.x + dy * forward.y  # dot product
	var forward_cells: int = max(forward_amount, 0)  # only positive = actual forward
	var backward_cells: int = max(-forward_amount, 0)

	# Lateral component: displacement minus forward projection
	var lateral_displacement: Vector2i = net_displacement - forward * forward_amount
	var lateral_cells: int = abs(lateral_displacement.x) + abs(lateral_displacement.y)

	# Forward movement: 0.5 pts / 25 energy per cell
	pts += forward_cells * 0.5
	energy += forward_cells * 25

	# Non-forward movement (backward + lateral): 1.0 pts / 50 energy per cell
	pts += (backward_cells + lateral_cells) * 1.0
	energy += (backward_cells + lateral_cells) * 50

	return {"move_points": pts, "energy": energy, "valid": true}


## Check if proposed ship cells collide with any living friendly ship.
## Excludes the moving ship itself. Enemy ships are invisible and don't block.
func check_move_collision(moving_ship: ShipInstance, new_cells: Array[Vector2i]) -> ShipInstance:
	var fleet: Array = GameState.players[GameState.current_player]["fleet"]
	for ship in fleet:
		if ship == moving_ship:
			continue
		if ship.is_destroyed:
			continue
		var cells: Array[Vector2i] = get_ship_cells(ship)
		for c in new_cells:
			if cells.has(c):
				return ship
	return null


## Check if all proposed cells are within grid bounds.
static func cells_in_bounds(cells: Array[Vector2i]) -> bool:
	for c in cells:
		if c.x < 0 or c.x >= GRID_WIDTH or c.y < 0 or c.y >= GRID_HEIGHT:
			return false
	return true


## Refresh FogShipRecords on all active probe cells that cover a given ship.
## Called after damage so the attacker's probe view shows updated stats.
func _refresh_probe_records_for_ship(ship: ShipInstance, attacker_idx: int) -> void:
	var cell_records: Dictionary = GameState.players[attacker_idx]["cell_records"]
	var ship_cells: Array[Vector2i] = ShipDefinitions.get_ship_cells(
		ship.ship_type, ship.position, ship.facing)
	var fog: FogShipRecord = FogShipRecord.from_ship(ship)
	for cell in ship_cells:
		if cell_records.has(cell):
			var record: CellRecord = cell_records[cell]
			if record.has_probe:
				record.ship = fog


## After a ship moves, update the opponent's active probe cell records.
## Old cells that had probe coverage lose their ship record; new cells that
## have probe coverage gain a fresh FogShipRecord.
func _update_opponent_probes_after_move(ship: ShipInstance, old_cells: Array[Vector2i],
		new_cells: Array[Vector2i], player_idx: int) -> void:
	var opponent_idx: int = 1 - player_idx
	var cell_records: Dictionary = GameState.players[opponent_idx]["cell_records"]

	# Clear ship from old cells that have active probe coverage. Ghost-only
	# cells keep their reference — ghosts are persistent intel and should not
	# vanish just because the enemy ship moved.
	for cell in old_cells:
		if cell_records.has(cell):
			var record: CellRecord = cell_records[cell]
			if record.ship != null and record.has_probe:
				record.ship = null

	# Add ship to new cells that have active probes
	var fog: FogShipRecord = FogShipRecord.from_ship(ship)
	for cell in new_cells:
		if cell_records.has(cell):
			var record: CellRecord = cell_records[cell]
			if record.has_probe:
				record.ship = fog


## Execute a move action. Returns a result dictionary.
## new_position: the ship's new origin after the move.
## new_facing: the ship's new facing after the move.
func resolve_move(acting_ship: ShipInstance, new_position: Vector2i, new_facing: int, player_idx: int) -> Dictionary:
	# Use pivot-based displacement so rotation-induced origin shifts don't count as movement
	var old_pivot: Vector2i = acting_ship.position + ShipDefinitions.get_pivot_offset(acting_ship.ship_type, acting_ship.facing)
	var new_pivot: Vector2i = new_position + ShipDefinitions.get_pivot_offset(acting_ship.ship_type, new_facing)
	var net_displacement: Vector2i = new_pivot - old_pivot
	var facing_diff: int = (new_facing - acting_ship.facing + 4) % 4
	var net_rotation: int = 0
	if facing_diff == 1:
		net_rotation = 1
	elif facing_diff == 3:
		net_rotation = -1

	# Use new_facing (post-rotation) so the forward-discount aligns with the
	# ship's heading after the rotate, not its heading at the start of the move.
	var cost: Dictionary = calc_move_cost(new_facing, net_displacement, net_rotation)
	var available: float = get_available_move_points(acting_ship)

	if cost["move_points"] > available + 0.001:
		return {"type": "move", "success": false, "reason": "Not enough move points"}

	if cost["energy"] > acting_ship.current_energy:
		return {"type": "move", "success": false, "reason": "Not enough energy"}

	# Check new cells for collision and bounds
	var new_cells: Array[Vector2i] = ShipDefinitions.get_ship_cells(
		acting_ship.ship_type, new_position, new_facing)

	if not cells_in_bounds(new_cells):
		return {"type": "move", "success": false, "reason": "Ship would go out of bounds"}

	var blocker: ShipInstance = check_move_collision(acting_ship, new_cells)
	if blocker != null:
		return {"type": "move", "success": false, "reason": "Blocked by " + blocker.ship_type}

	# Execute move
	var old_cells: Array[Vector2i] = ShipDefinitions.get_ship_cells(
		acting_ship.ship_type, acting_ship.position, acting_ship.facing)
	acting_ship.position = new_position
	acting_ship.facing = new_facing
	acting_ship.current_energy -= cost["energy"]
	acting_ship.move_actions_taken += 1
	acting_ship.action_taken = true

	# Update opponent's active probe records to reflect this ship's new position
	_update_opponent_probes_after_move(acting_ship, old_cells, new_cells, player_idx)

	# Recalculate sliders after energy change
	var tm: TurnManager = get_parent().get_node("TurnManager") if get_parent() else null
	if tm:
		tm.recalculate_sliders(acting_ship)

	return {
		"type": "move",
		"success": true,
		"ship_type": acting_ship.ship_type,
		"old_position": acting_ship.position - net_displacement,
		"new_position": new_position,
		"old_facing": (new_facing - facing_diff + 4) % 4,
		"new_facing": new_facing,
		"move_points_used": cost["move_points"],
		"energy_used": cost["energy"]
	}
