extends Node3D
@onready var mesh = $MeshInstance3D
@onready var trail = $MeshInstance3D/GPUTrail3D
var target
var speed = 20.0
var room
var playerId
var userId
var targetId
var player
func _process(delta):
	if not is_instance_valid(target):
		queue_free()
		return
	if is_instance_valid(player):
		look_at(Vector3(player.global_position + Vector3(0, 1.5, 0)), Vector3.UP)
	mesh.rotation = Vector3(deg_to_rad(-90), deg_to_rad(0) , deg_to_rad(0))
	var direction = -global_transform.basis.z
	global_position += direction * speed * delta
	if is_instance_valid(player):
		if global_position.distance_to(player.global_position) < 1.5:
			if playerId == userId:
				if "monster_id" in target:
					room.send("attackDealDamage", {"targetId": target.monster_id, "skillId": "drain_life_blood_mage", "playerId": playerId})
			queue_free()
