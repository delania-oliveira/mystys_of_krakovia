extends Control

@onready var cast_bar = $CastProgressBar
@onready var label = $CastProgressBar/Label
var room
var is_casting = false
var cast_elapsed = 0.0
var cast_duration = 2.0
var player
var cast_position
var label_update_timer := 0.0
var skill_id

func cast_skill(skillId, castDuration):
	skill_id = skillId
	cast_bar.show_percentage = false
	cast_duration = castDuration
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
		label_update_timer += delta
		cast_elapsed += delta
		cast_bar.value = cast_elapsed
		if label_update_timer >= 0.1:
			label_update_timer = 0.0
			label.text = "%0.1f / %0.1f" % [cast_elapsed, cast_duration]
		
			# When bar is full -> cast complete
		if cast_elapsed >= cast_duration:
			finish_cast()

func finish_cast():
	cast_bar.visible = false
	is_casting = false
	room.send("playerAttack", {
		"skillId": skill_id,
		"targetId": player.target_id
	})
	
func cancel_cast():
	is_casting = false
	cast_bar.visible = false
	cast_elapsed = 0.0
