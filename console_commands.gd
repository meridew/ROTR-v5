class_name ConsoleCommands

var god_mode = false
var add_equipment_to_hud = true

func set_spawn_paramsd(seconds):
	if SpawnManager.all_spawn_params[seconds]:
		SpawnManager.current_spawn_params = SpawnManager.all_spawn_params[seconds]

func set_player_speed(speed):
	GameStateManager.player.player_speed = speed

func die():
	GameStateManager.console_toggle(false)
	GameStateManager.player.player_died()

func spawn_boss_mob(amount = "1"):
	for i in range(amount.to_int()):
		SpawnManager.enable_mob("boss_mob",true)

func spawn_mob(amount = "1"):
	for i in range(amount.to_int()):
		SpawnManager.enable_mob("mob",true)
	
func kill_mobs():
	for mob in GameStateManager.pools.mob_pool_active.values():
		if mob.visible:
			mob.die()
	for mob in GameStateManager.pools.boss_mob_pool_active.values():
		if mob.visible:
			mob.die()

func god():
	god_mode = !god_mode
	GameStateManager.player.get_node("Damage_Area").get_node("Damage_Collision").set_deferred("disabled",god_mode)
	return "[color=darkgreen]God mode toggled[/color]\n"

func get_equipment(equipment_id=""):
	if equipment_id == "":
		return "[color=darkred]Error: Missing argument. Usage: get_equipment <equipment_id>\n[/color]"
	if equipment_id in GameStateManager.player.equipment:
		return "[color=darkred]Error: Player: equipment_id " + equipment_id + " already exists\n[/color]"
	if equipment_id in GameStateManager.armoury.equipment:
		GameStateManager.player.get_equipment(equipment_id,add_equipment_to_hud)
	else:
		return "[color=darkred]Error: Armoury: equipment_id " + equipment_id + " does not exist\n[/color]"

func set_equipment(equipment_id = "", stat_id = "", value = 0):
	if equipment_id == "" or stat_id == "":
		return "[color=darkred]Error: Missing argument. Usage: set_equipment_stat <equipment_id> <stat_id> <value>\n[/color]"
	if equipment_id in GameStateManager.player.equipment:
		if stat_id in GameStateManager.player.equipment[equipment_id].stats:
			GameStateManager.player.equipment[equipment_id].stats[stat_id].set_stat(value.to_int())
			return equipment_id + " " + stat_id + " set to " + str(value) + "\n"
		else:
			return "[color=darkred]Error: Player: stat_id " + stat_id + " does not exist in " + equipment_id + "\n[/color]"
	else:
		return "[color=darkred]Error: Player: equipment_id " + equipment_id + " does not exist\n[/color]"

func new_poi():
	var pos = Vector2(1000, 1000) # replace this with the actual POI global position
	GameStateManager.player.go_to_poi(pos)
