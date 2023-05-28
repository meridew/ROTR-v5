extends Node2D

@onready var hud_scene = preload("res://main/game/hud/hud.tscn")
@onready var level_scene = preload("res://main/game/levels/level.tscn")
@onready var player_scene = preload("res://main/game/player/player.tscn")
@onready var level_up_menu_scene = preload("res://main/game/menus/levelup/level_up_menu.tscn")
@onready var game_over_scene = preload("res://main/game/menus/game_over/game_over.tscn")
@onready var debug_console_scene = preload("res://main/game/hud/console.tscn")

@onready var music = $Music
@onready var mob_node = $MobLayer
@onready var item_node = $ItemLayer
@onready var projectile_node = $ProjectileLayer
@onready var poi_node = $PoiLayer
@onready var respawn_timer = $RespawnTimer
@onready var game_timer = $GameTimer

@onready var main
@onready var player_id
@onready var player
@onready var level
@onready var hud
@onready var armoury
@onready var game_over
@onready var level_up_menu
@onready var debug_console
@onready var game_time
@onready var game_time_seconds_passed = 0

func _ready():
	_init_game()
	start_game()

func set_music_volume(mode):
	if mode == "game":
		music.volume_db = 10
	elif mode == "menu":
		music.volume_db = 0
	elif mode == "game_over":
		music.volume_db = -100

func start_game():
	PoolManager.initialize_pools()
	PoolManager.set_process(true)
	SpawnManager.start_spawning()

func _init_game():
	hud = hud_scene.instantiate()
	GameStateManager.hud = hud
	add_child(hud)
	player = new_player(player_id)
	GameStateManager.player = player
	armoury = new_armoury()
	GameStateManager.armoury = armoury
	add_child(player)
	add_child(armoury)
	player.get_equipment(player.default_equipment_id,true)
	player.get_equipment("air_strike",true)
	
	GameStateManager.game = self
	
	armoury = get_node("Armoury")
	player = get_node("Player")
	
	level = level_scene.instantiate()
	
	level_up_menu = level_up_menu_scene.instantiate()
	game_over = game_over_scene.instantiate()
	debug_console = debug_console_scene.instantiate()
		
	GameStateManager.mob_node = mob_node
	GameStateManager.item_node = item_node
	GameStateManager.projectile_node = projectile_node
	GameStateManager.poi_node = poi_node
	GameStateManager.hud = hud
	GameStateManager.game_over = game_over
	GameStateManager.level_up_menu = level_up_menu
	
	add_child(level)
	add_child(hud)
	add_child(level_up_menu)
	add_child(game_over)
	add_child(debug_console)

func _on_game_timer_timeout():
	game_time_seconds_passed += 1
	var minutes = int(game_time_seconds_passed / 60)
	var seconds = game_time_seconds_passed % 60
	game_time = str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)	

func new_player(player_id: BasePlayer.PLAYER_ID):
	var base_player = BasePlayer.new()
	return base_player.new_player(player_id)

func new_armoury():
	return Armoury.new()
