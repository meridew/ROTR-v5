extends "res://equipment/base_equipment.gd"

@onready var player

func _init():
	type = "utility"
	equipment_id = "battery_overcharge"
	equipment_name = "Battery Overcharge"
	equipment_description = "go faster"
	add_stat("speed_increase", 1, 1.1)

func _ready():
	player = get_parent()
	player.player_speed *= stats.speed_increase.rate_increase
	stats.speed_increase.connect("stat_changed", Callable(self, "_on_stat_changed"))
