extends CharacterBody3D

@onready var anim_player = $Pivot/AuxScene/AnimationPlayer

@export var speed = 14
@export var fall_acceleration = 75
@export var jump_impulse = 20
@export var bounce_impulse = 16
@export var is_local: bool = false
var current_health: int
var max_health: int
var current_target: Node3D = null
var target_velocity = Vector3.ZERO
var network_position = Vector3.ZERO
var network_direction = Vector3.ZERO
var network_animation = "Idle"
const LERP_SPEED = 10.0
var was_idle
var room
var model: Node3D
var target_model: Node3D
@onready var health_label = $HealthBar/ProgressHealthBar/HealthLabel
@onready var health_bar = $HealthBar/ProgressHealthBar
@onready var target_picture = $Target/HBoxContainer/TextureRect
@onready var target_health_bar = $Target/HBoxContainer/VBoxContainer/HealthBar
@onready var target_health_label = $Target/HBoxContainer/VBoxContainer/HealthBar/HealthLabel
@onready var target_name_label = $Target/HBoxContainer/VBoxContainer/NameLabel
@onready var target_frame = $Target
@onready var target_id
var floating_damage_scene = preload("res://tests/players/DamagePopup.tscn")
var character_class
var is_attacking = false
var dead: bool = false
var id
var character_name = ""
var current_target_name = ""
var attack_speed = 1.0
var defense = 0
var ARROW_SCENE = preload("res://assets/effects/shoot_effects/Arrow.tscn")
var FIREBALL_SCENE = preload("res://assets/effects/shoot_effects/Fireball.tscn")

func _ready() -> void:
	var deathAnim = null
	var attackAnim = null
	var library = anim_player.get_animation_library("")
	if library.has_animation("StandingReactDeathBackward"):
		deathAnim = library.get_animation("StandingReactDeathBackward")
		attackAnim = library.get_animation("Standing1HMagicAttack01")
		library.remove_animation("StandingReactDeathBackward")
		library.remove_animation("Standing1HMagicAttack01")
	elif library.has_animation("StandingDeathForward02"):
		attackAnim = library.get_animation("StandingDrawArrow")
		deathAnim = library.get_animation("StandingDeathForward02")
		library.remove_animation("StandingDeathForward02")
		library.remove_animation("StandingDrawArrow")
	if deathAnim:
		library.add_animation("Death", deathAnim)
		library.add_animation("AutoAttack", attackAnim)
	else:
		push_warning("No death animation found to rename.")

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
		if velocity.length() == 0:
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
			target_velocity.y = jump_impulse
			room.send("jumpPlayer")
			
func get_target_by_id(target_id):
	return room.state.monsters.at(target_id)
	
func get_user_by_id(user_id):
	return room.state.players.at(user_id)
	
func _on_player_attack(data):
	if "skillEffect" in data:
		if data.skillEffect == "Fireball":
			spawn_fireball(get_target_by_id(data.targetId), get_user_by_id(data.id))
		else:
			spawn_arrow(get_target_by_id(data.targetId), get_user_by_id(data.id))
		
func _on_target_health_update(data):
	# First, check if we even have a target
	if not current_target:
		return

	# Now, check if the player who took damage (data.targetId) is our current target
	if data.targetId == current_target.id and data.health and data.health != 0 and data.id == id:
		# If it is, update OUR target frame UI
		target_health_bar.value = data.health
		target_health_label.text = str(data.health) + " / " + str(current_target.max_health)
		if data.damage and data.damage != 0:
			show_floating_damage(data.damage, false)
		# Optional: If the target is dead, clear the target
		if data.isDead:
			set_target(null)
	
func update_player_health(data):
	# This part updates this player's own health bar
	if data.health and data.health != current_health:
		show_floating_damage(current_health - data.health, true)
		current_health = data.health
		health_label.text = str(current_health) + " / " + str(max_health)
		health_bar.value = current_health
		
func on_network_data_received(data):
	if data.targetName:
		current_target_name = data.targetName
	network_position = Vector3(data.x, data.y, data.z)
	network_direction = Vector3(-data.dirX, 0, -data.dirZ)
	update_player_health(data)
	if "isAttacking" in data:
		is_attacking = data.isAttacking
	if not dead and data.animation:
		anim_player.play(data.animation)
	if data.isDead || data.health <= 0 || current_health <= 0:
		die()
		
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
	
func show_floating_damage(amount: int, tookDamage: bool):
	var damage_instance = floating_damage_scene.instantiate()
	get_tree().root.add_child(damage_instance)
	if tookDamage:
		damage_instance.global_position = global_position + Vector3(0, 2.0, 0)
	else:
		damage_instance.global_position = current_target.global_position + Vector3(0, 2.0, 0)
	damage_instance.set_damage(amount)
	
func _unhandled_input(event):
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
				play_auto_attack(result.collider)
				if current_target != result.collider:
					set_target(result.collider)
				
func play_auto_attack(target):
	if is_attacking or !is_local:
		return
	target_id = target.id
	room.send("playerAttack", {"skillId": "auto_attack_" + character_class.to_lower(), "targetId": target_id})
	
func spawn_fireball(target_node, user):
	var fireball = FIREBALL_SCENE.instantiate()
	fireball.target = target_node
	var spawn_position = Vector3(user.x, user.y, user.z) + Vector3(0.5, 0.5, 0.5)
	get_tree().root.add_child(fireball)
	fireball.global_position = spawn_position
	fireball.room = room
	var target_position = Vector3(target_node.x, target_node.y, target_node.z)
	fireball.look_at(target_position)
	
func spawn_arrow(target_node, user):
	var arrow = ARROW_SCENE.instantiate()
	arrow.target = target_node
	arrow.room = room
	get_tree().root.add_child(arrow)
	var spawn_position = Vector3(user.x, user.y, user.z) + Vector3.UP
	arrow.global_transform = global_transform
	arrow.global_position = spawn_position
	
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
