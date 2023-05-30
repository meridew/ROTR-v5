extends Area2D

@export var entity_type = "projectile"
@export var damage: float
@export var projectile_speed: float
@export var projectile_size: float
@export var projectile_passthrough: int
@export var projectile_knockback: float

@onready var player = GameStateManager.player

var projectile_passedthrough: int = 0
var velocity = Vector2.ZERO
var target

func init_stats(stats):
	damage = stats.damage.value
	scale = Vector2(stats.projectile_size.value,stats.projectile_size.value)
	projectile_speed = stats.projectile_speed.value
	projectile_passthrough = stats.projectile_passthrough.value
	projectile_knockback = stats.projectile_knockback.value
	
func _process(delta):
	global_position += velocity * delta

func set_direction(angle):
	velocity = Vector2(projectile_speed, 0).rotated(angle)

func _on_area_entered(area):
	if area.is_in_group("mobs"):
		area.take_damage(damage)
		projectile_passedthrough += 1
		if projectile_passedthrough >= projectile_passthrough:
			PoolManager.release_projectile(self)

func _on_visible_on_screen_notifier_2d_screen_exited():
	PoolManager.release_projectile(self)

func _on_body_entered(body):
	if body.is_in_group("mobs"):
		body.take_damage(damage)
		body.knockback(projectile_knockback)
		projectile_passedthrough += 1
		if projectile_passedthrough > projectile_passthrough:
			PoolManager.release_projectile(self)
			
func set_target(_target):
	target = target
