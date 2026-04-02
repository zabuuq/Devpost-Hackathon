class_name ShipInstance

var ship_type: String = ""
var position: Vector2i = Vector2i.ZERO
var facing: int = 0
var current_shields: int = 0
var current_armor: int = 0
var current_energy: int = 0
var missiles_remaining: int = 0
var probes_remaining: int = 0
var shield_regen_setting: int = 0
var laser_power_setting: int = 0
var action_taken: bool = false
var move_actions_taken: int = 0
var is_destroyed: bool = false
