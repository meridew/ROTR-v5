extends "res://equipment/base_equipment.gd"

@onready var laser_line = $LaserLine
@onready var fire_timer = $FireTimer
@onready var charge_timer = $ChargeTimer

var is_firing = false

func _init():
	type = "weapon"
	equipment_id = "spinning_laser"
	equipment_name = "Spinning Laser"
	equipment_description = "shitty spinning laser"
	add_stat("damage", 10, 0.2)
	add_stat("laser_length", 250, 0.2)
	add_stat("laser_speed", 180, 0.1)
	add_stat("laser_charge_time", 1, 0.1)
	add_stat("laser_fire_time", 2, 0.1)

func _ready():

	laser_line.points = [Vector2.ZERO, Vector2.UP * - stats.laser_length.value]
	
	charge_timer.wait_time = stats.laser_charge_time.value
	fire_timer.wait_time = stats.laser_fire_time.value
	
	charge_timer.connect("timeout", Callable(self, "_on_charge_timer_timeout"))
	fire_timer.connect("timeout", Callable(self, "_on_timer_timeout"))

func _physics_process(delta):
	if is_firing:
		rotate(deg_to_rad(stats.laser_speed.value) * delta)
		_check_collision()

func _on_charge_timer_timeout():
	is_firing = true
	fire_timer.start()
	
func _on_timer_timeout():
	is_firing = false

func _check_collision():
	var space_state = get_world_2d().direct_space_state
	var ray_query = PhysicsRayQueryParameters2D.new()
	ray_query.from = global_position
	ray_query.to = global_position + laser_line.points[1].rotated(rotation)
	var result = space_state.intersect_ray(ray_query)

	if result:
		result.collider.take_damage(stats.damage.value)
