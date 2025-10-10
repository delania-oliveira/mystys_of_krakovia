extends Control

@onready var cast_bar = $CastProgressBar
var room
var is_casting = false
var cast_elapsed = 0.0
var cast_duration = 2.0
var player
var cast_position

func cast_skill(skillId):
	cast_duration = player.attack_speed
	cast_elapsed = 0.0
	is_casting = true
	cast_bar.visible = true
	cast_bar.min_value = 0
	cast_bar.max_value = cast_duration
	cast_bar.value = 0

func _process(delta):
	if player and player.global_position.distance_to(cast_position) > 0.05:
		cancel_cast()
		return
	if is_casting:
		cast_elapsed += delta
		cast_bar.value = cast_elapsed

			# When bar is full -> cast complete
		if cast_elapsed >= cast_duration:
			finish_cast()

func finish_cast():
	cast_bar.visible = false
	is_casting = false
	room.send("playerAttack", {
		"skillId": "auto_attack_" + player.character_class.to_lower(),
		"targetId": player.target_id
	})
	
func cancel_cast():
	is_casting = false
	cast_bar.visible = false
	cast_elapsed = 0.0
