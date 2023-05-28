class_name BaseMob

const mob_scene = preload("res://mobs/mob.tscn")

var mob: RigidBody2D

# Scaling factor for mob mass; each unit increase in scale quadruples the mob's mass
# More mass means more force required to accelerate the mob
var mass_scaling_factor = 100.0

# Scaling factors for mob speed, acceleration, and frames-per-second (fps); each unit increase in scale halves these values
# Lower speed means the mob moves slower
# Lower acceleration means the mob takes longer to reach top speed
# Lower fps means the mob's animations update less frequently, making them appear slower
var speed_scaling_factor = 2.0
var acceleration_scaling_factor = 2.0
var fps_scaling_factor = 0.8

func _init(entity_variant: String, base_damage: float, base_hp: float, base_speed: float, base_value: float, base_fps: float, base_acceleration: float, base_mass: float, base_scale: int, randomness: float):
	mob = mob_scene.instantiate()
	mob.entity_variant = entity_variant
	mob.mob_scale = Vector2(base_scale,base_scale)
	set_random_factors(randomness,base_hp,base_damage,base_value)
	set_physics_scaling(base_mass,base_speed,base_acceleration,base_fps)
	
# Apply the scaling factors to the mob's physics-related attributes
# The sqrt function provides a less severe scaling effect than linear scaling
func set_physics_scaling(base_mass: float, base_speed: float, base_acceleration: float, base_fps: float):
	# Calculate physics properties based on scaling first
	mob.mob_mass = base_mass * sqrt(mass_scaling_factor * mob.mob_scale.x)
	mob.mob_speed = base_speed / sqrt(speed_scaling_factor * mob.mob_scale.x)
	mob.mob_acceleration = base_acceleration / sqrt(acceleration_scaling_factor * mob.mob_scale.x)
	mob.mob_fps = base_fps / sqrt(fps_scaling_factor * mob.mob_scale.x)

	# Now apply randomness to each property
	mob.mob_mass = get_randomised_value(mob.mob_mass)
	mob.mob_speed = get_randomised_value(mob.mob_speed)
	mob.mob_acceleration = get_randomised_value(mob.mob_acceleration)
	mob.mob_fps = get_randomised_value(mob.mob_fps)

# Set the random factors for mob damage, hp, and value; these random factors provide variation in mob stats
func set_random_factors(randomness: float, base_hp: float, base_damage: float, base_value: float):
	mob.mob_random_factor = get_random_factor(randomness)
	mob.mob_damage = get_randomised_value(base_damage)
	mob.mob_hp = get_randomised_value(base_hp)
	mob.mob_value = get_randomised_value(base_value)
	
# Get a random factor within a range determined by the "randomness" parameter
func get_random_factor(randomness: float) -> float:
	return randf_range(1 - randomness, 1 + randomness)

# Get a randomised value by multiplying a base value by a random factor
func get_randomised_value(value: float) -> float:
	return value * self.mob.mob_random_factor
