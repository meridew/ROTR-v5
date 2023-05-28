extends "res://equipment/base_equipment.gd"

var attracted_items = []

func _init():
	type = "utility"
	equipment_id = "electro_magnet"
	equipment_name = "Electro-Magnet"
	add_stat("attraction_radius", 50, 0.3)

func _ready():
	update_stats()
			
func _physics_process(delta: float) -> void:
	for item in attracted_items:
		item.position = item.calculate_new_position(GameStateManager.player.global_position, delta)

func _on_area_entered(area):
	if area.is_in_group("xp"):
		attracted_items.append(area)

func _on_area_exited(area):
	if area.is_in_group("xp"):
		attracted_items.erase(area)

func update_stats():
	$attraction.shape.radius = stats.attraction_radius.value
