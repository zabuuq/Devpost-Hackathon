class_name CellRecord

var has_probe: bool = false
var expires_in: int = 0                  # countdown: decrements at YOUR turn start
                                         # standard probe: set to 2; Probe Ship: set to 3
                                         # when reaches 0: ship → ghost, empty → delete record
var has_blind_hit: bool = false
var hit_turn: int = 0                    # in-progress turn number when blind hit was recorded
var has_miss: bool = false
var miss_turn: int = 0                   # in-progress turn number when miss was recorded
var was_probed: bool = false             # historical: cell has been inside an active probe
                                         # area at least once. Persists after probes expire so
                                         # the Target Grid can render a faint "you've looked here"
                                         # marker. Cleared only when GameState.reset() builds a
                                         # fresh cell_records dict.
var last_probe_turn: int = 0             # in-progress turn number of the most recent probe
                                         # that covered this cell (0 if never probed). Used
                                         # by the Target Grid hover tooltip.
var ship: FogShipRecord = null           # null if no ship detected in this cell

static func make_probe(fog_ship: FogShipRecord, probe_expires_in: int, turn_number: int) -> CellRecord:
	var record := CellRecord.new()
	record.has_probe = true
	record.expires_in = probe_expires_in
	record.was_probed = true
	record.last_probe_turn = turn_number
	record.ship = fog_ship
	return record

static func make_ship_ghost(fog_ship: FogShipRecord) -> CellRecord:
	var record := CellRecord.new()
	record.has_probe = false
	record.ship = fog_ship
	return record

static func make_blind_hit(turn: int = 0) -> CellRecord:
	var record := CellRecord.new()
	record.has_blind_hit = true
	record.hit_turn = turn
	return record

static func make_miss(turn: int) -> CellRecord:
	var record := CellRecord.new()
	record.has_miss = true
	record.miss_turn = turn
	return record
