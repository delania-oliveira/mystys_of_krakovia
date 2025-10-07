extends Node3D

var id
var speed = 0.0
var is_targeting = false
var spawn_position = Vector3.ZERO
var room
var model
var current_health = 0.0
var max_health = 0.0
var character_name = ""
var target_position = Vector3.ZERO
var LERP_SPEED = 10.0
var network_position = Vector3.ZERO

func _process(delta):
	position = position.lerp(network_position, LERP_SPEED * delta)
	
func _on_attack_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"):
		var player_session_id = body.id # Assuming your player node has its session_id
		room.send("moveMonster", {
			"monsterId": id,
			"targetId": player_session_id,
			"isTargeting": true
		})


func _on_aggro_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("players"):
		room.send("moveMonster", {
			"monsterId": id,
			"targetId": "",
			"isTargeting": false
		})
