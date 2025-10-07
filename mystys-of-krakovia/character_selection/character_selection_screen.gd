extends Control

@onready var char_select = $CharacterSelectList
@onready var delete_character_request = $DeleteCharacterRequest
@onready var get_character_list_request = $GetCharacterListRequest
@onready var error_dialog = $ErrorDialog
@onready var preview = $CharacterPreview3D
@onready var exit_button = $ExitButton
@onready var create_character_button = $CreateCharacterButton
@onready var join_game_button = $JoinGameButton
@onready var loading_screen = $LoadingScreen
@onready var character_name = $Label
@onready var success_dialog = $SuccessDialog
@onready var delete_character_button = $DeleteCharacterButton
@onready var confirm_deletion_dialog = $ConfirmDeletionDialog
@onready var confirm_deletion_input = $ConfirmDeletionDialog/ConfirmDeletionInput
@onready var config_menu_button = $ConfigMenuButton

var characters = []
var character_selected = {}
const SERVER_URL = "http://localhost:2567/api/user"
var token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2NvdW50X2lkIjoiMzEzOGVkYWItYzViMC00OGYzLWExZjgtZWIzZjM4MWZiZjFkIiwiaWF0IjoxNzU5NjgxNzk5LCJleHAiOjE3NjIyNzM3OTl9.VOXIGd28FSBkJtx4s1av0NiwIu1idElgBYzFj9xT1WY"
var headers = ["Content-Type: application/json", "Authorization: Bearer " + token]

func _ready():
	loading_screen.show()
	error_dialog.hide()
	success_dialog.hide()
	confirm_deletion_dialog.hide()
	get_character_list_request.request_completed.connect(_on_get_character_list_request_completed)
	char_select.item_selected.connect(_on_class_selected)
	get_character_list_request.request(SERVER_URL, headers, HTTPClient.METHOD_GET)
	exit_button.pressed.connect(_on_exit_pressed)
	delete_character_button.pressed.connect(_on_delete_character_pressed)
	create_character_button.pressed.connect(_on_create_character_pressed)
	delete_character_request.request_completed.connect(_on_delete_character_request_completed)
	config_menu_button.pressed.connect(_on_config_menu_pressed)
	join_game_button.pressed.connect(_on_join_game_pressed)
	
func _on_class_selected(index: int) -> void:
	if characters.size() > 0:
		character_name.text = characters[index].name
		character_selected = characters[index]
		clear_preview()
		prepare_preview()
		
func _on_config_menu_pressed():
	var options_scene = load("res://ui/OptionsMenu.tscn").instantiate()
	add_child(options_scene)
		
func prepare_preview() -> void:
	var camera = preview.get_node("Camera3D")
	camera.position = Vector3(0, 2, 5)
	camera.look_at(Vector3.ZERO, Vector3.UP)
	
	var light = preview.get_node("DirectionalLight3D")
	light.rotation_degrees = Vector3(-45, 45, 0)
	
	var char_scene = load("res://assets/character/" + character_selected.class + ".glb").instantiate()
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
			
func _on_get_character_list_request_completed(result, response_code, headers, body) -> void:
	var json = JSON.new()
	
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	match response_code:
		200: 
			if response.characters.size() > 0:
				for character in response.characters:
					char_select.add_item("%s - %s Lv.%d" % 
					[character.name, character.class, character.level])
					characters.append(character)
				char_select.select(0)
				_on_class_selected(0)
			else:
				get_tree().change_scene_to_file("res://character_creation/CharacterCreationScreen.tscn")
			loading_screen.hide()
		_:
			error_dialog.dialog_text = "Erro de conexão com o servidor."
			error_dialog.popup_centered()
			
func _on_delete_character_request_completed(result, response_code, headers, body) -> void:
	match response_code:
		204:
			success_dialog.dialog_text = "Personagem removido com sucesso!"
			success_dialog.popup_centered()
		_:
			error_dialog.dialog_text = "Erro de conexão com o servidor."
			error_dialog.popup_centered()
			
func _on_create_character_pressed() -> void:
	if characters.size() >= 5:
		error_dialog.dialog_text = "Você atingiu o número máximo de personagens."
		error_dialog.popup_centered()
		return
	get_tree().change_scene_to_file("res://character_creation/CharacterCreationScreen.tscn")

func _on_delete_character_pressed() -> void:
	if character_selected == {}:
		error_dialog.dialog_text = "Selecione um personagem para remover."
		error_dialog.popup_centered()
		return
	confirm_deletion_input.clear()
	confirm_deletion_dialog.popup_centered()
	
func _on_exit_pressed():
	get_tree().change_scene_to_file("res://login/LoginScreen.tscn")

func _on_join_game_pressed():
	CharacterHelper.character_id = character_selected.id
	get_tree().change_scene_to_file("res://tests/map/TestMap.tscn")
	
func _on_success_dialog_confirmed() -> void:
	get_tree().reload_current_scene()

func _on_confirm_deletion_dialog_confirmed() -> void:
	if (confirm_deletion_input.text.strip_edges() == character_selected.name):
		delete_character_request.request("http://week-characterized.gl.at.ply.gg:29821/api/characters/" 
		+ character_selected.name, 
		headers, 
		HTTPClient.METHOD_DELETE)
	else:
		error_dialog.dialog_text = "Nome do personagem não corresponde!"
		error_dialog.popup_centered()
