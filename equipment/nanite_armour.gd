extends "res://equipment/base_equipment.gd"

@onready var player
@onready var health_regen_timer = $HealthRegenTimer

func _init():
	type = "utility"
	equipment_id = "nanite_armour"
	equipment_name = "Nanite Armour"
	equipment_description = "heal over time"
	add_stat("health_regen_amount", 1, 0.1)
	add_stat("health_regen_frequency", 1, 0.1)
	add_stat("health_regen_max", 50, 0.1)

func _ready():
	player = get_parent()
	health_regen_timer.wait_time = stats.health_regen_frequency.value
	stats.health_regen_frequency.connect("stat_changed", Callable(self, "_on_stat_health_regen_frequency_changed"))
	stats.health_regen_amount.connect("stat_changed", Callable(self, "_on_stat_health_regen_amount_changed"))
	
func _on_stat_health_regen_frequency_changed():
	health_regen_timer.wait_time = stats.health_regen_frequency.value

func _on_health_regen_timer_timeout():
	player.add_hp(stats.health_regen_amount.value)
