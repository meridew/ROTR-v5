extends CanvasLayer

@onready var button_scene = preload("res://main/game/menus/levelup/buttons/level_up_button.tscn")
@onready var button_container = $MarginContainer/VBoxContainer/ButtonsContainer
@onready var audio_player = $AudioStreamPlayer2D
@onready var animation_player = $AnimationPlayer

@export var buttons = []
@export var buttons_amount = 5

func _ready():
	hide()

func show_menu():
	GameStateManager.pause()
	level_up_animation()
	GameStateManager.game.set_music_volume("menu")
	remove_buttons()  # Add this line here to remove existing buttons
	create_buttons(buttons_amount)
	show()
	
func _on_button_pressed(button: Button): 
	process_button_press(button) 
	remove_buttons() 
	hide() 
	GameStateManager.player.process_level_up_queue()
	GameStateManager.resume()

func create_buttons(quantity: int) -> void:
	var options = get_random_options(quantity)
	for option_key in options.keys():
		var option = options[option_key]
		var equipment_name = format_id_string(option.equipment_id)
		var button_instance = button_scene.instantiate()
		buttons.append(button_instance)
		var button_text: String
		var stat_name: String
		if(option.type == "stat"):
			stat_name = format_id_string(option.stat_id)
			button_text = "UPGRADE" + "\n" + str(equipment_name) + "\n" + "INCREASE" + "\n" + str(stat_name) + "\n" + str(option.rate_increase * 100) + "%" + "\n" + str(option.level) + "/" + str(option.max_level)
			button_instance.set_meta("select",option)
			button_instance.get_node("MarginContainer").get_node("info_container").get_node("label_new").hide()
		elif(option.type == "weapon"):
			button_text = "WEAPON" + "\n" + str(equipment_name) + "\n" + str(option.equipment_description)
			button_instance.set_meta("select",option)
		elif(option.type == "utility"):
			button_text = "UTILITY" + "\n" + str(equipment_name) + "\n" + str(option.equipment_description)
			button_instance.set_meta("select",option)
		button_instance.call_deferred("set_upgrade_type",button_text)
		button_instance.call_deferred("set_icon",str(option.equipment_id))
		button_instance.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button_instance.connect("pressed", Callable(self, "_on_button_pressed").bind(button_instance))
		button_container.add_child(button_instance)

func format_id_string(id_string: String) -> String:
	var words = id_string.split("_")
	for i in range(words.size()):
		words[i] = words[i].capitalize()
	return " ".join(words)

func process_button_press(button):
	var option = button.get_meta("select")
	if option.type == "stat":
		option.upgrade_stat()
	else:
		GameStateManager.player.get_equipment(option.equipment_id)

func remove_buttons():
	for button in button_container.get_children():
		if button is Button:
			button.queue_free()
			
func get_random_options(quantity: int):
	var options = GameStateManager.armoury.get_available_equipment()
	options.merge(GameStateManager.armoury.get_available_upgrades())
	var random_options = {}
	for i in range(quantity):
		if options.size() == 0:  # Break the loop if there are no more options left
			break
		var random_key = options.keys()[randi() % options.size()]
		random_options[random_key] = options[random_key]
		options.erase(random_key)  # Remove the selected option from the 'options' dictionary
	return random_options

func _on_skip_button_pressed(): 
	remove_buttons() 
	hide() 
	GameStateManager.player.process_level_up_queue()
	GameStateManager.resume()

func level_up_animation():
	audio_player.play()
	animation_player.play("menu_flash")
