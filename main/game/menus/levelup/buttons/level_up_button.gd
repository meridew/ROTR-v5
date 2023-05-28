extends Button

@onready var label_upgrade_type = $MarginContainer/info_container/label_upgrade_type
@onready var equipment_icon = $MarginContainer/TextureRect/equipment_icon

func _ready():
	pass
	
func set_upgrade_type(label_text):
	label_upgrade_type.text = label_text

func set_icon(animation_name):
	equipment_icon.set_deferred("animation",animation_name)
	equipment_icon.play()
