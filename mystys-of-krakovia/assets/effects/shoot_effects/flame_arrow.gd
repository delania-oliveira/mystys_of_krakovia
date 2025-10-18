# arrow.gd
extends Node3D

var target
var speed = 25.0
var room
var playerId
var userId
var player
func _ready() -> void:
	var archer_scene = load("res://assets/character/Archer.glb")
	var archer_instance = archer_scene.instantiate()

	var eyes_mesh = archer_instance.get_node_or_null("Node/Skeleton3D/Erika_Archer_Eyes_Mesh")
	if eyes_mesh and eyes_mesh is MeshInstance3D:
		$MeshInstance3D.mesh = eyes_mesh.mesh
		var gradient := Gradient.new()
		gradient.add_point(0.0, Color(1, 0, 0)) # Red
		gradient.add_point(1.0, Color(1, 1, 0)) # Yellow

		var gradient_texture := GradientTexture2D.new()
		gradient_texture.gradient = gradient

		var mat := StandardMaterial3D.new()
		mat.albedo_texture = gradient_texture

		$MeshInstance3D.set_surface_override_material(0, mat)
	else:
		push_error("Could not find Erika_Archer_Eyes_Mesh in Hunter.glb")
func _process(delta):
	if not is_instance_valid(target):
		queue_free()
		return

	look_at(Vector3(target.x, target.y, target.z), Vector3.UP)
	
	var direction = -global_transform.basis.z
	global_position += direction * speed * delta

	if global_position.distance_to(Vector3(target.x, target.y, target.z)) < 0.5:
		if playerId == userId:
			room.send("attackDealDamage", {"targetId": target.monster_id, "skillId": "flame_arrow_archer", "playerId": playerId})
		queue_free()
