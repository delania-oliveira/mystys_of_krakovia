extends Control

const CONFIG_PATH = "user://settings.cfg"

@onready var return_button = $MarginContainer/VBoxContainer/ButtonsSection/ReturnButton
@onready var resolution_select = $MarginContainer/VBoxContainer/GraphicsSection/ResolutionSection/SelectResolution
@onready var master_slider = $MarginContainer/VBoxContainer/VolumeSection/VBoxContainer/MasterVolumeSlider
@onready var save_button = $MarginContainer/VBoxContainer/ButtonsSection/SaveButton
@onready var fullscreen_check = $MarginContainer/VBoxContainer/GraphicsSection/VBoxContainer/ModeSection/Fullscreen
@onready var windowed_check = $MarginContainer/VBoxContainer/GraphicsSection/VBoxContainer/ModeSection/Windowed
@onready var windowed_fullscreen_check = $MarginContainer/VBoxContainer/GraphicsSection/VBoxContainer/ModeSection/WindowedFullscreen
@onready var ambient_slider = $MarginContainer/VBoxContainer/VolumeSection/VBoxContainer3/AmbientVolumeSlider
@onready var sfx_slider = $MarginContainer/VBoxContainer/VolumeSection/VBoxContainer2/SoundEffectsVolumeSlider
func _ready() -> void:
	master_slider.value  = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	ambient_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Ambient")))
	sfx_slider.value     = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))
	return_button.pressed.connect(_on_return_pressed)
	save_button.pressed.connect(_on_save_pressed)
	
	var resolutions = [
		Vector2i(1920, 1080),
		Vector2i(1600, 900),
		Vector2i(1280, 720),
	]
	for i in resolutions.size():
		var res = resolutions[i]
		resolution_select.set_item_metadata(i, res)
	resolution_select.item_selected.connect(_on_resolution_selected)
	load_settings()
	
func _on_save_pressed():
	save_settings()
	queue_free()

func save_settings():
	var config = ConfigFile.new()
	config.set_value("graphics", "resolution", resolution_select.selected)
	config.set_value("graphics", "mode", DisplayServer.window_get_mode())
	config.set_value("audio", "master", master_slider.value)
	config.set_value("audio", "sfx", sfx_slider.value)
	config.set_value("audio", "ambient", ambient_slider.value)
	config.save(CONFIG_PATH)
	
func _on_return_pressed():
	queue_free()
	
func load_settings():
	var config = ConfigFile.new()
	if config.load(CONFIG_PATH) == OK:
		master_slider.value  = config.get_value("audio", "master", master_slider.value)
		sfx_slider.value     = config.get_value("audio", "sfx", sfx_slider.value)
		resolution_select.select(config.get_value("graphics", "resolution", 0))
		ambient_slider.value = config.get_value("audio", "ambient", ambient_slider.value)
		var mode = config.get_value("graphics", "mode", 0)
		if mode == 0:
			windowed_check.button_pressed = true
		elif mode == 4:
			fullscreen_check.button_pressed = true
		elif mode == 3:
			windowed_fullscreen_check.button_pressed = true
		
func _on_resolution_selected(idx: int):
	var res = resolution_select.get_item_metadata(idx)
	DisplayServer.window_set_size(res)
	
func _on_windowed_fullscreen_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

func _on_windowed_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
