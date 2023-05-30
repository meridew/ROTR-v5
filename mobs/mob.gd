extends RigidBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite_shadow: Sprite2D = $AnimatedSprite2D/Sprite2D
@onready var radar_marker: PackedScene = preload("res://main/game/hud/radar/mob_marker.tscn")

var entity_type: String = "mob"
var entity_variant: String
var mob_damage: float
var mob_hp: float
var mob_speed: float
var mob_acceleration: float
var mob_value: float
var mob_fps: float
var mob_random_factor: float
var mob_target: CharacterBody2D
var mob_scale: Vector2
var mob_mass: float
var size

func _ready():
	self.name = self.entity_type + "_" + self.entity_variant
	size = animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation,0).get_size()
	set_meta("radar_marker",radar_marker)
	set_mob_scale()
	set_animation_fps()

func _physics_process(_delta) -> void:
	move_mob()

func move_mob():
	if mob_target:
		# Calculate the direction to the player
		var direction_to_player = (mob_target.global_position - global_position).normalized()
		
		# If the mob is moving slower than its max speed, accelerate towards the player.
		if linear_velocity.length() < mob_speed:
			var acceleration_force = direction_to_player * mob_acceleration
			apply_central_force(acceleration_force)
		else:
			# If the mob is moving faster than its max speed, apply a deceleration force.
			var deceleration_force = -linear_velocity.normalized() * mob_acceleration
			apply_central_force(deceleration_force)
		
		flip_sprite(direction_to_player)

func knockback(amount):
	var knockback_direction = -linear_velocity.normalized()
	apply_central_impulse(knockback_direction * amount)

func take_damage(damage_amount):
	mob_hp -= damage_amount
	animation_player.play("flash")
	
func _on_animation_player_animation_finished(anim_name):
	if mob_hp <= 0: 
		die()

func die():
	GameStateManager.pools.acquire_item(self, mob_value)
	GameStateManager.pools.release_mob(self)

func flip_sprite(direction_to_player):
	if direction_to_player.x < 0:
		animated_sprite.flip_h = true
	elif direction_to_player.x > 0:
		animated_sprite.flip_h = false

func set_animation_fps():
	var original_fps = 6.0
	animated_sprite.speed_scale = mob_fps / original_fps

func set_target(target):
	mob_target = target

func set_mob_scale():
	animated_sprite.scale = mob_scale
	collision_shape.scale = mob_scale

func set_hp(hp):
	mob_hp = hp

func change_mob(animation_name):
	var homosapien_offset = Vector2(1,-28)
	var neanderthal_offset = Vector2(2,-32)
	var caveman_offset = Vector2(5,-24)
	animated_sprite.set_animation(animation_name)
	var offset: Vector2
	match animation_name:
		"homosapien": offset = homosapien_offset
		"neanderthal": offset = neanderthal_offset
		"caveman": offset = caveman_offset
	sprite_shadow.offset = offset
	animated_sprite.play()
