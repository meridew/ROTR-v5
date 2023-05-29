class_name BasePlayer

const player_scene = preload("res://main/game/player/player.tscn")
const player_obelisk_spriteframes = preload("res://assets/spriteframes/players/player_obelisk.tres")
const player_slugger_spriteframes = preload("res://assets/spriteframes/players/player_slugger.tres")

enum PLAYER_ID {
	slugger,
	obelisk,
}

var player: CharacterBody2D

func new_player(player_id: BasePlayer.PLAYER_ID):
	player = player_scene.instantiate()
	player.entity_type = "player"
	player.entity_variant
	player.default_equipment_id
	
	var player_animated_sprite = player.get_node("AnimatedSprite2D")
	var player_animated_sprite_shadow = player.get_node("AnimatedSprite2D").get_node("Shadow")
	
	match player_id:
		BasePlayer.PLAYER_ID.slugger:
			player.entity_variant = BasePlayer.PLAYER_ID.slugger
			player.default_equipment_id = "gauss_canon"
			player.player_max_hp = 100
			player.player_speed = 140
			player.scale = Vector2(3,3)
			player_animated_sprite_shadow.show()
			player_animated_sprite.sprite_frames = player_slugger_spriteframes
			
		BasePlayer.PLAYER_ID.obelisk:
			player.entity_variant = BasePlayer.PLAYER_ID.obelisk
			player.default_equipment_id = "laser"
			player.player_max_hp = 100
			player.player_speed = 140
			player.scale = Vector2(2,2)
			player_animated_sprite_shadow.hide()
			player_animated_sprite.sprite_frames = player_obelisk_spriteframes
	
	return player
