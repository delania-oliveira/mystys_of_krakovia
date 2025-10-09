extends Node3D

var id
var speed = 0.0
var spawn_position = Vector3.ZERO
var room
var model
var current_health = 0.0
var max_health = 0.0
var character_name = ""
var target_position = Vector3.ZERO
var LERP_SPEED = 10.0
var network_position = Vector3.ZERO
var defense
var difficulty
@onready var is_targeting = false
@onready var target_id = ""
@export var loot_scene: PackedScene
var is_aggressive = false
func _process(delta):
	position = position.lerp(network_position, LERP_SPEED * delta)

func spawn_loot():
	var loot_scene = load("res://tests/npcs/monsters/Loot.tscn")
	if not loot_scene:
		return
	var loot_instance = loot_scene.instantiate()
	loot_instance.global_position = global_position
	get_tree().current_scene.add_child(loot_instance)
	
func _on_attack_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"):
		if !is_targeting && is_aggressive:
			var player_session_id = body.id
			room.send("moveMonster", {
				"monsterId": id,
				"targetId": player_session_id,
				"isTargeting": true,
				"isAggroed": true
			})
