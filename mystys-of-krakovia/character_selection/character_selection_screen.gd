extends Control

@onready var char_select = $CharacterOptionList
@onready var http_request = $HTTPRequest
@onready var error_dialog = $ErrorDialog
@onready var preview = $CharacterPreview3D
@onready var exit_button = $ExitButton
@onready var create_character_button = $CreateCharacterButton

var characters = []

const SERVER_URL = "http://week-characterized.gl.at.ply.gg:29821/api/user"

func _ready():
	error_dialog.hide()
	http_request.request_completed.connect(_on_http_request_completed)
	char_select.item_selected.connect(_on_class_selected)
	
	var token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2NvdW50X2lkIjoiMjhkY2VjM2QtNTg3Yy00YjYyLTk2NGYtNWQ1ZjQ1MjVhZmRkIiwiaWF0IjoxNzU5MTU1MDA4LCJleHAiOjE3NjE3NDcwMDh9.q_ToUCisL8InxF58BTdVMCmu-edNfDQnBxuxJYiZKps"
	var headers = ["Content-Type: application/json", "Authorization: Bearer " + token]
	http_request.request_completed.connect(_on_http_request_completed)
	http_request.request(SERVER_URL, headers, HTTPClient.METHOD_GET)
	exit_button.pressed.connect(_on_exit_pressed)
	create_character_button.pressed.connect(_on_create_character_pressed)
	
func _on_class_selected(index: int) -> void:
	$Label.text = characters[index].name
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
	var json = JSON.new()
	
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	match response_code:
		200: 
			for character in response.characters:
				char_select.add_item("%s - %s Lv.%d" % 
				[character.name, character.class, character.level])
				characters.append(character)
			char_select.select(0)
			_on_class_selected(0)
		_:
			error_dialog.dialog_text = "Erro de conexão com o servidor."
			error_dialog.popup_centered()

func _on_create_character_pressed():
	if characters.size() >= 5:
		error_dialog.dialog_text = "Você atingiu o número máximo de personagens."
		error_dialog.popup_centered()
		return
	get_tree().change_scene_to_file("res://character_creation/CharacterCreationScreen.tscn")
	
func _on_exit_pressed():
	get_tree().change_scene_to_file("res://login/LoginScreen.tscn")
