extends Node2D

# Customize the properties of your circle
@export var radius = 64
@export var color = Color(1, 1, 1, 1)

func _ready():
	pass

func _draw():
	# Draw the circle with the given properties
	draw_circle(Vector2.ZERO, radius, color)
