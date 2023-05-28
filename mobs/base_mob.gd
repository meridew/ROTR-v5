extends RigidBody2D

@export var entity_type = "mob"
@export var value: int = 50
@export var damage: float = 10
@export var original_collision_layer: int = 2  # Change this to the correct layer for mobs

@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var particles_1 = $AnimatedSprite2D/GPUParticles2D
@onready var particles_2 = $AnimatedSprite2D/GPUParticles2D2
@onready var bleed_timer = $BleedTimer
@onready var collision = $CollisionShape2D
@onready var audio_fx = $Audio_FX

var random_factor = 0.2
var knock_back = Vector2.ZERO
var knock_back_decay = 0.8
var mob_hp = 100
var mob_speed = 100
var acceleration: float = 500
var mob_boss_scale = Vector2(3,3)
var animation_fps = 6

var previous_position
var direction: Vector2

var mob_target

func _ready():
	set_mob()
	animation_player.connect("animation_finished",Callable(self,"_on_animation_finished"))

func _physics_process(_delta):
	move_mob()

func move_mob():
	if mob_target:
		# Calculate the direction to the player
		var direction_to_player = (mob_target.global_position - global_position).normalized()
		# Accelerate towards the player
		var force = direction_to_player * acceleration
		# Apply the force
		apply_central_force(force)
		# Clamp the linear velocity to the max_speed
		if linear_velocity.length() > mob_speed:
			linear_velocity = linear_velocity.normalized() * mob_speed

		if direction_to_player.x < 0:
			animated_sprite.flip_h = true
		elif direction_to_player.x > 0:
			animated_sprite.flip_h = false

func set_target(_mob_target):
	mob_target = _mob_target

func apply_knockback(knock_back_direction,knock_back_strength) -> void:
	var knock_back_force = knock_back_direction * knock_back_strength
	knock_back += knock_back_force

func die():
	PoolManager.acquire_item(self,value)
	PoolManager.release_mob(self)

func random_bool() -> bool:
	var random_int = randi() % 2
	return random_int == 0

func take_damage(damage_amount):
	bleed()
	mob_hp -= damage_amount
	animation_player.play("flash")
	
func bleed():
	particles_1.emitting = true
	particles_2.emitting = true
	bleed_timer.start()
	
func _on_bleed_timer_timeout():
	particles_1.emitting = false
	particles_2.emitting = false

func make_boss():
	entity_type = "boss_mob"
	collision.scale = mob_boss_scale
	animated_sprite.scale = mob_boss_scale
	mob_hp = (SpawnManager.current_spawn_params.mobs_hp * 10) * randf_range(1 - random_factor, 1 + random_factor)
	mob_speed = 50 * randf_range(1 - random_factor, 1 + random_factor)
	set_animation_fps()

func set_animation_fps():
	var desired_fps = mob_speed * 0.06
	var original_fps = 6.0  # adjust this to match your animation's original FPS
	animated_sprite.speed_scale = desired_fps / original_fps

func set_mob():
	entity_type = "mob"
	mob_hp = SpawnManager.current_spawn_params.mobs_hp * randf_range(1 - random_factor, 1 + random_factor)
	mob_speed = 100 * randf_range(1 - random_factor, 1 + random_factor)
	set_animation_fps()

func _on_animation_player_animation_finished(anim_name):
	if mob_hp <= 0: 
		die()
