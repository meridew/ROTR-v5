extends Area2D

@export var entity_type = "item"
@export var entity_variant = "xp"
@export var acceleration = 1000
@export var max_speed = 10000

var value = 50
var velocity = Vector2.ZERO

func calculate_new_position(player_position: Vector2, delta: float) -> Vector2:
	var direction: Vector2 = (player_position - position).normalized()
	velocity = direction * acceleration

	if velocity.length() > max_speed:
		velocity = direction * max_speed

	return position + velocity * delta
	
