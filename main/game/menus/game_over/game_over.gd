extends CanvasLayer

@onready var animation_player = $AnimationPlayer

func _ready():
	hide()
	
func _input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		GameStateManager.change_scene("main_menu_scene")
		
func show_screen():
	show()
	animation_player.play("game_over")
	GameStateManager.game.set_music_volume("game_over")
	GameStateManager.pause()

func _on_button_pressed():
	GameStateManager.restart()
