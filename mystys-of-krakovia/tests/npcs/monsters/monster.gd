extends CharacterBody3D  # or Node3D if no physics needed
var monster_id
@export var speed = 5.0
@export var detection_range = 10.0
@export var attack_range = 2.0
@export var attack_cooldown = 1.0

var target_velocity = Vector3.ZERO
var network_position = Vector3.ZERO
var network_direction = Vector3.ZERO
var network_animation = "Idle"
const LERP_SPEED = 10.0

var target_player: Node3D = null
var attack_timer = 0.0
var room

func _physics_process(delta):
	attack_timer -= delta

	# Find the closest player
	var closest_dist = detection_range
	target_player = null
	for player in get_tree().get_nodes_in_group("players"): # make players part of "players" group
		var dist = global_position.distance_to(player.global_position)
		if dist < closest_dist:
			closest_dist = dist
			target_player = player

	if target_player:
		move_toward_player(delta)

func move_toward_player(delta):
	var dir = (target_player.global_position - global_position).normalized()
	var distance_to_player = global_position.distance_to(target_player.global_position)
	var move_direction = Vector3.ZERO
	if distance_to_player > attack_range:
		var dir_normalized = dir.normalized()
		move_direction = dir_normalized
		
	velocity = move_direction * speed
	move_and_slide()
	room.send("moveMonster", { "x": move_direction.x, "y": 0, "z": move_direction.z, "monster_id": monster_id })
