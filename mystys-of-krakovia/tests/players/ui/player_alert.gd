extends Control

@onready var label = $Label

var float_speed = 1.5
var lifetime = 1.0
var fade_time = 0.8
var time_passed = 0.0

func _ready():
	label.modulate = Color(1, 0, 0, 1)
	global_position.x += randf_range(-0.2, 0.2)
	global_position.y += randf_range(-0.2, 0.2)
	
func set_value(alert_text):
		label.text = alert_text
		
func _process(delta):
	time_passed += delta

	if time_passed > fade_time:
		var alpha = 1.0 - ((time_passed - fade_time) / (lifetime - fade_time))
		label.modulate.a = clamp(alpha, 0.0, 1.0)
	if time_passed >= lifetime:
		queue_free()
		
func set_color(c: Color) -> void:
	label.modulate = c
	
