extends Control

const CONFIG_PATH = "user://settings.cfg"

@onready var return_button =$CenterContainer/PanelContainer/MarginContainer/Layout/ButtonsSection/ReturnButton
@onready var save_button = $CenterContainer/PanelContainer/MarginContainer/Layout/ButtonsSection/SaveButton
@onready var resolution_select = $CenterContainer/PanelContainer/MarginContainer/Layout/HBoxContainer/GraphicsSection/GridContainer/SelectResolution
@onready var mode_select = $CenterContainer/PanelContainer/MarginContainer/Layout/HBoxContainer/GraphicsSection/GridContainer/SelectWindow
@onready var master_slider = $CenterContainer/PanelContainer/MarginContainer/Layout/HBoxContainer/VolumeSection/VBoxContainer/MasterVolumeSlider
@onready var sfx_slider = $CenterContainer/PanelContainer/MarginContainer/Layout/HBoxContainer/VolumeSection/VBoxContainer2/SoundEffectsVolumeSlider
@onready var ambient_slider = $CenterContainer/PanelContainer/MarginContainer/Layout/HBoxContainer/VolumeSection/VBoxContainer3/AmbientVolumeSlider


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
	
	mode_select.add_item("Janela")
	mode_select.set_item_metadata(0, DisplayServer.WINDOW_MODE_WINDOWED)
	mode_select.add_item("Janela em Tela Cheia")
	mode_select.set_item_metadata(1, DisplayServer.WINDOW_MODE_FULLSCREEN)
	mode_select.add_item("Tela Cheia Exclusiva")
	mode_select.set_item_metadata(2, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	mode_select.item_selected.connect(_on_mode_selected)
	
	var popup_menu = mode_select.get_popup()
	popup_menu.add_theme_icon_override("checked", Texture2D.new())
	popup_menu.add_theme_constant_override("h_separation", 0)
	popup_menu.add_theme_constant_override("item_h_separation", 0)
	
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
	closed.emit()
	queue_free()
	
func load_settings():
	var config = ConfigFile.new()
	if config.load(CONFIG_PATH) == OK:
		master_slider.value  = config.get_value("audio", "master", master_slider.value)
		sfx_slider.value     = config.get_value("audio", "sfx", sfx_slider.value)
		resolution_select.select(config.get_value("graphics", "resolution", 0))
		ambient_slider.value = config.get_value("audio", "ambient", ambient_slider.value)
		
		var mode = config.get_value("graphics", "mode", DisplayServer.WINDOW_MODE_WINDOWED)
		for i in mode_select.item_count:
			if mode_select.get_item_metadata(i) == mode:
				mode_select.select(i)
				break
		
func _on_resolution_selected(idx: int):
	var res = resolution_select.get_item_metadata(idx)
	DisplayServer.window_set_size(res)
	
func _on_mode_selected(idx: int):
	var mode = mode_select.get_item_metadata(idx)
	DisplayServer.window_set_mode(mode)
