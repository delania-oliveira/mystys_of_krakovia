extends CharacterBody3D

@onready var anim_player = $Pivot/AuxScene/AnimationPlayer

@export var speed = 14
@export var fall_acceleration = 75
@export var jump_impulse = 20
@export var bounce_impulse = 16
@export var is_local: bool = false
var current_health: int
var max_exp: int
var max_health: int
var current_target: Node3D = null
var target_velocity = Vector3.ZERO
var network_position = Vector3.ZERO
var network_direction = Vector3.ZERO
var network_animation = "Idle"
const LERP_SPEED = 10.0
var was_idle
var current_gold
var room
var model: Node3D
var target_model: Node3D
var is_standing = true
@onready var current_experience
@onready var current_level
@onready var health_label = $HealthBar/ProgressHealthBar/HealthLabel
@onready var health_bar = $HealthBar/ProgressHealthBar
@onready var experience_label = $ExperienceBar/ProgressExperienceBar/ExperienceLabel
@onready var experience_bar = $ExperienceBar/ProgressExperienceBar
@onready var level_label = $ExperienceBar/ProgressExperienceBar/LevelLabel
@onready var target_picture = $Target/HBoxContainer/TextureRect
@onready var target_health_bar = $Target/HBoxContainer/VBoxContainer/HealthBar
@onready var target_health_label = $Target/HBoxContainer/VBoxContainer/HealthBar/HealthLabel
@onready var target_name_label = $Target/HBoxContainer/VBoxContainer/NameLabel
@onready var target_frame = $Target
@onready var target_id
@onready var cast_bar = $CastBar
@onready var gold_label = get_node("Inventory/HBoxContainer/InventoryItems/Gold/TextureRect/GoldAmount")
var floating_popup_scene = preload("res://tests/players/ui/Popup.tscn")
var menu_tab_scene = preload("res://ui/MenuTab.tscn")
var player_alert_scene = preload("res://tests/players/ui/PlayerAlert.tscn")
var party_invite_scene = preload("res://tests/players/ui/PartyInvitePopup.tscn")
var party_ui_scene = preload("res://tests/players/ui/PartyUI.tscn")
var party_ui_instance = null
var character_class
var is_attacking = false
var dead: bool = false
var id
var character_name = ""
var current_target_name = ""
var attack_speed = 1.0
var defense = 0
var partyId
var ARROW_SCENE = preload("res://assets/effects/shoot_effects/Arrow.tscn")
var ARCANEBALL_SCENE = preload("res://assets/effects/shoot_effects/Arcaneball.tscn")

signal skills_updated(new_skills)
var menu_instance = null
@onready var spellbook = $SpellBook
@onready var player_menu = $PlayerMenu
@onready var inventory = $Inventory
var skills: Array = []
var attack_locked = false

func _ready() -> void:
	var deathAnim = null
	var shotAnim = null
	var castAnim = null
	var arcaneExplosionAnim = null
	var multiShotAnim = null
	var library = anim_player.get_animation_library("")
	if library.has_animation("StandingReactDeathBackward"):
		# Mage.glb - Mage model
		deathAnim = library.get_animation("StandingReactDeathBackward")
		castAnim = library.get_animation("Standing1HMagicAttack01")
		arcaneExplosionAnim = library.get_animation("Standing2HMagicAreaAttack02")
		library.remove_animation("StandingReactDeathBackward")
		library.remove_animation("Standing1HMagicAttack01")
	elif library.has_animation("StandingDeathForward02"):
		# Archer.glb - Archer model
		shotAnim = library.get_animation("StandingDrawArrow")
		multiShotAnim = library.get_animation("StandingDrawArrow")
		deathAnim = library.get_animation("StandingDeathForward02")
		library.remove_animation("StandingDeathForward02")
		library.remove_animation("StandingDrawArrow")
	if deathAnim:
		library.add_animation("Death", deathAnim)
		library.add_animation("DefaultAttack", shotAnim)
		library.add_animation("MultiShot", shotAnim)
		library.add_animation("DefaultCast", castAnim)
		library.add_animation("ArcaneExplosionCast", arcaneExplosionAnim)
	else:
		push_warning("No death animation found to rename.")
		
func _on_set_skills(data):
	if !is_local:
		return
	skills = data
	skills_updated.emit(skills)
	
func _physics_process(delta):
	var direction = Vector3.ZERO
	if is_local && !dead:
		if Input.is_action_pressed("move_right"):
			direction.x += 1
		if Input.is_action_pressed("move_left"):
			direction.x -= 1
		if Input.is_action_pressed("move_back"):
			direction.z += 1
		if Input.is_action_pressed("move_forward"):
			direction.z -= 1
		if direction != Vector3.ZERO:
			direction = direction.normalized()
			# Setting the basis property will affect the rotation of the node.
			$Pivot.look_at(global_transform.origin + direction, Vector3.UP)
			$Pivot.rotate_y(PI)
			room.send("lookPlayer", { "dirX": direction.x, "dirY": 0 , "dirZ": direction.z })
		# Ground Velocity
		target_velocity.x = direction.x * speed
		target_velocity.z = direction.z * speed

		# Vertical Velocity
		if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
			target_velocity.y = target_velocity.y - (fall_acceleration * delta)
		# Moving the Character
		velocity = target_velocity
		move_and_slide()
		is_standing = false
		if velocity.length() == 0:
			is_standing = true
			if not was_idle:
				room.send("movePlayer", { "x": 0, "y": 0, "z": 0 })
				was_idle = true
				if !is_attacking and target_velocity.y == 0:
					anim_player.play("Idle")
		else:
			was_idle = false
			room.send("movePlayer", { "x": direction.x, "y": 0, "z": direction.z })
			if !is_attacking and target_velocity.y == 0:
				anim_player.play("Running")
		# Jumping.
		if is_on_floor() and Input.is_action_just_pressed("jump"):
			is_standing = false
			target_velocity.y = jump_impulse
			room.send("jumpPlayer")

func get_target_by_id(target_id):
	if target_id:
		return room.state.monsters.at(target_id)
	
func get_user_by_id(user_id):
	if user_id:
		return room.state.players.at(user_id)
		
func _on_party_health_update(data):
	if is_instance_valid(party_ui_instance):
		party_ui_instance._update_member_health(data)
		
func _on_target_health_update(data):
	if not current_target or not is_instance_valid(current_target):
		return
		
	if data.targetId != current_target.id:
		return
	
	target_health_bar.value = data.health
	target_health_label.text = str(data.health) + " / " + str(current_target.max_health)

	if "isDead" in data && data.isDead:
		set_target(null)
		
func _on_damage_dealt(data):
	var target = get_target_by_id(data.targetId)
	if data.id == id:
		show_floating_text(data.damage, false, target, "Damage")
	
func update_player_health(data):
	# UPDATE OWN PLAYER HEALTH
	if data.health and data.health != current_health:
		show_floating_text(current_health - data.health, true, null, "Damage")
		current_health = data.health
		health_label.text = str(current_health) + " / " + str(max_health)
		health_bar.value = current_health
		
func _on_experience_gained(data):
	if "taggedPlayerId" in data and data.taggedPlayerId == id or ("partyId" in data && data.partyId == partyId):
		update_player_experience(data)
	
func update_player_experience(data):
	# UPDATE OWN PLAYER EXPERIENCE
	if data.experience:
		current_experience = data.currentExperience
		experience_label.text = str(current_experience) + " / " + str(max_exp)
		experience_bar.value = current_experience
		show_floating_text(data.experience, true, null, "Experience")
	if data.levelsGained != 0:
		max_exp = data.maxExp
		current_level += data.levelsGained
		current_experience =  data.currentExperience
		level_label.text = "Level: " + str(current_level)
		experience_label.text = str(current_experience) + " / " + str(data.maxExp)
		experience_bar.max_value = data.maxExp
	
func _on_player_attack(data):
	if "skillEffect" in data and data.needTarget and current_target:
		var target = get_target_by_id(data.targetId)
		if data.skillEffect == "ArcaneBall":
			spawn_ranged_skill(target, get_user_by_id(data.id), data.id, ARCANEBALL_SCENE)
		elif data.skillEffect == "ArrowShot":
			spawn_ranged_skill(target, get_user_by_id(data.id), data.id, ARROW_SCENE)
		elif data.skillEffect == "ArrowMultiShot":
			var radius = data.area
			var area_center = Vector3(target.x, target.y, target.z)

			var space_state = get_world_3d().direct_space_state
			var shape = SphereShape3D.new()
			shape.radius = radius

			var query = PhysicsShapeQueryParameters3D.new()
			query.shape = shape
			query.transform = Transform3D(Basis(), area_center)
			query.collide_with_areas = false
			query.collide_with_bodies = true
			var results = space_state.intersect_shape(query, 32)
			for result in results:
				var body = result.collider
				if body.is_in_group("monsters"):
					spawn_ranged_skill(get_target_by_id(body.id), get_user_by_id(data.id), data.id, ARROW_SCENE)
	if "skillEffect" in data and !data.needTarget:
		if data.skillEffect == "ArcaneExplosion":
			var ARCANE_EXPLOSION_SCENE = preload("res://assets/effects/aoe_effects/ArcaneExplosion.tscn")
			var explosion = ARCANE_EXPLOSION_SCENE.instantiate()
			var caster = get_user_by_id(data.id)
			if !is_local:
				explosion.global_transform.origin = global_position
			else:
				explosion.global_transform.origin = Vector3(caster.x - 2, caster.y - 2, caster.z - 1)
				
			explosion.room = room
			explosion.playerId = id
			get_tree().current_scene.add_child(explosion)
			
func update_gold(new_value):
	var gold_diff = new_value - current_gold
	if gold_diff > 0:
		show_floating_text(gold_diff, true, null, "Gold")
	current_gold = new_value
	gold_label.text = "Gold: " + str(current_gold)
	
func _on_looted_item(data):
	inventory.update_inventory(data)
	
func on_network_data_received(data):
	if data.targetName:
		current_target_name = data.targetName
	network_position = Vector3(data.x, data.y, data.z)
	network_direction = Vector3(-data.dirX, 0, -data.dirZ)
	update_player_health(data)
	is_attacking = data.isAttacking
	if data.gold != null:
		update_gold(data.gold)
	if not dead:
		if data.animation:
			if data.animation.contains("Attack") or data.animation.contains("MultiShot") and data.isAttacking:
				anim_player.connect("animation_finished", Callable(self, "_on_attack_animation_finished"), CONNECT_ONE_SHOT)
				anim_player.play(data.animation, -1.0, attack_speed)
				attack_locked = true
			elif not attack_locked:
				anim_player.play(data.animation)
			if is_local and data.animation.contains("Cast") and "castTime" in data and data.isAttacking == true:
				cast_bar.player = self
				cast_bar.room = room
				cast_bar.visible = true
				cast_bar.cast_position = global_position
				cast_bar.cast_skill(data.skillId, data.castTime)
				var anim = anim_player.get_animation(data.animation)
				var calculated_speed = (anim.length / data.castTime) - 0.6
				anim_player.play(data.animation, -1.0, calculated_speed)
	if data.isDead || data.health <= 0 || current_health <= 0:
		die()
		
func _on_attack_animation_finished(anim_name):
	if anim_name.contains("Attack"):
		room.send("playerAttack", {
			"skillId": "default_skill_" + character_class.to_lower(),
			"targetId": target_id
		})
	elif anim_name == "MultiShot":
		room.send("playerAttack", {
			"skillId": "multi_shot_archer",
			"targetId": target_id
		})
	attack_locked = false
func _process(delta):
	if is_local:
		return
	position = position.lerp(network_position, LERP_SPEED * delta)
	if network_direction.length() > 0.1:
		look_at(global_position + network_direction.normalized(), Vector3.UP)

func die():
	if dead:
		return
	dead = true
	anim_player.play("Death")
	
	velocity = Vector3.ZERO
	
func show_floating_text(amount: int, tookDamage: bool, target, type: String):
	var popup_instance = floating_popup_scene.instantiate()
	get_tree().root.add_child(popup_instance)
	match type:
		"Experience":
			popup_instance.set_color(Color(0.6, 0.2, 1.0))
			popup_instance.set_value(amount, "Experience")
		"Damage":
			popup_instance.set_color(Color(1, 0, 0))
			popup_instance.set_value(amount, "Damage")
		"Gold":
			popup_instance.set_color(Color(0.95, 1.0, 0.0, 1.0))
			popup_instance.set_value(amount, "Gold")
	if tookDamage:
		popup_instance.global_position = global_position + Vector3(0, 2.0, 0)
	if target:
		popup_instance.global_position = Vector3(target.x, target.y, target.z) + Vector3(0, 2.0, 0)
		
func show_player_alert(text):
	var alert_instance = player_alert_scene.instantiate()
	get_tree().root.add_child(alert_instance)
	alert_instance.set_value(text)
	
func _on_too_far_away(data):
	show_player_alert("Inimigo muito distante!")

func _on_invite_fail(data):
	show_player_alert(data.text)

func _on_party_leave(data):
	var member = party_ui_instance.get_node_or_null(str(data.leavingMember))
	if (member):
		member.queue_free()
	
func _on_party_joined(data):
	if is_instance_valid(party_ui_instance):
		party_ui_instance.queue_free()
	partyId = data.leader
	party_ui_instance = party_ui_scene.instantiate()
	party_ui_instance.room = room
	party_ui_instance.local_player_id = id
	party_ui_instance._create_party(data.members, data.leader)
	get_tree().root.add_child(party_ui_instance)
	
func _on_party_invite(data):
	var party_invite_instance = party_invite_scene.instantiate()
	party_invite_instance.get_child(0).text = data.invitingPlayerName + " te convidou para um grupo."
	party_invite_instance.invitingPlayer = data.invitingPlayerId
	party_invite_instance.invitedPlayer = id
	party_invite_instance.room = room
	get_tree().root.add_child(party_invite_instance)
	
func _unhandled_input(event):
	if !is_local:
		return
	if event and event.is_action_pressed("ui_cancel"):
		if not menu_instance:
			menu_instance = menu_tab_scene.instantiate()
			add_child(menu_instance)
		else:
			menu_instance.queue_free()
			menu_instance = null
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var from = get_viewport().get_camera_3d().project_ray_origin(event.position)
		var to = from + get_viewport().get_camera_3d().project_ray_normal(event.position) * 1000
		var space_state = get_world_3d().direct_space_state
		var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
		if result and result.collider.is_in_group("targetable"):
			set_target(result.collider)
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			var from = get_viewport().get_camera_3d().project_ray_origin(event.position)
			var to = from + get_viewport().get_camera_3d().project_ray_normal(event.position) * 1000
			var space_state = get_world_3d().direct_space_state
			var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
			if result and result.collider.is_in_group("monsters"):
				if current_target != result.collider:
					set_target(result.collider)
				play_default_skill(result.collider)
			if result and result.collider.has_method("toggle_loot_ui"):
				var loot = result.collider
				if global_position.distance_to(loot.global_position) <= 5:
					loot.toggle_loot_ui(id)
					get_viewport().set_input_as_handled()
				else:
					show_player_alert("Muito longe!")
			if result and result.collider.is_in_group("players") and result.collider.id != id:
				player_menu.global_position = get_viewport().get_mouse_position()
				player_menu.show()
				if current_target != result.collider:
					set_target(result.collider)
	if event.is_action_pressed("toggle_skill_book"):
		spellbook.visible = not spellbook.visible
	if event.is_action_pressed("toggle_inventory"):
		inventory.visible = not inventory.visible
		
func play_default_skill(target):
	if is_attacking or !is_local or !target:
		return
	target_id = target.id
	is_attacking = true
	room.send("playerStartedAttack", {"skillId": "default_skill_" + character_class.to_lower(), "targetId": target_id})
	
func play_arcane_explosion():
	if is_attacking or !is_local:
		return
	is_attacking = true
	room.send("playerStartedAttack", {"skillId": "arcane_explosion_mage"})
	
func play_multi_shot(target):
	if is_attacking or !is_local or !target:
		return
	target_id = target.id
	is_attacking = true
	room.send("playerStartedAttack", {"skillId": "multi_shot_archer", "targetId": target_id})
	
func spawn_ranged_skill(target_node, user, userId, scene):
	var skill = scene.instantiate()
	skill.target = target_node
	skill.userId = userId
	skill.playerId = id
	var spawn_position = Vector3(user.x, user.y, user.z)
	get_tree().root.add_child(skill)
	skill.global_position = spawn_position
	skill.room = room
	
func set_target(new_target: Node3D):
	if not is_local:
		return
	current_target = new_target
	if new_target:
		target_health_bar.show_percentage = false
		target_name_label.text = new_target.character_name
		target_health_bar.max_value = new_target.max_health
		target_health_bar.value = new_target.current_health
		target_health_label.text = str(new_target.current_health) + " / " + str(new_target.max_health)
		target_picture.texture = load("res://icon.svg") as Texture2D
		current_target_name = new_target.character_name
		target_frame.show()
		room.send("setTarget", {"targetName": new_target.character_name})
	else:
		target_picture.texture = null
		target_frame.hide()

func _on_invite_to_party_button_down() -> void:
	room.send("partyInvite", {"playerInvitingId": id, "invitedPlayerId": current_target.id})
	player_menu.hide()

func _on_cancel_button_down() -> void:
	player_menu.hide()
