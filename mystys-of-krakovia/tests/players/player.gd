extends CharacterBody3D

@onready var anim_player = $Pivot/AuxScene/AnimationPlayer

@export var speed = 14
@export var fall_acceleration = 75
@export var jump_impulse = 20
@export var bounce_impulse = 16
@export var is_local: bool = false
var id
var character_class
var character_name
var dead
var server_authoritative_position
var current_health: int
var max_exp: int
var resisted = false
var max_health: int
var max_mana: int
var current_mana: int
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
var is_attacking = false
@onready var current_experience
@onready var current_level
@onready var health_label = $HealthBar/ProgressHealthBar/HealthLabel
@onready var health_bar = $HealthBar/ProgressHealthBar
@onready var mana_label = $ManaBar/ProgressManaBar/ManaLabel
@onready var mana_bar = $ManaBar/ProgressManaBar
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
@onready var stats_label = get_node("Inventory/PlayerStats")
var floating_popup_scene = preload("res://tests/players/ui/Popup.tscn")
var menu_tab_scene = preload("res://ui/MenuTab.tscn")
var player_alert_scene = preload("res://tests/players/ui/PlayerAlert.tscn")
var party_invite_scene = preload("res://tests/players/ui/PartyInvitePopup.tscn")
var death_screen_scene = preload("res://ui/DeathScreen.tscn")
var party_ui_scene = preload("res://tests/players/ui/PartyUI.tscn")
var current_target_name = ""
var attack_speed = 1.0
var defense = 0
var attack = 0
var partyId
var ARROW_SCENE = preload("res://assets/effects/shoot_effects/Arrow.tscn")
var ARCANEBALL_SCENE = preload("res://assets/effects/shoot_effects/Arcaneball.tscn")
var DESINTEGRATE_SCENE = preload("res://assets/effects/shoot_effects/Desintegrate.tscn")
var FLAME_ARROW_SCENE = preload("res://assets/effects/shoot_effects/FlameArrow.tscn")
var WARCRY_SCENE = preload("res://assets/effects/aoe_effects/Warcry.tscn")
signal skills_updated(new_skills)
var menu_instance = null
@onready var spellbook = $SpellBook
@onready var player_menu = $PlayerMenu
@onready var inventory = $Inventory
var skills: Array = []
var attack_locked = false
var action_slot
var party_ui_instance = null

func _ready() -> void:
	var deathAnim = null
	var shotAnim = null
	var castAnim = null
	var arcaneExplosionAnim = null
	var desintegrateAnim = null
	var library = anim_player.get_animation_library("")
	if library.has_animation("StandingReactDeathBackward"):
		# Mage.glb - Mage model
		deathAnim = library.get_animation("StandingReactDeathBackward")
		castAnim = library.get_animation("Standing1HMagicAttack01")
		arcaneExplosionAnim = library.get_animation("Standing2HMagicAreaAttack02")
		desintegrateAnim = library.get_animation("Standing2HMagicAttack04")
		library.remove_animation("StandingReactDeathBackward")
		library.remove_animation("Standing1HMagicAttack01")
		library.remove_animation("Standing2HMagicAttack04")
	elif library.has_animation("StandingDeathForward02"):
		# Archer.glb - Archer model
		shotAnim = library.get_animation("StandingDrawArrow")
		deathAnim = library.get_animation("StandingDeathForward02")
		library.remove_animation("StandingDeathForward02")
		library.remove_animation("StandingDrawArrow")
	if deathAnim:
		library.add_animation("Death", deathAnim)
		library.add_animation("DefaultAttack", shotAnim)
		library.add_animation("AttackMultiShot", shotAnim)
		library.add_animation("AttackFlameArrow", shotAnim)
		library.add_animation("DefaultCast", castAnim)
		library.add_animation("ArcaneExplosionCast", arcaneExplosionAnim)
		library.add_animation("DesintegrateCast", desintegrateAnim)
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
		var error_distance = global_position.distance_to(server_authoritative_position)
		if error_distance > 0.01:
			global_position = global_position.lerp(server_authoritative_position, LERP_SPEED * delta)
			
		is_standing = velocity.length() < 0.1
		var is_colliding_with_wall = false
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			# If the normal's Y value is low, it's a wall or a very steep slope.
			if collision.get_normal().y < 0.5:
				is_colliding_with_wall = true
				break
		if velocity.length() < 0.1 or is_colliding_with_wall:
			if is_standing:
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
	if data.health and data.health != current_health and data.health < current_health:
		resisted = false
		show_floating_text(current_health - data.health, true, null, "Damage")
		current_health = data.health
		health_label.text = str(current_health) + " / " + str(max_health)
		health_bar.value = current_health
	elif data.max_health and data.max_health != max_health:
		max_health = data.max_health
		health_bar.max_value = data.max_health
		health_label.text = str(current_health) + " / " + str(max_health)
		health_bar.value = max_health
	elif data.health and data.health != current_health and data.health > current_health and (data.health - current_health) > 10:
		show_floating_text(data.health - current_health, true, null, "Healing")
		current_health = data.health
		health_label.text = str(current_health) + " / " + str(max_health)
		health_bar.value = current_health
func update_player_mana(data):
	# UPDATE OWN PLAYER MANA
	if data.mana and data.mana != current_mana:
		current_mana = data.mana
		mana_label.text = str(current_mana) + " / " + str(max_mana)
		mana_bar.value = current_mana
	elif data.max_mana and data.max_mana != max_mana:
		max_mana = data.max_mana
		mana_bar.max_value = data.max_mana
		mana_label.text = str(current_mana) + " / " + str(max_mana)
		mana_bar.value = max_mana
	
func _on_resist_damage(data):
	if !resisted:
		resisted = true
		show_floating_text(0, true, null, "Damage")
	
func _on_experience_gained(data):
	update_player_experience(data)
	
func update_player_experience(data):
	# UPDATE OWN PLAYER EXPERIENCE
	var current_experience = data.currentExperience
	var new_max_exp = data.maxExp
	var gained_experience = data.experience

	experience_bar.max_value = new_max_exp
	experience_bar.value = current_experience
	experience_label.text = str(current_experience) + " / " + str(new_max_exp)
	show_floating_text(gained_experience, true, null, "Experience")
	if data.levelsGained != 0:
		max_exp = data.maxExp
		current_level += data.levelsGained
		current_experience =  data.currentExperience
		level_label.text = "Level: " + str(current_level)
		experience_label.text = str(current_experience) + " / " + str(data.maxExp)
		experience_bar.max_value = data.maxExp
		
func _on_party_member_level_up(data):
	if partyId and party_ui_instance:
			for member in data.membersLeveledUp:
				party_ui_instance._update_member_level(member)
				
func _on_player_attack(data):
	if "skillEffect" in data and data.needTarget and data.targetId:
		var target = get_target_by_id(data.targetId)
		attack_locked = false
		if data.skillEffect == "ArcaneBall":
			spawn_ranged_skill(target, get_user_by_id(data.id), data.id, ARCANEBALL_SCENE)
		elif data.skillEffect == "ArrowShot":
			spawn_ranged_skill(target, get_user_by_id(data.id), data.id, ARROW_SCENE)
		elif data.skillEffect == "ArrowMultiShot":
			spawn_multi_shot(data, target)
		elif data.skillEffect == "FlameArrow":
			spawn_ranged_skill(target, get_user_by_id(data.id), data.id, FLAME_ARROW_SCENE)
		elif data.skillEffect == "Desintegrate":
			spawn_ranged_skill(target, get_user_by_id(data.id), data.id, DESINTEGRATE_SCENE)
		elif data.skillEffect == "DefaultAttackMelee":
			if data.id == id:
				if not is_instance_valid(target):
					return
				room.send("attackDealDamage", {"targetId": target.monster_id, "skillId": data.skillId, "playerId": id})
		elif data.skillEffect == "CleaveAttackMelee":
			if not is_instance_valid(target):
					return
			if data.id == id:
				cleave_warrior(data, target)
	if "skillEffect" in data and !data.needTarget:
		if data.skillEffect == "ArcaneExplosion":
			var ARCANE_EXPLOSION_SCENE = preload("res://assets/effects/aoe_effects/ArcaneExplosion.tscn")
			var explosion = ARCANE_EXPLOSION_SCENE.instantiate()
			var caster = get_user_by_id(data.id)
			explosion.global_transform.origin = Vector3(caster.x, caster.y, caster.z)
			explosion.room = room
			explosion.playerId = id
			get_tree().current_scene.add_child(explosion)
		elif data.skillEffect == "WarcryWarrior":
			var warcry = WARCRY_SCENE.instantiate()
			var caster = get_user_by_id(data.id)
			warcry.global_transform.origin = Vector3(caster.x, caster.y, caster.z)
			get_tree().current_scene.add_child(warcry)
			if data.id == id:
				room.send("playerBuff", {"skillId": data.skillId, "playerId": id})
				
func spawn_multi_shot(data, target):
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
			
func cleave_warrior(data, target):
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
		if body.is_in_group("monsters") and id == data.id:
			room.send("attackDealDamage", {"targetId": body.id, "skillId": data.skillId, "playerId": id})
func update_gold(new_value):
	var gold_diff = new_value - current_gold
	if gold_diff > 0:
		show_floating_text(gold_diff, true, null, "Gold")
	current_gold = new_value
	gold_label.text = "Gold: " + str(current_gold)

func update_defense(new_value):
	if defense != new_value:
		defense = new_value
		stats_label.text = "⚔️ " + str(attack) + "🛡️ " + str(new_value)
func update_attack(new_value):
	if attack != new_value:
		attack = new_value
		stats_label.text = "⚔️ " + str(attack) + "🛡️ " + str(defense)
func _on_looted_item(data):
	inventory.update_inventory(data)
	
func on_network_data_received(data):
	if data.targetName:
		current_target_name = data.targetName
	if is_local:
		server_authoritative_position = Vector3(data.x, data.y, data.z)
	else:
		network_position = Vector3(data.x, data.y, data.z)
		network_direction = Vector3(-data.dirX, 0, -data.dirZ)
	update_player_health(data)
	update_player_mana(data)
	is_attacking = data.isAttacking
	if data.gold != null and data.gold != 0:
		update_gold(data.gold)
	if data.defense != null:
		update_defense(data.defense)
	if data.attack != null:
		update_attack(data.attack)
	if not dead:
		if data.animation:
			if is_local and data.animation.contains("Attack") and data.isAttacking:
				anim_player.connect("animation_finished", Callable(self, "_on_attack_animation_finished"), CONNECT_ONE_SHOT)
				anim_player.play(data.animation, -1.0, attack_speed)
				attack_locked = true
			if is_local and data.animation.contains("Ataque") and data.isAttacking:
				anim_player.connect("animation_finished", Callable(self, "_on_attack_animation_finished"), CONNECT_ONE_SHOT)
				anim_player.play(data.animation, -1.0, attack_speed + 0.5)
				attack_locked = true
			if is_local and data.animation == "Buff":
				anim_player.connect("animation_finished", Callable(self, "_on_attack_animation_finished"), CONNECT_ONE_SHOT)
				anim_player.play(data.animation, -1.0, attack_speed)
				attack_locked = true
			elif not attack_locked:
				if data.animation == "Idle":
					var anim = anim_player.get_animation("Idle")
					anim.loop_mode = Animation.LOOP_LINEAR
				anim_player.play(data.animation)
			if is_local and data.animation.contains("Cast") and "castTime" in data and data.isAttacking == true:
				cast_bar.player = self
				cast_bar.room = room
				cast_bar.visible = true
				if action_slot:
					cast_bar.action_slot = action_slot
				cast_bar.cast_position = global_position
				cast_bar.cast_skill(data.skillId, data.castTime)
				var anim = anim_player.get_animation(data.animation)
				var calculated_speed = (anim.length / data.castTime) - 0.6
				anim_player.play(data.animation, -1.0, calculated_speed)
	if data.isDead and not dead:
		die()
	elif not data.isDead and dead:
		respawn()
		
func _on_attack_animation_finished(anim_name):
	if !is_local:
		return
	if anim_name == ("DefaultAttack"):
		room.send("playerAttack", {
			"skillId": "default_skill_" + character_class.to_lower(),
			"targetId": target_id
		})
	elif anim_name == ("Ataque Leve"):
		room.send("playerAttack", {
			"skillId": "default_skill_" + character_class.to_lower(),
			"targetId": target_id
		})
	elif anim_name == "AttackMultiShot":
		room.send("playerAttack", {
			"skillId": "multi_shot_archer",
			"targetId": target_id
		})
	elif anim_name == "AttackFlameArrow":
		room.send("playerAttack", {
			"skillId": "flame_arrow_archer",
			"targetId": target_id
		})
	elif anim_name == "Ataque Pesado":
		room.send("playerAttack", {
			"skillId": "cleave_attack_warrior",
			"targetId": target_id
		})
	elif anim_name == "Buff":
		room.send("playerAttack", {
			"skillId": "warcry_warrior",
			"targetId": target_id
		})
	attack_locked = false
	
func _process(delta):
	if is_local:
		return
	position = position.lerp(network_position, LERP_SPEED * delta)
	if network_direction.length() > 0.1:
		look_at(global_position + network_direction.normalized(), Vector3.UP)

func respawn():
	if not dead:
		return
	
	dead = false
	anim_player.play("Idle") 
	velocity = Vector3.ZERO
	
	if is_local:
		var death_screen = find_child("DeathScreenUI")
		if is_instance_valid(death_screen):
			death_screen.queue_free()

func die():
	if dead:
		return
	dead = true
	anim_player.play("Death")
	
	if is_local:
		var death_screen = death_screen_scene.instantiate()
		death_screen.name = "DeathScreenUI" 
		death_screen.room = room
		death_screen.player = self
		add_child(death_screen)

		velocity = Vector3.ZERO
		
func show_floating_text(amount: int, tookDamage: bool, target, type: String):
	var popup_instance = floating_popup_scene.instantiate()
	get_tree().root.add_child(popup_instance)
	match type:
		"LevelUp":
			popup_instance.set_color(Color(0.6, 0.2, 1.0))
			popup_instance.set_value(amount, "LevelUp")
		"Experience":
			popup_instance.set_color(Color(0.6, 0.2, 1.0))
			popup_instance.set_value(amount, "Experience")
		"Damage":
			if amount == 0 and resisted:
				popup_instance.set_color(Color(0.0, 0.067, 1.0, 1.0))
				popup_instance.resist()
			else:
				popup_instance.set_color(Color(1, 0, 0))
				popup_instance.set_value(amount, "Damage")
		"Gold":
			popup_instance.set_color(Color(0.95, 1.0, 0.0, 1.0))
			popup_instance.set_value(amount, "Gold")
		"Healing":
			popup_instance.set_color(Color(0.416, 0.748, 0.0, 1.0))
			popup_instance.set_value(amount, "Healing")
	if tookDamage:
		popup_instance.global_position = global_position + Vector3(0, 2.0, 0)
	if target:
		popup_instance.global_position = Vector3(target.x, target.y, target.z) + Vector3(0, 2.0, 0)
		
func show_player_alert(text):
	var alert_instance = player_alert_scene.instantiate()
	get_tree().root.add_child(alert_instance)
	alert_instance.set_value(text)
	
func _on_skill_fail(data):
	if action_slot:
		action_slot._on_cooldown_finished()
	show_player_alert(data.text)

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
	if event and event.is_action("tab_target"):
		var closest_monster = null
		var min_distance = INF

		var all_monsters = get_tree().get_nodes_in_group("monsters")

		for monster in all_monsters:
			if monster:
				var distance = self.global_position.distance_to(monster.global_position)
				if distance < min_distance:
					min_distance = distance
					closest_monster = monster
		
		# If a valid monster was found, set it as the target
		if is_instance_valid(closest_monster):
			set_target(closest_monster)
	if event and event.is_action_pressed("ui_cancel"):
		if not menu_instance:
			menu_instance = menu_tab_scene.instantiate()
			menu_instance.player = self
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
				play_skill(result.collider, null, "default_skill_" + character_class.to_lower(), true)
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
		
func play_skill(target, action_slot, skillId, needTarget):
	if is_attacking or !is_local:
		return
	if needTarget == true and !target:
		return
	elif needTarget == true and target:
		target_id = target.id
	is_attacking = true
	if action_slot:
		self.action_slot = action_slot
	room.send("playerStartedAttack", {"skillId": skillId, "targetId": target_id})
	
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
		room.send("setTarget", {"targetName": new_target.character_name, "targetId": new_target.id})
	else:
		target_picture.texture = null
		target_frame.hide()
		
func _on_set_party_target(data):
	if not is_local:
		return
	target_health_bar.show_percentage = false
	target_name_label.text = data.character_name
	target_health_bar.max_value = data.max_health
	target_health_bar.value = data.current_health
	target_health_label.text = str(data.current_health) + " / " + str(data.max_health)
	target_picture.texture = load("res://icon.svg") as Texture2D
	current_target_name = data.character_name
	target_frame.show()
	
func _on_invite_to_party_button_down() -> void:
	room.send("partyInvite", {"playerInvitingId": id, "invitedPlayerId": current_target.id})
	player_menu.hide()

func _on_cancel_button_down() -> void:
	player_menu.hide()
