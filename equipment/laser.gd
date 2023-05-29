extends "res://equipment/base_equipment.gd"

@onready var laser = $laser_line

var is_charging = false
var is_firing = false
var charge_time = 1.0
var fire_time = 0.1

func _init():
	type = "weapon"
	equipment_id = "laser"
	equipment_name = "Laser"
	add_stat("damage", 50, 0.5)
	add_stat("frequency", 1, 0.2)
	add_stat("passthrough", 0, 1, 1)
	add_stat("range", 100, 0.2)

func update_stats():
	dps = stats.damage.value * stats.frequency.value * (stats.passthrough.value + 1)
	effectiveness = dps * (1 + stats.range.value / 100)

func _ready():
	is_charging = true
	
func _process(delta):
	if is_charging:
		charge_time -= delta
		if charge_time <= 0:
			is_charging = false
			is_firing = true  # Start firing when charging is done
			fire_laser(GameStateManager.player.global_position, stats.range.value, stats.passthrough.value)  # Fire the laser here
	elif is_firing:
		fire_time -= delta
		if fire_time <= 0:
			is_firing = false
			laser.clear_points()  # Clear the laser here after firing phase is complete
			charge_time = 1 / stats.frequency.value # Update the charge time based on the new frequency
			fire_time = 0.1  # Reset fire time
			is_charging = true  # Start charging again
	
func fire_laser(origin, range, passthrough, found_mobs = {}):
	laser.clear_points()
	var current_origin = laser.to_local(origin)
	var remaining_passthrough = passthrough + 1
	var closest_mob = find_closest_mob(current_origin, range, found_mobs)
	if closest_mob == null:
		return
	while remaining_passthrough > 0:
		current_origin = handle_mob_hit(closest_mob, found_mobs, current_origin)
		remaining_passthrough -= 1
		if remaining_passthrough <= 0:
			break
		closest_mob = find_closest_mob(current_origin, range, found_mobs)
		if closest_mob == null:
			break
	laser.add_point(current_origin)

func find_closest_mob(current_origin, range, found_mobs):
	var closest_mob = null
	var min_distance = range
	for mob in GameStateManager.mob_node.get_children():
		if mob in found_mobs or not mob.visible:
			continue
		var distance = current_origin.distance_to(laser.to_local(mob.global_position))
		if distance < min_distance:
			min_distance = distance
			closest_mob = mob
	return closest_mob

func handle_mob_hit(mob, found_mobs, current_origin):
	mob.take_damage(stats.damage.value)
	found_mobs[mob] = true
	laser.add_point(current_origin)
	current_origin = laser.to_local(mob.global_position)
	return current_origin
