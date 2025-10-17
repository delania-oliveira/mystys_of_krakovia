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
var is_aggressive = false
var loot: Dictionary
var lootPosition
var network_animation
@onready var MOVEMENT_TRESHOLD = 0.1
var BEHOLDER_FIREBALL_SCENE = preload("res://assets/monsters/skills/BeholderFireball.tscn")
var rotation_model = -PI/2
var anim_player
var library
@onready var attack_range = 2.0
@onready var is_attacking = false
@onready var time_since_last_attack = 2.0
func _ready() -> void:
	var path = "Pivot/Sketchfab_Scene/AnimationPlayer"
	if get_node(path):
		anim_player = get_node(path)
	elif get_node("Pivot/AuxScene/AnimationPlayer"):
		path = "Pivot/AuxScene/AnimationPlayer"
		anim_player = get_node(path)
	else:
		anim_player = null
		
	match character_name:
		"Lobo":
			rotation_model = -PI/2
		_:
			rotation_model = PI
	if anim_player:
		library = anim_player.get_animation_library("")
		var runAnim = null
		var atkAnim = null
		var idleAnim = null
		if library.has_animation("01_Run"):
			runAnim = library.get_animation("01_Run")
			idleAnim = library.get_animation("04_Idle")
			atkAnim = library.get_animation("03_creep")
			library.remove_animation("01_Run")
			library.remove_animation("03_creep")
			library.remove_animation("04_Idle")
			library.add_animation("Running", runAnim)
			library.add_animation("Idle", idleAnim)
			library.add_animation("Attack", atkAnim)
		elif library.has_animation("Frames"):
			atkAnim = library.get_animation("Frames")
			library.add_animation("Attack", atkAnim)
			library.add_animation("Idle", atkAnim)
			library.add_animation("Running", atkAnim)
		elif character_name == "Beholder":
			runAnim = library.get_animation("Idle")
			library.add_animation("Attack", runAnim)
			library.add_animation("Running", runAnim)
func _process(delta):
	position = position.lerp(network_position, LERP_SPEED * delta)
	time_since_last_attack += delta
	if position.distance_squared_to(network_position) > 0.1:
		if target_id or is_attacking:
			$Pivot.look_at(network_position, Vector3.UP)
			$Pivot.rotate_y(rotation_model)
		else:
			$Pivot.look_at(spawn_position, Vector3.UP)
			$Pivot.rotate_y(rotation_model)
	if anim_player and anim_player.has_animation(network_animation):
		anim_player.play(network_animation)
	if character_name == "Beholder" and is_attacking and target_id:
		if time_since_last_attack >= 2:
			var target = _get_target_by_id(target_id)
			if target:
				spawn_ranged_skill(target, BEHOLDER_FIREBALL_SCENE)
				time_since_last_attack = 0.0
				
func _get_target_by_id(target_id):
	return room.state.players.at(target_id)
	
func spawn_ranged_skill(target_node, scene):
	var skill = scene.instantiate()
	skill.target = target_node
	var spawn_position = global_position
	get_tree().root.add_child(skill)
	skill.global_position = spawn_position
	
func _on_set_monster_loot(data):
	var current_loot = data.loot
	var loot_scene = load("res://tests/npcs/monsters/Loot.tscn")

	if not loot_scene or not current_loot:
		return

	var loot_instance = loot_scene.instantiate()
	var loot_container = loot_instance.get_node("LootUI/LootContainer")
	var index = 1

	for item in current_loot:
		var item_slot = loot_container.get_node_or_null("Item" + str(index))
		if not item_slot:
			index += 1
			continue
		
		var icon = item_slot.get_node("ItemIcon")
		var quantity_label = item_slot.get_node("ItemQuantity")
		var tex = load("res://assets/icons/items/" + str(item.id) + ".png")
		
		icon.texture = tex
		icon.tooltip_text = item.name
		item_slot.room = room
		item_slot.item_tex = tex
		item_slot.item_id = item.id
		item_slot.item_name = item.name
		item_slot.item_quantity = item.quantity
		
		quantity_label.text = str(item.quantity)

		index += 1

	loot_instance.global_position = Vector3(data.loot_pos_x, data.loot_pos_y, data.loot_pos_z)
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
