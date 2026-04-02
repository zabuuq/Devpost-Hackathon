class_name FogShipRecord

var ship_type: String = ""
var position: Vector2i = Vector2i.ZERO   # origin cell on enemy grid
var facing: int = 0
var last_shields: int = 0                # visible only when has_probe == true (PRD 4.3)
var last_armor: int = 0                  # visible only when has_probe == true

static func from_ship(ship: ShipInstance) -> FogShipRecord:
	var record := FogShipRecord.new()
	record.ship_type = ship.ship_type
	record.position = ship.position
	record.facing = ship.facing
	record.last_shields = ship.current_shields
	record.last_armor = ship.current_armor
	return record
