extends Node

const gauss_round_scene = preload("res://equipment/projectiles/gauss_round.tscn")
const item_scene = preload("res://items/item.tscn")

var boss_mobs_max = 10
var boss_mob_pool_active = {}
var boss_mob_pool_inactive = {}
var mobs_max = 500
var mob_pool_active = {}
var mob_pool_inactive = {}
var gauss_round_max = 100
var gauss_round_pool_active = {}
var gauss_round_pool_inactive = {}
var item_max = 500
var item_pool_active = {}
var item_pool_inactive = {}

"""
Mob.New() parameter order:
	entity_variant: String
	base_damage: float
	base_hp: float
	base_speed: float
	base_value: float
	base_fps: float
	base_acceleration: float
	base_mass: float
	base_scale: float
	randomness: float
"""

func _ready():
	set_process(false)
		
func initialize_pools():
	init_mob_pool_inactive()
	init_boss_mob_pool_inactive()
	init_gauss_round_pool_inactive()
	init_item_pool_inactive()

	print("pools ready")

#entity_variant: String, 
#base_damage
#base_hp: float, 
#base_speed: float, 
#base_value: float, 
#base_fps: float, 
#base_acceleration: float, 
#base_mass: float, 
#base_scale: float, 
#randomness: float

var base_fps = 7
var base_speed = 100
var base_acceleration = 750

func init_mob_pool_inactive():
	var mob
	for i in range(mobs_max):
		mob = BaseMob.new("mob",10,100,base_speed,50,base_fps,base_acceleration,100,2,0.2).mob
		disable(mob)
		mob.set_target(GameStateManager.player)
		#mob.global_position = get_random_position()
		mob_pool_inactive[mob.get_instance_id()] = mob
		GameStateManager.mob_node.add_child(mob)

func init_boss_mob_pool_inactive():
	var boss_mob
	for i in range(boss_mobs_max):
		boss_mob = BaseMob.new("boss_mob",50,1000,base_speed,5000,base_fps,base_acceleration,1000,4,0.2).mob
		disable(boss_mob)
		boss_mob.set_target(GameStateManager.player)
		#boss_mob.global_position = get_random_position()
		boss_mob_pool_inactive[boss_mob.get_instance_id()] = boss_mob
		GameStateManager.mob_node.add_child(boss_mob)

func init_item_pool_inactive():
	var item
	for i in range(item_max):
		item = item_scene.instantiate()
		disable(item)
		item_pool_inactive[item.get_instance_id()] = item
		GameStateManager.item_node.add_child(item)

func init_gauss_round_pool_inactive():
	var gauss_round
	for i in range(gauss_round_max):
		gauss_round = gauss_round_scene.instantiate()
		disable(gauss_round)
		#gauss_round.global_position = get_random_position()
		gauss_round_pool_inactive[gauss_round.get_instance_id()] = gauss_round
		GameStateManager.projectile_node.add_child(gauss_round)
		
func acquire_item(mob,value) -> Area2D:
	var item
	if len(item_pool_inactive) > 0:
		item = item_pool_inactive[item_pool_inactive.keys()[0]]
		item_pool_active[(item.get_instance_id())] = item
		item_pool_inactive.erase(item.get_instance_id())
		item.global_position = mob.global_position
		item.value = value
		enable(item)
		return item
	else:
		return

func release_item(item):
	disable(item)
	item_pool_active.erase(item.get_instance_id())
	item_pool_inactive[(item.get_instance_id())] = item	

func acquire_projectile() -> Area2D:
	var projectile
	if len(gauss_round_pool_inactive) > 0:
		projectile = gauss_round_pool_inactive[gauss_round_pool_inactive.keys()[0]]
		gauss_round_pool_inactive.erase(projectile.get_instance_id())
		gauss_round_pool_active[(projectile.get_instance_id())] = projectile
		enable(projectile)
		return projectile
	else:
		return

func release_projectile(projectile):
	disable(projectile)
	gauss_round_pool_active.erase(projectile.get_instance_id())
	gauss_round_pool_inactive[(projectile.get_instance_id())] = projectile	

func acquire_mob(entity_variant):
	if entity_variant not in ["mob", "boss_mob"]:
		push_error("PoolManager couldn't acquire_mob(mob): " + entity_variant)

	var pool_inactive = mob_pool_inactive if entity_variant == "mob" else boss_mob_pool_inactive
	var pool_active = mob_pool_active if entity_variant == "mob" else boss_mob_pool_active

	if len(pool_inactive) > 0:
		var mob = pool_inactive[pool_inactive.keys()[0]]
		pool_inactive.erase(mob.get_instance_id())
		pool_active[mob.get_instance_id()] = mob
		return mob

func release_mob(mob) -> bool:
	if mob.entity_variant not in ["mob", "boss_mob"]:
		push_error("PoolManager couldn't release_mob(mob): " + mob.entity_variant)
		return false

	var pool_active = mob_pool_active if mob.entity_variant == "mob" else boss_mob_pool_active
	var pool_inactive = mob_pool_inactive if mob.entity_variant == "mob" else boss_mob_pool_inactive

	if pool_active.has(mob.get_instance_id()):
		disable(mob)
		pool_active.erase(mob.get_instance_id())
		pool_inactive[mob.get_instance_id()] = mob
		return true

	return false

func disable(obj):
	obj.visible = false
	obj.set_meta("original_collision_layer", obj.collision_layer)
	obj.collision_layer = 1 << 19
	obj.set_process(false)
	obj.set_physics_process(false)
	obj.get_node("CollisionShape2D").set_deferred("disabled",true)
	if obj.entity_type == "mob":
		obj.global_position = SpawnManager.get_random_position()

func enable(obj):
	if obj.entity_type == "mob":
		obj.global_position = SpawnManager.get_random_position()
	if obj.has_meta("original_collision_layer"):
		obj.collision_layer = obj.get_meta("original_collision_layer")
	obj.set_process(true)
	obj.set_physics_process(true)
	obj.get_node("CollisionShape2D").set_deferred("disabled",false)
	obj.visible = true
