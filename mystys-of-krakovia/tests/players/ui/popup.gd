extends Node3D

@onready var label = $Label3D

var float_speed = 1.5
var lifetime = 1.0
var fade_time = 0.8
var time_passed = 0.0

func _ready():
	label.modulate = Color(1, 0, 0, 1) # red text
	# Slight random horizontal offset for natural look
	global_position.x += randf_range(-0.2, 0.2)
	global_position.z += randf_range(-0.2, 0.2)

func set_value(amount: int, type):
	if type == "Gold" || type == "Experience":
		label.text = "+" + str(amount)
	elif type == "LevelUp":
		label.text = "Level Up!"
	elif type == "Damage":
		label.text = str(amount)
		
func resist():
	label.text = "Resist"
	
func _process(delta):
	time_passed += delta
	translate(Vector3(0, float_speed * delta, 0))

	# Fade out
	if time_passed > fade_time:
		var alpha = 1.0 - ((time_passed - fade_time) / (lifetime - fade_time))
		label.modulate.a = clamp(alpha, 0.0, 1.0)

	# Remove after lifetime
	if time_passed >= lifetime:
		queue_free()
		
func set_color(c: Color) -> void:
	# For Label3D you can use modulate:
	label.modulate = c
	# If you used a 2D Label instead, you'd do:
	# label3d.set("theme_override_colors/font_color", c)
