class_name CellRecord

var has_probe: bool = false
var expires_in: int = 0                  # countdown: decrements at YOUR turn start
                                         # standard probe: set to 2; Probe Ship: set to 3
                                         # when reaches 0: ship → ghost, empty → delete record
var has_blind_hit: bool = false
var has_miss: bool = false
var miss_turn: int = 0                   # in-progress turn number when miss was recorded
var ship: FogShipRecord = null           # null if no ship detected in this cell

static func make_probe(fog_ship: FogShipRecord, probe_expires_in: int) -> CellRecord:
	var record := CellRecord.new()
	record.has_probe = true
	record.expires_in = probe_expires_in
	record.ship = fog_ship
	return record

static func make_ship_ghost(fog_ship: FogShipRecord) -> CellRecord:
	var record := CellRecord.new()
	record.has_probe = false
	record.ship = fog_ship
	return record

static func make_blind_hit() -> CellRecord:
	var record := CellRecord.new()
	record.has_blind_hit = true
	return record

static func make_miss(turn: int) -> CellRecord:
	var record := CellRecord.new()
	record.has_miss = true
	record.miss_turn = turn
	return record
