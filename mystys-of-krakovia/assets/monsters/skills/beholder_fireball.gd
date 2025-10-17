# fireball.gd
extends Node3D

var speed = 20.0
var target
var monster
@onready var explosion_scene = preload("res://assets/effects/shoot_effects/Explosion.tscn")

func _physics_process(delta):
	if not is_inside_tree():
		return
	if not is_instance_valid(target):
		queue_free()
		return

	look_at(Vector3(target.x, target.y, target.z), Vector3.UP)

	var direction = -global_transform.basis.z
	global_position += direction * speed * delta

	if global_position.distance_to(Vector3(target.x, target.y, target.z)) < 0.5:
		var forward = -global_transform.basis.z.normalized()
		var explosion = load("res://assets/effects/shoot_effects/Explosion.tscn").instantiate()
		get_parent().add_child(explosion)
		explosion.global_position = global_position
		explosion.look_at(explosion.global_position + forward, Vector3.UP)
		get_tree().current_scene.add_child(explosion)
		explosion.emitting = true
		queue_free()
