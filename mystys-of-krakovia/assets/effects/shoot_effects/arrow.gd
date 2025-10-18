# arrow.gd
extends Node3D
var player
var target
var speed = 25.0
var room
var playerId
var userId
@onready var arrow_mesh = $MeshInstance3D
func _ready() -> void:
	var archer_scene = load("res://assets/character/Archer.glb")
	var archer_instance = archer_scene.instantiate()

	var eyes_mesh = archer_instance.get_node_or_null("Node/Skeleton3D/Erika_Archer_Eyes_Mesh")
	if eyes_mesh and eyes_mesh is MeshInstance3D:
		$MeshInstance3D.mesh = eyes_mesh.mesh
		arrow_mesh.scale = Vector3(2.0, 2.0, 2.0)
	else:
		push_error("Could not find Erika_Archer_Eyes_Mesh in Hunter.glb")
func _process(delta):
	# If the target is gone for any reason, destroy the arrow
	if not is_instance_valid(target):
		queue_free()
		return

	# Look at the target
	look_at(Vector3(target.x, target.y + 1.0, target.z), Vector3.UP)
	
	# Calculate direction and move forward
	var direction = -global_transform.basis.z
	global_position += direction * speed * delta

	# Check if we've reached the target
	if global_position.distance_to(Vector3(target.x, target.y, target.z)) < 2.0:
		# You can add impact effects here (e.g., play an explosion)
		# and notify the server/target that damage was dealt.
		if playerId == userId:
			room.send("attackDealDamage", {"targetId": target.monster_id, "skillId": "default_skill_archer", "playerId": playerId})
		queue_free() # Destroy the arrow
