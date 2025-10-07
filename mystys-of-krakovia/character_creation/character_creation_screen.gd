extends Control

@onready var name_input = $NameLineEdit
@onready var class_select = $ClassOptionButton
@onready var preview = $CharacterPreview3D
@onready var create_button = $CreateButton
@onready var alert_panel = $AlertPanel
@onready var http_request = $HTTPRequest
@onready var exit_button = $Exit
@onready var config_menu = $ConfigMenuButton

const SERVER_URL = "http://localhost:2567/api/characters"

func _ready():
	# Populate class dropdown
	class_select.add_item("Warrior")
	class_select.add_item("Mage")
	class_select.add_item("Hunter")
	class_select.add_item("Assassin")
	class_select.add_item("Priest")
	alert_panel.hide()
	class_select.item_selected.connect(_on_class_selected)
	http_request.request_completed.connect(_on_http_request_completed)
	create_button.pressed.connect(_on_create_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	config_menu.pressed.connect(_on_config_menu_pressed)
	class_select.select(0)
	_on_class_selected(0)
	
func _on_create_pressed():
	var char_name = name_input.text.strip_edges()
	var char_class = ""
	var selected_indices = class_select.get_selected_items()
	for index in selected_indices:
		char_class = class_select.get_item_text(index)
	if char_class == "":
		alert_panel.dialog_text = "Selecione um personagem!"
		alert_panel.popup_centered()
		return
	if char_name == "":
		alert_panel.dialog_text = "Nome não pode ficar em branco"
		alert_panel.popup_centered()
		return
	# Store the character data (for now just print, but you might save to global or send to server)
	var body = JSON.stringify({
		"name": char_name,
		"character_class": char_class
	})
	var token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2NvdW50X2lkIjoiMzEzOGVkYWItYzViMC00OGYzLWExZjgtZWIzZjM4MWZiZjFkIiwiaWF0IjoxNzU5NjgxNzk5LCJleHAiOjE3NjIyNzM3OTl9.VOXIGd28FSBkJtx4s1av0NiwIu1idElgBYzFj9xT1WY"
	var headers = ["Content-Type: application/json", "Authorization: Bearer " + token]
	http_request.request(SERVER_URL, headers, HTTPClient.METHOD_POST, body)
	
func _on_class_selected(index: int) -> void:
	var class_selected = class_select.get_item_text(index)
	clear_preview()
	prepare_preview(class_selected)

func _on_config_menu_pressed() -> void:
	var options_scene = load("res://ui/OptionsMenu.tscn").instantiate()
	add_child(options_scene)
	
func prepare_preview(class_selected) -> void:
	var camera = preview.get_node("Camera3D")
	camera.position = Vector3(0, 2, 5)
	camera.look_at(Vector3.ZERO, Vector3.UP)
	
	var light = preview.get_node("DirectionalLight3D")
	light.rotation_degrees = Vector3(-45, 45, 0)
	
	var char_scene = load("res://assets/character/" + class_selected + ".glb").instantiate()
	char_scene.position = Vector3(0, 0, 0)   # moves model to origin
	char_scene.rotation_degrees = Vector3.ZERO
	char_scene.scale = Vector3.ONE
	preview.add_child(char_scene)
	
	var anim_player = char_scene.get_node("AnimationPlayer")  # adjust path if needed
	if anim_player:
		anim_player.play("Idle")

func clear_preview() -> void:
	for child in preview.get_children():
		if child.name != "Camera3D" and child.name != "DirectionalLight3D":
			child.queue_free()
	
func _on_http_request_completed(result, response_code, headers, body) -> void:
	match response_code:
		201: 
			alert_panel.dialog_text = "Personagem criado com sucesso!"
			alert_panel.popup_centered()
		401:
			alert_panel.dialog_text = "Nome já existe!"
			alert_panel.popup_centered()
		_:
			alert_panel.dialog_text = "Erro de conexão com o servidor."
			alert_panel.popup_centered()

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://character_selection/CharacterSelectionScreen.tscn")


func _on_character_created_success_confirmed() -> void:
	get_tree().change_scene_to_file("res://character_selection/CharacterSelectionScreen.tscn")
