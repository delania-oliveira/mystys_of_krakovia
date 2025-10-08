# fireball.gd
extends Node3D

var speed = 20.0
var target
@onready var trail_particles = $Trail
var room

func _physics_process(delta):
	# Move the fireball forward based on its own -Z direction
	global_position += -global_transform.basis.z * speed * delta
	
	if global_position.distance_to(Vector3(target.x, target.y, target.z)) < 0.5:
		# You can add impact effects here (e.g., play an explosion)
		# and notify the server/target that damage was dealt.
		room.send("attackDealDamage", {"targetId": target.monster_id, "skillId": "auto_attack_mage"})

		queue_free() # Destroy the arrow
	
