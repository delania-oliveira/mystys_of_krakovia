extends Button

@onready var options_scene = preload("res://ui/OptionsMenu.tscn")

func _on_button_down() -> void:
	var options_menu = options_scene.instantiate()
	options_menu.get_child(1).hide()
	var background = ColorRect.new()

	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0.322, 0.322, 0.322, 0.95)
	background.name = "OptionsMenuBackground"

	background.add_child(options_menu)
	options_menu.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	get_tree().root.add_child(background)
	
	if is_instance_valid(options_menu):
		options_menu.closed.connect(background.queue_free)
