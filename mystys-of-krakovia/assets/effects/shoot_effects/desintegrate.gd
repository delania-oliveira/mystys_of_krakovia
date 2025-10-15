extends Node3D

@onready var mesh: MeshInstance3D = $MeshInstance3D
var target
var userId
var playerId
var room
var speed = 5.0
var start_height = 30.0
var target_position: Vector3
var elapsed := 0.0
var lifetime := 0.5
var start_position: Vector3
var SPARKS_SCENE = preload("res://assets/effects/shoot_effects/sparks.tscn")

func _ready():
	if target:
		target_position = Vector3(target.x, target.y, target.z)
		start_position = target_position + Vector3(0, 10, 0)  # 10 units above
		global_position = start_position

func _process(delta):
	if not is_instance_valid(target):
		queue_free()
		return

	elapsed += delta * speed
	var t = clamp(elapsed / lifetime, 0.0, 1.0)

	var height_curve = sin(t * PI) * 2.0
	global_position = start_position.lerp(target_position, t) + Vector3(0, height_curve, 0)

	look_at(target_position, Vector3.UP)
	rotate_z(deg_to_rad(90))
	if t >= 1.0:
		_emit_sparks()
		if playerId == userId:
			room.send("attackDealDamage", {"targetId": target.monster_id, "skillId": "desintegrate_mage", "playerId": playerId})
		queue_free()


func _emit_sparks():
	var sparks = SPARKS_SCENE.instantiate()
	get_tree().current_scene.add_child(sparks)
	sparks.global_position = global_position
	sparks.get_node("GPUParticles3D").emitting = true
	var light = DirectionalLight3D.new()
	light.light_energy = 3
	add_child(light)
	await get_tree().create_timer(1.0).timeout
	if sparks:
		sparks.queue_free()
