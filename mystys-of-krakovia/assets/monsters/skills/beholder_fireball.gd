# fireball.gd
extends Node3D

var speed = 20.0
var target
var monster

func _physics_process(delta):
	if not is_inside_tree():
		return
	if not is_instance_valid(target):
		queue_free()
		return

	look_at(Vector3(target.x, target.y + 2.0, target.z), Vector3.UP)

	var direction = -global_transform.basis.z
	global_position += direction * speed * delta

	if global_position.distance_to(Vector3(target.x, target.y, target.z)) < 2.5:
		queue_free()
