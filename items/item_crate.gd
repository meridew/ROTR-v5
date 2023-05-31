extends Area2D

@onready var sprite = $Sprite2DCrate
@onready var animation_player = $AnimationPlayer
@onready var radar_marker: PackedScene = preload("res://main/game/hud/radar/poi_marker.tscn")
@onready var entity_type = "item"
@onready var entity_variant = "airdrop"

func _ready():
	set_meta("radar_marker",radar_marker)

func _on_body_entered(_body):
	GameStateManager.hud.trigger_air_strike_button.show()
	GameStateManager.player.get_equipment("air_strike",true)
	GameStateManager.hud.remove_marker(self)
	queue_free()
