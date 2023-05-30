extends Node

@onready var game_scene = preload("res://main/game/game.tscn").instantiate()

var current_scene

var pools: Pools
var main
var game
var player
var armoury
var hud
var main_menu
var level_up_menu
var game_over
var mob_node
var projectile_node
var item_node
var poi_node

var console_open = false

var _paused := false

func pause():
	_paused = true
	get_tree().paused = true

func resume():
	_paused = false
	if !console_open:
		get_tree().paused = false

func is_paused() -> bool:
	return _paused

func console_toggle(value: bool) -> void:
	console_open = value

func restart():
	SpawnManager.stop_spawning()
	var pools: Pools
	resume()
	get_tree().reload_current_scene()
