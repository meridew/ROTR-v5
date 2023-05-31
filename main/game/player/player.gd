extends CharacterBody2D

@export var entity_type: String
@export var entity_variant: BasePlayer.PLAYER_ID
@export var default_equipment_id: String
@export var player_level: int = 0
@export var player_max_hp: float
@export var player_hp: float
@export var player_max_xp: float = 100
@export var player_xp: float = 0
@export var player_speed: float
@export var player_xp_level_multiplier: float = 1.2

@export var equipment: Dictionary

@onready var damage_timer = $Damage_Timer
@onready var animation_player = $AnimationPlayer
@onready var animated_sprite = $AnimatedSprite2D
@onready var player_camera = $Camera2D
@onready var sprite_shadow = $AnimatedSprite2D/Shadow

@onready var joystick

var mobs_in_range = {}
var level_up_queue = []

func _ready():
	player_hp = player_max_hp

func get_equipment(equipment_id: String, add_to_hud = false):
	var equipment_instance = GameStateManager.armoury.take_equipment(equipment_id)
	equipment[equipment_id] = equipment_instance
	add_child(equipment_instance)
	if add_to_hud:
		GameStateManager.hud.add_equipment(equipment_id)
	update_debug_info()

func replace_equipment(equipment_id: String, remove_from_hud = true):
	var equipment_instance = equipment[equipment_id]
	remove_child(equipment_instance)
	GameStateManager.armoury.replace_equipment(equipment_id)
	if remove_from_hud:
		GameStateManager.hud.replace_equipment(equipment_id)
	update_debug_info()

func _physics_process(_delta: float):
	get_input()
	move_and_slide()
	handle_mobs_in_range()

func get_input():
	if GameStateManager.console_open:
		return
	else:
		var input_direction = Input.get_vector("left", "right", "up", "down")

		# Add the joystick output to the input direction
		if joystick.is_pressed:
			input_direction += joystick.output

		# Make sure the length of the input direction does not exceed 1
		# input_direction = input_direction.clamped(1)
		
		velocity = input_direction * player_speed
		
		# Check if the player is moving
		if input_direction.x != 0 or input_direction.y != 0:
			animated_sprite.set_flip_h(input_direction.x < 0)
			
			# Change the animation to "moving"
			if animated_sprite.animation != "moving":
				animated_sprite.animation = "moving"
		else:
			# If the player is not moving, change the animation to "idle"
			if animated_sprite.animation != "idle":
				animated_sprite.animation = "idle"

func level_up():  
	while player_xp >= player_max_xp:  
		player_xp -= player_max_xp  
		player_max_xp *= player_xp_level_multiplier  
		player_level += 1   
		level_up_queue.append(player_level)

	if level_up_queue.size() > 0:  
		process_level_up_queue()

func process_level_up_queue():
	if level_up_queue.size() > 0: 
		var next_level = level_up_queue.pop_front() 
		GameStateManager.hud.set_level(next_level, player_xp, player_max_xp) 
		GameStateManager.level_up_menu.show_menu()
		update_debug_info()

func add_xp(area):
	animation_player.play("item_collected")
	player_xp += area.value
	GameStateManager.hud.set_xp(player_xp)
	if player_xp >= player_max_xp:
		level_up()

func handle_mobs_in_range():
	if mobs_in_range:
		var mobs_total_damage = 0
		for mob in mobs_in_range.values():  # Iterate over the mobs (values), not the instance IDs (keys)
			mobs_total_damage += mob.mob_damage
		take_damage(mobs_total_damage)
		animation_player.play("player_took_damage")

func take_damage(amount):
	if(damage_timer.is_stopped()):
		player_hp -= amount
		GameStateManager.hud.set_hp(player_hp)
		if player_hp <= 0:
			player_died()
		damage_timer.start()

func add_hp(hp_amount):
	if player_hp < player_max_hp:
		player_hp += hp_amount
		if player_hp > player_max_hp:
			player_hp = player_max_hp
		GameStateManager.hud.set_hp(player_hp)

func player_died():
	GameStateManager.game_over.show_screen()

func _on_pickup_area_area_entered(item):
	if(item.is_in_group("xp")):
		got_xp(item)

func got_xp(item):
	add_xp(item)
	GameStateManager.pools.release_item(item)

func _on_player_took_equipment(equipment_id):
	print("player_took_equipment")
	add_child(GameStateManager.armoury[equipment_id])

func _on_damage_area_body_entered(body):
	mobs_in_range[body.get_instance_id()] = body

func _on_damage_area_body_exited(body):
	mobs_in_range.erase(body.get_instance_id())

func set_spriteframes(spriteframes):
	animated_sprite.sprite_frames = spriteframes
	animated_sprite.play()

func set_weapon(weapon_id):
	get_equipment(weapon_id)
	GameStateManager.hud.add_equipment(weapon_id)

func set_shadow(shadow_enabled):
	sprite_shadow.visible = shadow_enabled

func update_debug_info():
	var debug_text = ""
	for e in equipment.keys():
		debug_text += "Weapon: " + str(e) + "\n"
		for s in equipment[e].stats.keys():
			var v = equipment[e].stats[s].value
			debug_text += "   - " + str(s) + ": " + str(v) + "\n"
	GameStateManager.hud.debug_info.text = debug_text
