extends Control

@onready var name_input = $NameLineEdit
@onready var class_select = $ClassOptionButton
@onready var preview = $CharacterPreview3D
@onready var create_button = $CreateButton
@onready var error_panel = $BlankNameError
@onready var success_panel = $CharacterCreatedSuccess
@onready var http_request = $HTTPRequest
@onready var exit_button = $Exit

const SERVER_URL = "http://week-characterized.gl.at.ply.gg:29821/api/characters"

func _ready():
	# Populate class dropdown
	class_select.add_item("Warrior")
	class_select.add_item("Mage")
	class_select.add_item("Hunter")
	class_select.add_item("Assassin")
	class_select.add_item("Priest")
	error_panel.hide()
	success_panel.hide()
	class_select.item_selected.connect(_on_class_selected)
	http_request.request_completed.connect(_on_http_request_completed)
	create_button.pressed.connect(_on_create_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	class_select.select(0)
	_on_class_selected()
	
func _on_create_pressed():
	var char_name = name_input.text.strip_edges()
	var char_class = ""
	var selected_indices = class_select.get_selected_items()
	for index in selected_indices:
		char_class = class_select.get_item_text(index)
	if char_class == "":
		error_panel.dialog_text = "Selecione um personagem!"
		error_panel.popup_centered()
		return
	if char_name == "":
		error_panel.dialog_text = "Nome não pode ficar em branco"
		error_panel.popup_centered()
		return
	# Store the character data (for now just print, but you might save to global or send to server)
	var body = JSON.stringify({
		"name": char_name,
		"character_class": char_class
	})
	var token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2NvdW50X2lkIjoiMjhkY2VjM2QtNTg3Yy00YjYyLTk2NGYtNWQ1ZjQ1MjVhZmRkIiwiaWF0IjoxNzU5MTU1MDA4LCJleHAiOjE3NjE3NDcwMDh9.q_ToUCisL8InxF58BTdVMCmu-edNfDQnBxuxJYiZKps"
	var headers = ["Content-Type: application/json", "Authorization: Bearer " + token]
	http_request.request(SERVER_URL, headers, HTTPClient.METHOD_POST, body)
	
func _on_class_selected():
	clear_preview()
	prepare_preview()
	
func prepare_preview():
	var camera = preview.get_node("Camera3D")
	camera.position = Vector3(0, 2, 5)
	camera.look_at(Vector3.ZERO, Vector3.UP)
	
	var light = preview.get_node("DirectionalLight3D")
	light.rotation_degrees = Vector3(-45, 45, 0)
	
	var char_scene = preload("res://assets/character/cac-1758665492797.gltf").instantiate()
	char_scene.position = Vector3(0, 0, 0)   # moves model to origin
	char_scene.rotation_degrees = Vector3.ZERO
	char_scene.scale = Vector3.ONE
	preview.add_child(char_scene)
	
	var anim_player = char_scene.get_node("AnimationPlayer")  # adjust path if needed
	if anim_player:
		anim_player.play("Idle")

func clear_preview():
	for child in preview.get_children():
		if child.name != "Camera3D" and child.name != "DirectionalLight3D":
			child.queue_free()
	
func _on_http_request_completed(result, response_code, headers, body):
	match response_code:
		201: 
			success_panel.dialog_text = "Personagem criado com sucesso!"
			success_panel.popup_centered()
		401:
			error_panel.dialog_text = "Nome já existe!"
			error_panel.popup_centered()
		_:
			error_panel.dialog_text = "Erro de conexão com o servidor."
			error_panel.popup_centered()

func _on_exit_pressed():
	get_tree().change_scene_to_file("res://character_selection/CharacterSelectionScreen.tscn")


func _on_character_created_success_confirmed() -> void:
	get_tree().change_scene_to_file("res://character_selection/CharacterSelectionScreen.tscn")
