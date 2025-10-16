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
@onready var anim_player = get_node("Pivot/" + character_name + "/AnimationPlayer")
var rotation_model
func _ready() -> void:
	if anim_player:
		var library = anim_player.get_animation_library("")
		var runAnim = null
		var atkAnim = null
		var idleAnim = null
		if library.has_animation("01_Run"):
			rotation_model = -PI/2
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
			rotation_model = PI
			atkAnim = library.get_animation("Frames")
			library.add_animation("Attack", atkAnim)
			library.add_animation("Idle", atkAnim)
			library.add_animation("Running", atkAnim)
func _process(delta):
	position = position.lerp(network_position, LERP_SPEED * delta)
	if position.distance_squared_to(network_position) > 0.1:
		if target_id:
			$Pivot.look_at(network_position, Vector3.UP)
			$Pivot.rotate_y(rotation_model)
		else:
			$Pivot.look_at(spawn_position, Vector3.UP)
			$Pivot.rotate_y(rotation_model)
	if anim_player:
		anim_player.play(network_animation)
			
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
