extends Node

const MIN_TARGET_SPAWN_DISTANCE = 1000
const MAX_TARGET_SPAWN_DISTANCE = 1500
const MIN_TARGET_RESPAWN_DISTANCE = 1500
const MAX_TARGET_RESPAWN_DISTANCE = 5000

var all_spawn_params_path = "res://spawn_data.csv"
var all_spawn_params = {}
var current_spawn_params
var spawn_params_update_timer = Timer.new()
var mob_spawn_timer = Timer.new()
var boss_mob_spawn_timer = Timer.new()
var respawn_timer = Timer.new()
var spawn_params_time_period = 0

var difficulty = 1

func _ready():
	_init_spawn_manager()
	
func _init_spawn_manager():
	_init_all_spawn_params(all_spawn_params_path)
	_init_spawn_params_timer()
	_init_mob_spawn_timer()
	_init_mob_boss_spawn_timer()
	_init_respawn_timer()

func _init_all_spawn_params(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var headers = file.get_csv_line()
	while not file.eof_reached():
		var row = file.get_csv_line()
		if row.size() > 0:
			var elapsed_seconds = str(row[0])
			var spawn_params = {}
			for i in range(1, row.size()):
				spawn_params[headers[i]] = row[i]
			all_spawn_params[elapsed_seconds] = spawn_params
	file.close()
	set_spawn_params()

func set_spawn_params():
	var time_period_string: String
	time_period_string = str(spawn_params_time_period)
	if all_spawn_params[time_period_string]:
		current_spawn_params = all_spawn_params[time_period_string]
		for key in current_spawn_params.keys():
			current_spawn_params[key] = int(current_spawn_params[key]) * difficulty
		print("Current spawn parameters:")
		print(current_spawn_params)

func _on_respawn_timer_timeout():
	respawn_mobs()

func _init_respawn_timer():
	respawn_timer.autostart = true
	respawn_timer.wait_time = 1
	respawn_timer.start()
	respawn_timer.connect("timeout",Callable(self,"_on_respawn_timer_timeout"))

func _init_spawn_params_timer():
	spawn_params_update_timer.connect("timeout",Callable(self,"_on_spawn_params_timer_timeout"))
	spawn_params_update_timer.wait_time = 10

func _init_mob_spawn_timer():
	mob_spawn_timer.connect("timeout",Callable(self,"_on_mob_spawn_timer_timeout"))

func _init_mob_boss_spawn_timer():
	boss_mob_spawn_timer.connect("timeout",Callable(self,"_on_boss_mob_spawn_timer_timeout"))
	boss_mob_spawn_timer.one_shot = true
		
func start_spawning():
	add_child(spawn_params_update_timer)
	add_child(mob_spawn_timer)
	add_child(boss_mob_spawn_timer)
	add_child(respawn_timer)
	spawn_params_update_timer.start()
	mob_spawn_timer.start()

func _on_spawn_params_timer_timeout():
	set_spawn_params()
	spawn_params_time_period += spawn_params_update_timer.wait_time
	mob_spawn_timer.wait_time = 1.0 / current_spawn_params.mobs_per_second
	boss_mob_spawn_timer.wait_time = 1.0 / current_spawn_params.boss_mobs_per_second
	
	if current_spawn_params.mobs_per_second != 0:
		mob_spawn_timer.wait_time = 1.0 / current_spawn_params.mobs_per_second
		if mob_spawn_timer.is_stopped():
			mob_spawn_timer.start()
	else:
		mob_spawn_timer.stop()
	
	if current_spawn_params.boss_mobs_per_second != 0: 
		boss_mob_spawn_timer.wait_time = 1.0 / current_spawn_params.boss_mobs_per_second
		if boss_mob_spawn_timer.is_stopped(): 
			boss_mob_spawn_timer.start()
	else:
		boss_mob_spawn_timer.stop()

func enable_mob(mob_type: String, force: bool = false):
	var mob
	var pool_active
	var mobs_max
	match mob_type:
		"mob": 
			pool_active = PoolManager.mob_pool_active
			mobs_max = current_spawn_params.mobs_max
		"boss_mob":
			pool_active = PoolManager.boss_mob_pool_active
			mobs_max = current_spawn_params.boss_mobs_max
	if force or pool_active.size() < mobs_max:
		mob = PoolManager.acquire_mob(mob_type)
		if mob:
			var mob_choice = randi() % 3  # gives a random integer 0, 1, or 2
			if mob_choice == 0:
				mob.change_mob("homosapien")
			elif mob_choice == 1:
				mob.change_mob("neanderthal")
			else:
				mob.change_mob("caveman")
			PoolManager.enable(mob)

func _on_mob_spawn_timer_timeout():
	enable_mob("mob")

func _on_boss_mob_spawn_timer_timeout():
	enable_mob("boss_mob")
	
func change_mob(mob, animation_name):
	var animated_sprite = mob.get_node("AnimatedSprite2D")
	animated_sprite.set_animation(animation_name)

func get_random_position():
	randomize()
	var spawn_distance = randf_range(MIN_TARGET_SPAWN_DISTANCE, MAX_TARGET_SPAWN_DISTANCE)
	var angle = deg_to_rad(randf_range(0, 360))
	var spawn_position = GameStateManager.player.global_position + Vector2(cos(angle), sin(angle)) * spawn_distance
	return spawn_position

func respawn_mobs():
	randomize()
	var spawn_distance = randf_range(MIN_TARGET_RESPAWN_DISTANCE, MAX_TARGET_RESPAWN_DISTANCE)
	for mob in PoolManager.mob_pool_active.values():
		var distance_to_player = mob.global_position.distance_to(GameStateManager.player.global_position)
		if distance_to_player >= spawn_distance:
			var player_direction = GameStateManager.player.get_real_velocity().normalized()
			var angle_range = PI/6  # adjust this value to change the spawn angle range
			var angle_offset = randf_range(-angle_range, angle_range)  # random angle in the range
			var spawn_angle = player_direction.angle() + angle_offset
			var spawn_position = GameStateManager.player.global_position + Vector2(cos(spawn_angle), sin(spawn_angle)) * spawn_distance
			mob.global_position = spawn_position
