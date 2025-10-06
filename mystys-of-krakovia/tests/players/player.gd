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

var dead: bool = false
var player_key
var character_name = ""

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
				anim_player.play("Idle")
				room.send("movePlayer", { "x": 0, "y": 0, "z": 0 })
				was_idle = true
		else:
			was_idle = false
			anim_player.play("Running")
			room.send("movePlayer", { "x": direction.x, "y": 0, "z": direction.z })
		# Jumping.
		if is_on_floor() and Input.is_action_just_pressed("jump"):
			target_velocity.y = jump_impulse
			room.send("jumpPlayer")

func on_network_data_received(data):
	if data.health:
		current_health = data.health
		health_label.text = str(current_health) + " / " + str(max_health)
		health_bar.value = current_health
		if current_target && current_target.character_name == data.name:
			target_health_bar.value = data.health
			target_health_label.text = str(data.health) + " / " + str(current_target.max_health)
	if data.isDead and not dead:
		die()
	if is_local:
		return
	network_position = Vector3(data.x, data.y, data.z)
	network_direction = Vector3(-data.dirX, 0, -data.dirZ)
	if not dead:
		anim_player.play(data.animation)
	
func _process(delta):
	if is_local:
		return
	position = position.lerp(network_position, LERP_SPEED * delta)
	if network_direction.length() > 0.1:
		look_at(global_position + network_direction.normalized(), Vector3.UP)

func take_damage(target_key, monster_id):
	room.send("playerTakeDamage", { "targetId": target_key, "monsterId": monster_id })

func die():
	if dead:
		return
	dead = true
	anim_player.play("StandingReactDeathBackward")
	velocity = Vector3.ZERO
	set_physics_process(false)
	
func _unhandled_input(event):
	if !is_local:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var from = get_viewport().get_camera_3d().project_ray_origin(event.position)
		var to = from + get_viewport().get_camera_3d().project_ray_normal(event.position) * 1000
		var space_state = get_world_3d().direct_space_state
		var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
		if result and result.collider.is_in_group("targetable"):
			set_target(result.collider)

func set_target(new_target: Node3D):
	current_target = new_target
	if new_target:
		target_health_bar.show_percentage = false
		target_name_label.text = new_target.character_name
		target_health_bar.max_value = new_target.max_health
		target_health_bar.value = new_target.current_health
		target_health_label.text = str(new_target.current_health) + " / " + str(new_target.max_health)
		target_picture.texture = load("res://icon.svg") as Texture2D
		target_frame.show()
	else:
		target_picture.texture = null
		target_frame.hide()
