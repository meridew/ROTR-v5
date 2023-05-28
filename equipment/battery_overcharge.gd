extends "res://equipment/base_equipment.gd"

@onready var player

func _init():
	type = "utility"
	equipment_id = "battery_overcharge"
	equipment_name = "Battery Overcharge"
	add_stat("speed_increase", 20, 0.2)

func _ready():
	player = get_parent()
	player.player_speed += stats.speed_increase.value
	stats.speed_increase.connect("stat_changed", Callable(self, "_on_stat_changed"))
	
func _on_stat_changed():
	player.player_speed += stats.speed_increase.value
