extends Node

@onready var music = $Music
@onready var intro = $Intro
@onready var intro_animation = $Intro/TextureRect/AnimatedSprite2D
@onready var main_menu = $MainMenu
@onready var player_select = $PlayerSelect
@onready var game_scene = preload("res://main/game/game.tscn")
@onready var obelisk_spriteframes = preload("res://assets/spriteframes/players/player_obelisk.tres")
@onready var slugger_spriteframes = preload("res://assets/spriteframes/players/player_slugger.tres")

var player_id: BasePlayer.PLAYER_ID
var player_weapon
var player_spriteframes
var game

func _ready():
	GameStateManager.main = self
	GameStateManager.main_menu = main_menu
	main_menu.hide()
	player_select.hide()
	game = game_scene.instantiate()

func _unhandled_input(event):
	if intro.visible and event.is_action_pressed("ui_cancel"):
		intro_animation.stop()
		intro.hide()
		main_menu.show()

func _on_animated_sprite_2d_animation_finished():
	intro.hide()
	main_menu.show()

func _on_start_button_pressed():
	main_menu.hide()
	player_select.show()

func _on_character_1_pressed():
	player_id = BasePlayer.PLAYER_ID.slugger
	start_game()

func _on_character_2_pressed():
	player_id = BasePlayer.PLAYER_ID.obelisk
	start_game()
	
func start_game():
	var game = game_scene.instantiate()
	game.player_id = player_id
	add_child(game)
	player_select.hide()
	music.stop()
