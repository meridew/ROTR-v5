extends Node2D
class_name Armoury

signal armoury_ready

var equipment_scenes: Dictionary = {
	
	"exposed_reactor": preload("res://equipment/exposed_reactor.tscn"),
	"electro_magnet": preload("res://equipment/electro_magnet.tscn"),
	"gauss_canon": preload("res://equipment/gauss_canon.tscn"),
	"spinning_laser": preload("res://equipment/spinning_laser.tscn"),
	"battery_overcharge": preload("res://equipment/battery_overcharge.tscn"),
	"nanite_armour": preload("res://equipment/nanite_armour.tscn"),
	"laser": preload("res://equipment/laser.tscn"),
	"air_strike": preload("res://equipment/air_strike.tscn"),
}

var equipment: Dictionary = {}

func _init():
	name = "Armoury"
	instance_equipment()
	
func _ready():
	emit_signal("armoury_ready")

func instance_equipment():
	for key in equipment_scenes.keys():
		var equipment_instance = equipment_scenes[key].instantiate()
		equipment_instance.update_stats()
		equipment[key] = equipment_instance

func take_equipment(equipment_id: String):
	equipment[equipment_id].set_projectile_node(GameStateManager.projectile_node)
	equipment[equipment_id].equipped = true
	return equipment[equipment_id]
	
func replace_equipment(equipment_id: String):
	equipment[equipment_id].equipped = true

func get_available_equipment():
	var available_equipment = {}
	for equipment_key in equipment.keys():
		if !equipment[equipment_key].equipped:
			available_equipment[equipment_key] = equipment[equipment_key]
	return available_equipment
	
func get_available_upgrades():
	var upgrade_stats = {}
	for equipment_key in equipment.keys():
		for stat_key in equipment[equipment_key].stats.keys():
			if equipment[equipment_key].equipped and equipment[equipment_key].stats[stat_key].level < equipment[equipment_key].stats[stat_key].max_level:
				upgrade_stats[stat_key] = equipment[equipment_key].stats[stat_key]
	return upgrade_stats
