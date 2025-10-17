extends Button

@onready var options_scene = preload("res://ui/OptionsMenu.tscn")

func _on_button_down() -> void:
	var options_menu = options_scene.instantiate()
	
	get_tree().root.add_child(options_menu)
