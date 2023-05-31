extends CanvasLayer

signal hud_ready

@onready var hp_bar = $HPContainer/HP_Bar
@onready var xp_bar = $XPContainer/XP_Bar
@onready var xp_bar_label = $XPContainer/Level
@onready var animation_player = $AnimationPlayer
@onready var equipment_grid = $EquipmentGrid
@onready var game_time = $GameTime
@onready var markers_node = $Radar/Markers
@onready var radar = $Radar/RadarBackground
@onready var hud_update_timer = $HudUpdateTimer
@onready var full_screen_button = $FullScreenButton

@onready var equipment_icons = {
	"exposed_reactor": preload("res://assets/sprites/icon_exposed_reactor.png"),
	"air_strike": preload("res://assets/sprites/icon_air_strike.png"),
	"gauss_canon": preload("res://assets/sprites/icon_gauss_canon.png"),
	"laser": preload("res://assets/sprites/icon_laser.png"),
}

const RADAR_SCALE = 0.1
var entity_markers: Dictionary = {}
var entity_marker_scale = 1
var boss_mob_marker_scale = 2

func add_equipment(equipment_id: String):
	var texture_rect = TextureRect.new()
	texture_rect.name = equipment_id
	texture_rect.texture = equipment_icons[equipment_id]
	equipment_grid.add_child(texture_rect)

func _on_player_ready():
	hud_update_timer.start()

func _on_hud_update_timer_timeout():
	if GameStateManager.game.game_time:
		game_time.text = GameStateManager.game.game_time
	update_markers(GameStateManager.mob_node)
	update_markers(GameStateManager.poi_node)

func _on_full_screen_button_pressed():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _process(_delta):
	pass
	
func _ready():
	if not DisplayServer.is_touchscreen_available():
		full_screen_button.hide()
	emit_signal("hud_ready")
	
# Function to add a marker for an entity
func add_marker(entity):
	var marker_scene = entity.get_meta("radar_marker")
	if marker_scene is PackedScene:
		var marker = marker_scene.instantiate()
		var scale_factor
		if entity.entity_variant == "boss_mob":
			scale_factor = boss_mob_marker_scale
		else:
			scale_factor = entity_marker_scale
		marker.scale *= scale_factor
		markers_node.add_child(marker)
		entity_markers[entity] = marker
	else:
		print("Error: Entity does not have valid radar_marker metadata")

# Function to remove a marker for an entity
func remove_marker(entity):
	markers_node.remove_child(entity_markers[entity])
	entity_markers[entity].queue_free()
	entity_markers.erase(entity)

# Function to update the position of a marker
func update_marker_position(entity, player_position):
	var relative_position = (entity.position - player_position) * RADAR_SCALE
	var marker_position = relative_position + (markers_node.size / 2)
	var marker_half_size = entity_markers[entity].size / 2
	marker_position.x = clamp(marker_position.x, marker_half_size.x, markers_node.size.x - marker_half_size.x)
	marker_position.y = clamp(marker_position.y, marker_half_size.y, markers_node.size.y - marker_half_size.y)
	entity_markers[entity].position = marker_position

# Main function to update markers
func update_markers(entity_node):
	var player_position = GameStateManager.player.position

	for entity in entity_node.get_children():
		if entity.visible and entity not in entity_markers:
			add_marker(entity)

		elif not entity.visible and entity in entity_markers:
			remove_marker(entity)

		if entity.visible and entity in entity_markers:
			update_marker_position(entity, player_position)

func flash_poi_makers():
	pass

func flash_radar():
	animation_player.play("hud_radar_flash")

func replace_equipment(equipment_id: String):
	var equipment_node = equipment_grid.get_node(equipment_id)
	equipment_grid.remove_child(equipment_node)

func set_hp(player_hp):
	hp_bar.value = player_hp
	animation_player.play("hp_flash")
	
func set_xp(player_xp):
	xp_bar.value = player_xp
	animation_player.play("xp_flash")

func set_level(player_level,player_xp,player_max_xp):
	xp_bar.max_value = player_max_xp
	xp_bar_label.text = "LEVEL: " + str(player_level)
	set_xp(player_xp)

func _on_fire_pressed():
	pass # Replace with function body.
