extends "res://equipment/base_equipment.gd"

@onready var air_strike_target = $Area2D
@onready var collision = $Area2D/CollisionShape2D
@onready var animation_player = $AnimationPlayer
@onready var strike_timer = $StrikeTimer
@onready var danger_close_timer = $DangerCloseTimer
@onready var sprite = $Area2D/CollisionShape2D/Crosshairs
@onready var plane_shadow_sprite = $PlaneShadow
@onready var animated_sprite = $Area2D/CollisionShape2D/AnimatedSprite2D

@onready var animation_player_2 = $Area2D/AnimationPlayer2

@onready var targeting_sprite = preload("res://assets/sprites/airstrike_targeting.png")
@onready var firing_sprite = preload("res://assets/sprites/airstrike_firing.png")

var target_position = Vector2()
var air_strike_delay = 5
var air_strike_mobs = []
var is_strike_active = false

func _init():
	type = "weapon"
	equipment_id = "air_strike"
	equipment_name = "Air Strike"
	equipment_description = "air strike danger close"
	add_stat("damage", 200, 0.05)
	add_stat("radius", 100, 0.05)
	add_stat("frequency", 5, 0.05)

func _ready():
	GameStateManager.hud.trigger_air_strike_button.show()
	animated_sprite.hide()
	sprite.hide()
	strike_timer.wait_time = stats.frequency.value
	collision.shape.radius = stats.radius.value
	var sprite_size = sprite.texture.get_size()
	var anim_sprite_size = animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, 0).get_size()
	var desired_sprite_size = stats.radius.value * 2
	var scale_factor_sprite = desired_sprite_size / max(sprite_size.x, sprite_size.y)
	var scale_factor_anim_sprite = desired_sprite_size / max(anim_sprite_size.x, anim_sprite_size.y)
	sprite.scale = Vector2(scale_factor_sprite, scale_factor_sprite)
	animated_sprite.scale = Vector2(scale_factor_anim_sprite, scale_factor_anim_sprite)
	allowed_in_armoury = false

func _process(_delta):
	if is_strike_active:
		air_strike_target.global_position = target_position

func _on_danger_close_timer_timeout():
	sprite.texture = firing_sprite
	animation_player.play("air_strike_firing")
	animation_player_2.play("air_strike_flyover")

func _unhandled_input(event):
	if event.is_action_pressed("fire"):
		trigger_airstrike()

func trigger_airstrike():
	sprite.texture = targeting_sprite
	sprite.show()
	animation_player.play("air_strike_targeting")
	collision.disabled = false
	target_position = self.global_position
	strike_timer.start(air_strike_delay)
	danger_close_timer.start(air_strike_delay - 1)
	is_strike_active = true

func _on_strike_timer_timeout():
	GameStateManager.player.get_node("AnimationPlayer").play("screen_flash")
	for mob in air_strike_mobs:
		mob.take_damage(stats.damage.value)
	# air_strike_mobs.clear()  
	collision.disabled = true
	sprite.hide()
	GameStateManager.hud.trigger_air_strike_button.hide()

func _on_area_2d_body_entered(body):
	if body not in air_strike_mobs: 
		air_strike_mobs.append(body)
	
func _on_area_2d_body_exited(body):
	if body in air_strike_mobs:
		air_strike_mobs.erase(body)

func _on_animation_player_2_animation_finished(anim_name):
	animated_sprite.show()
	animated_sprite.play("default")
	
func _on_animated_sprite_2d_animation_finished():
	is_strike_active = false
	animated_sprite.hide()
	air_strike_target.position = Vector2.ZERO 
	GameStateManager.player.replace_equipment("air_strike")
