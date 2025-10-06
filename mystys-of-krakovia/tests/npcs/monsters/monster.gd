extends CharacterBody3D  # or Node3D if no physics needed
var monster_id
@export var speed = 0.0
@export var detection_range = 10.0
@export var attack_range = 2.0
@export var attack_cooldown = 2.0
var attack_damage = 0.0
var is_targeting = false
var target_velocity = Vector3.ZERO
const LERP_SPEED = 10.0
var spawn_position = Vector3.ZERO
var target_player: Node3D = null
var attack_timer = 0.0
var room
var was_idle
var max_health = 0.0
var current_health = 0.0
var character_name = ""
var model

func _physics_process(delta):
	attack_timer -= delta

	# Find the closest player
	var closest_dist = detection_range
	target_player = null
	for player in get_tree().get_nodes_in_group("players"):
		if player is CharacterBody3D:
			var dist = global_position.distance_to(player.global_position)
			if dist < closest_dist:
				closest_dist = dist
				target_player = player
	if target_player && !target_player.dead:
		move_toward_player(delta, target_player)
		if global_position.distance_to(target_player.global_position) <= attack_range:
			try_attack_player()
	else:
		return_to_spawn_point()

func try_attack_player():
	if attack_timer <= 0.0:
		if "take_damage" in target_player:
			target_player.take_damage(target_player.player_key, monster_id)
		attack_timer = attack_cooldown
		
func return_to_spawn_point():
	var dist_to_spawn = global_position.distance_to(spawn_position)
	var direction = (spawn_position - global_position).normalized()
	if dist_to_spawn > 0.1:
		velocity = direction * speed
		move_and_slide()
	else:
		velocity = Vector3.ZERO
		global_position = spawn_position
	_send_monster_state(direction, null)
	
	
func move_toward_player(delta, target_player):
	var dir = (target_player.global_position - global_position).normalized()
	var distance_to_player = global_position.distance_to(target_player.global_position)
	var move_direction = Vector3.ZERO
	if distance_to_player > attack_range:
		var dir_normalized = dir.normalized()
		move_direction = dir_normalized
		
	velocity = move_direction * speed
	move_and_slide()
	_send_monster_state(move_direction, target_player)

func _send_monster_state(move_direction: Vector3, target_player):
	var is_idle = move_direction == Vector3.ZERO
	var payload = {
			"x": move_direction.x,
			"y": 0,
			"z": move_direction.z,
			"monster_id": monster_id
	}
	if target_player:
		payload["targetId"] = target_player.player_key
	if is_idle != was_idle:
		room.send("moveMonster", payload)
		was_idle = is_idle
