extends Button

@onready var options_scene = preload("res://ui/OptionsMenu.tscn")

func _on_button_down() -> void:
	var options_menu = options_scene.instantiate()
	options_menu.get_child(1).hide()
	var background = ColorRect.new()

	# This will make the background cover the entire game window.
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0.322, 0.322, 0.322, 0.95) # Made it slightly transparent
	background.name = "OptionsMenuBackground"

	# Add the menu to the background first.
	background.add_child(options_menu)
	# Now anchor the menu to the center of the background.
	options_menu.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	# CRITICAL FIX: Add the background to the scene root, not the button.
	get_tree().root.add_child(background)
	
	# Connect the signal to free the entire background (and its child menu).
	if is_instance_valid(options_menu):
		options_menu.closed.connect(background.queue_free)
