extends "res://equipment/base_equipment.gd"

@export var gauss_round_scene: PackedScene
@onready var audio_fx = $AudioFX

var elapsed_time = 0.0
var mobs_in_range = []

func _init():
	type = "weapon"
	equipment_id = "gauss_canon"
	equipment_name = "Gauss Canon"
	add_stat("damage", 50, 0.5)
	add_stat("frequency", 1, 0.2)
	add_stat("projectile_size", 0.5, 0.3)
	add_stat("projectile_speed", 250, 1)
	add_stat("projectile_passthrough", 0, 1, 1)
	add_stat("projectile_knockback", 100, 0.5)

func _process(delta):
	elapsed_time += delta
	if elapsed_time >= 1 / stats.frequency.value:
		elapsed_time = 0
		fire_projectile()

func update_stats():
	dps = stats.damage.value * stats.frequency.value * (1 + stats.projectile_passthrough.value)
	effectiveness = dps * (1 + stats.projectile_size.value) * stats.projectile_speed.value / 500 * (1 + stats.projectile_knockback.value / 100)

func fire_projectile():
	if mobs_in_range.size() > 0:
		var angle = get_closest_mob()
		var gauss_round = PoolManager.acquire_projectile()
		if gauss_round:
			gauss_round.init_stats(stats)
			gauss_round.set_direction(angle)
			gauss_round.global_position = global_position
			audio_fx.play()
	
func _on_area_2d_area_entered(area):
	if area.is_in_group("mobs"):
		mobs_in_range.append(area)

func _on_area_2d_area_exited(area):
	if area.is_in_group("mobs"):
		mobs_in_range.erase(area)

func get_closest_mob():
	var closest_mob = null
	var closest_mob_distance = INF
	for mob in mobs_in_range:
		var distance = (mob.global_position - global_position).length()
		if distance < closest_mob_distance:
			closest_mob = mob
			closest_mob_distance = distance
	return (closest_mob.global_position - global_position).angle()

func _on_projectile_timer_timeout():
	if mobs_in_range.size() > 0:
		var angle = get_closest_mob()
		var gauss_round = gauss_round_scene.instantiate()
		gauss_round.init_stats(stats)
		gauss_round.set_direction(angle)
		projectile_node.add_child(gauss_round)

func _on_area_2d_body_entered(body):
	if body.is_in_group("mobs"):
		mobs_in_range.append(body)

func _on_area_2d_body_exited(body):
	if body.is_in_group("mobs"):
		mobs_in_range.erase(body)
