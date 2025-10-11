# fireball.gd
extends Node3D

var speed = 20.0
var target
var room
var playerId
var userId
@onready var explosion_scene = preload("res://assets/effects/shoot_effects/Explosion.tscn")

func _physics_process(delta):
	if not is_inside_tree():
		return
	# If the target is gone for any reason, destroy the arrow
	if not is_instance_valid(target):
		queue_free()
		return

	# Keep looking at the target's current position
	look_at(Vector3(target.x, target.y, target.z), Vector3.UP)

	# Calculate direction and move forward
	var direction = -global_transform.basis.z
	global_position += direction * speed * delta

	# Check for impact
	if global_position.distance_to(Vector3(target.x, target.y, target.z)) < 0.5:
		var forward = -global_transform.basis.z.normalized()
		var explosion = load("res://assets/effects/shoot_effects/Explosion.tscn").instantiate()
		get_parent().add_child(explosion)
		explosion.global_position = global_position
		explosion.look_at(explosion.global_position + forward, Vector3.UP)
		get_tree().current_scene.add_child(explosion)
		explosion.emitting = true
		# Send damage signal and destroy the fireball
		if playerId == userId:
			room.send("attackDealDamage", {"targetId": target.monster_id, "skillId": "default_skill_mage", "playerId": playerId})
		queue_free()
