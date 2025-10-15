extends Node3D

@export var duration := 0.5
@onready var mesh: MeshInstance3D = $MeshInstance3D
var playerId
var room

func _ready():
	if not mesh.material_override is ShaderMaterial:
		var shader_material = ShaderMaterial.new()
		shader_material.shader = preload("res://assets/effects/aoe_effects/arcane_explosion.gdshader")
		mesh.material_override = shader_material

	mesh.scale = Vector3.ONE * 1.5
	mesh.material_override.set_shader_parameter("progress", 0.0)
	
	var tween = create_tween()
	
	tween.tween_property(mesh.material_override, "shader_parameter/progress", 1.0, duration)
	
	tween.tween_callback(queue_free)
