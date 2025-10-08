# arrow.gd
extends Node3D

var target
var speed = 25.0
var room
var playerId
var userId
func _ready() -> void:
	var hunter_scene = load("res://assets/character/Hunter.glb")
	var hunter_instance = hunter_scene.instantiate()

	# Find the ErikaArcherEyesMesh inside it
	var eyes_mesh = hunter_instance.get_node_or_null("Node/Skeleton3D/Erika_Archer_Eyes_Mesh")
	if eyes_mesh and eyes_mesh is MeshInstance3D:
		$MeshInstance3D.mesh = eyes_mesh.mesh
	else:
		push_error("Could not find Erika_Archer_Eyes_Mesh in Hunter.glb")
func _process(delta):
	# If the target is gone for any reason, destroy the arrow
	if not is_instance_valid(target):
		queue_free()
		return

	# Look at the target
	look_at(Vector3(target.x, target.y, target.z), Vector3.UP)
	
	# Calculate direction and move forward
	var direction = -global_transform.basis.z
	global_position += direction * speed * delta

	# Check if we've reached the target
	if global_position.distance_to(Vector3(target.x, target.y, target.z)) < 0.5:
		# You can add impact effects here (e.g., play an explosion)
		# and notify the server/target that damage was dealt.
		if playerId == userId:
			room.send("attackDealDamage", {"targetId": target.monster_id, "skillId": "auto_attack_hunter", "playerId": playerId})
		queue_free() # Destroy the arrow
