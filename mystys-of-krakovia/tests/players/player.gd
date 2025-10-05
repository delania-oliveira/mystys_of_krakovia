extends CharacterBody3D

@onready var anim_player = $Pivot/AuxScene/AnimationPlayer

@export var speed = 14
@export var fall_acceleration = 75
@export var jump_impulse = 20
@export var bounce_impulse = 16
@export var is_local: bool = false

var target_velocity = Vector3.ZERO
var network_position = Vector3.ZERO
var network_direction = Vector3.ZERO
var network_animation = "Idle"
const LERP_SPEED = 10.0

var room

func _physics_process(delta):
	var direction = Vector3.ZERO
	if is_local:
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
			anim_player.play("Idle")
		else:
			anim_player.play("Running")
		room.send("movePlayer", { "x": direction.x, "y": 0, "z": direction.z })
		# Jumping.
		if is_on_floor() and Input.is_action_just_pressed("jump"):
			target_velocity.y = jump_impulse
			room.send("jumpPlayer")
		

func on_network_data_received(data):
	if is_local:
		return
	network_position = Vector3(data.x, data.y, data.z)
	network_direction = Vector3(-data.dirX, 0, -data.dirZ)
	$Pivot/AuxScene/AnimationPlayer.play(data.animation)
	
func _process(delta):
	if is_local:
		return
	position = position.lerp(network_position, LERP_SPEED * delta)
	if network_direction.length() > 0.1:
		look_at(global_position + network_direction.normalized(), Vector3.UP)
