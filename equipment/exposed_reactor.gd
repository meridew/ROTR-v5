extends "res://equipment/base_equipment.gd"

@onready var fire_timer = $fire_timer
@onready var collision = $Area2D/CollisionShape2D
@onready var sticky_nodes = get_tree().get_nodes_in_group("sticky_nodes")

var mobs_in_range = {}
var timer = 0.0
var radiation_color = Color(0,204,0,0.1)
var circle_vector = Vector2.ZERO

func _init():
	type = "weapon"
	equipment_id = "exposed_reactor"
	equipment_name = "Exposed Reactor"
	add_stat("damage", 10, 0.1)
	add_stat("frequency", 1,-0.1)
	add_stat("damage_radius", 40,0.1)
	
func _ready():
	fire_timer.wait_time = stats.frequency.value
	collision.shape.radius = stats.damage_radius.value
	stats.damage_radius.connect("stat_changed", Callable(self, "_on_stat_changed"))

func calculate_dps():
	dps = stats.damage.value * stats.frequency.value

func _on_stat_changed():
	collision.shape.radius = stats.damage_radius.value
	queue_redraw()

func _process(delta):
	timer += delta

	if timer >= stats.frequency.value:
		apply_damage_to_enemies()
		timer = 0.0

func apply_damage_to_enemies():
	for mob in mobs_in_range.values():
		if is_instance_valid(mob):
			mob.take_damage(stats.damage.value)

func _draw():
	draw_circle(circle_vector, stats.damage_radius.value, radiation_color)

func _on_area_2d_area_entered(area):
	if area.is_in_group("mobs"):
		mobs_in_range[area.get_instance_id()] = area

func _on_area_2d_area_exited(area):
	if area.is_in_group("mobs"):
		mobs_in_range.erase(area.get_instance_id())

func _on_area_2d_body_entered(body):
	if body.is_in_group("mobs"):
		mobs_in_range[body.get_instance_id()] = body

func _on_area_2d_body_exited(body):
	if body.is_in_group("mobs"):
		mobs_in_range.erase(body.get_instance_id())
