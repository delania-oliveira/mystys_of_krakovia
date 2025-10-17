extends Node3D
@onready var mesh = $MeshInstance3D
@onready var trail = $MeshInstance3D/GPUTrail3D
var target
var speed = 35.0
var room
var playerId
var userId
var targetId
func _process(delta):
	if not is_instance_valid(target):
		queue_free()
		return
	look_at(Vector3(target.x, target.y, target.z), Vector3.UP)
	mesh.rotation = Vector3(deg_to_rad(-90), deg_to_rad(0) , deg_to_rad(0))
	var direction = -global_transform.basis.z
	global_position += direction * speed * delta
	if global_position.distance_to(Vector3(target.x, target.y, target.z)) < 0.5:
		if playerId == userId:
			if "monster_id" in target:
				room.send("attackDealDamage", {"targetId": target.monster_id, "skillId": "default_skill_blood_mage", "playerId": playerId})
			else:
				room.send("healTarget", {"targetId": targetId, "skillId": "default_skill_blood_mage", "playerId": playerId})
		queue_free()
