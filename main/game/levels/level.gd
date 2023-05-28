extends Node2D

@onready var air_drop_item_scene = preload("res://items/item_crate.tscn")
@onready var air_drop_timer = $AirDropTimer
@onready var air_drop_poi_wait_timer = $AirDropPoiWaitTimer

func _ready():
	air_drop_timer.start()

func _on_air_drop_timer_timeout():
	randomize()
	var air_drop_item = air_drop_item_scene.instantiate()
	air_drop_item.global_position = Vector2(randf_range(-10000,10000),randf_range(-10000,10000))
	GameStateManager.poi_node.add_child(air_drop_item)
	air_drop_timer.wait_time = randf_range(240,300)
	GameStateManager.hud.flash_radar()
