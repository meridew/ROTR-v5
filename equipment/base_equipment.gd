extends Node2D

@export var equipment_id: String
@export var equipment_name: String
@export var type: String
@export var stats: Dictionary = {}
@export var equipped: bool = false

var dps = 0
var effectiveness = 0
var projectile_node

func add_stat(stat_id: String, value: float, rate_increase: float, base_increase: float = 0):
	stats[stat_id] = Stat.new(self, equipment_id, stat_id, value, rate_increase, base_increase)
	return self

func set_projectile_node(_projectile_node):
	projectile_node = _projectile_node

func update_stats():
	pass  # to be overridden in child classes

class Stat:
	
	var equipment
		
	var equipment_id: String
	var stat_id: String
	var value: float
	var rate_increase: float
	var base_increase: float
	var level: int = 0
	var max_level: int = 10
	var type = "stat"

	func _init(_equipment, _equipment_id: String, _stat_id: String, _value: float, _rate_increase: float, _base_increase: float = 0):
		self.equipment = _equipment
		self.equipment_id = _equipment_id
		self.stat_id = _stat_id
		self.value = _value
		self.rate_increase = _rate_increase
		self.base_increase = _base_increase
			
	func upgrade_stat():
		if level < max_level:
			value += value * rate_increase + base_increase
			level += 1 # Recalculate DPS after stat change
			equipment.update_stats()
			GameStateManager.player.calculate_player_dps()
		else:
			print("Stat: " + stat_id + " is at max level")
		return self
	
	func set_stat(_value):
		value = _value
		equipment.update_stats()
		GameStateManager.player.calculate_player_dps()
			
