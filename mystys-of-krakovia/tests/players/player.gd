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
var id
var character_name = ""
var current_target_name = ""

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

func _on_target_health_update(data):
	# First, check if we even have a target
	if not current_target:
		return

	# Now, check if the player who took damage (data.targetId) is our current target
	if data.targetId == current_target.id:
		# If it is, update OUR target frame UI
		target_health_bar.value = data.health
		target_health_label.text = str(data.health) + " / " + str(current_target.max_health)
		
		# Optional: If the target is dead, clear the target
		if data.isDead:
			set_target(null)
			
func update_player_health(data):
	# This part updates this player's own health bar
	if data.health:
		current_health = data.health
		health_label.text = str(current_health) + " / " + str(max_health)
		health_bar.value = current_health

	# This part handles this player's own death
	if data.isDead:
		die()

		
func on_network_data_received(data):
	if data.targetName:
		current_target_name = data.targetName
	network_position = Vector3(data.x, data.y, data.z)
	network_direction = Vector3(-data.dirX, 0, -data.dirZ)
	update_player_health(data)
	if not dead and data.animation:
		anim_player.play(data.animation)
	if data.isDead:
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
	anim_player.play("StandingReactDeathBackward")
	velocity = Vector3.ZERO
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var from = get_viewport().get_camera_3d().project_ray_origin(event.position)
		var to = from + get_viewport().get_camera_3d().project_ray_normal(event.position) * 1000
		var space_state = get_world_3d().direct_space_state
		var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
		if result and result.collider.is_in_group("targetable"):
			set_target(result.collider)

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
