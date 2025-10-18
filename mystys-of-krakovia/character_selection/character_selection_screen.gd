extends Control

const CharacterButtonScene = preload("res://assets/theme/CharacterButton.tscn")
var class_avatars = {
	"Warrior": preload("res://assets/avatars/100x100/warriorAvatar.png"),
	"Mage": preload("res://assets/avatars/100x100/mageAvatar.png"),
	"Assassin": preload("res://assets/avatars/100x100/assassimAvatar.png"),
	"Blood Mage": preload("res://assets/avatars/100x100/bloodmageAvatar.png"),
	"Archer": preload("res://assets/avatars/100x100/archerAvatar.png"),
}

@onready var character_list_container = $MarginContainer/Layout/Panels/LeftPanel/Characteres
@onready var delete_character_request = $DeleteCharacterRequest
@onready var get_character_list_request = $GetCharacterListRequest
@onready var error_dialog = $WarningDialog
@onready var preview = $MarginContainer/Layout/Panels/CenterPanel/CharacterPreview/CharacterPreview3D
@onready var exit_button = $MarginContainer/Layout/Panels/RightPanel/ExitButton
@onready var create_character_button = $MarginContainer/Layout/Panels/RightPanel/CreateCharacterButton
@onready var join_game_button = $MarginContainer/Layout/Panels/CenterPanel/JoinGameButton
@onready var loading_screen = $LoadingScreen
@onready var success_dialog = $SuccessDialog
@onready var delete_character_button = $MarginContainer/Layout/Panels/LeftPanel/DeleteCharacterButton
@onready var confirm_deletion_dialog = $ConfirmDeletionDialog
@onready var confirm_deletion_input = $ConfirmDeletionDialog/ConfirmDeletionInput
@onready var config_menu_button = $MarginContainer/Layout/Panels/RightPanel/ConfigMenuButton

var characters = []
var character_selected = {}
const SERVER_URL = "http://localhost:2567/api/user"
var token = Globals.token
var headers = ["Content-Type: application/json", "Authorization: Bearer " + token]

func _ready():
	loading_screen.show()
	error_dialog.hide()
	success_dialog.hide()
	confirm_deletion_dialog.hide()
	get_character_list_request.request_completed.connect(_on_get_character_list_request_completed)
	get_character_list_request.request(SERVER_URL, headers, HTTPClient.METHOD_GET)
	exit_button.pressed.connect(_on_exit_pressed)
	delete_character_button.pressed.connect(_on_delete_character_pressed)
	create_character_button.pressed.connect(_on_create_character_pressed)
	delete_character_request.request_completed.connect(_on_delete_character_request_completed)
	config_menu_button.pressed.connect(_on_config_menu_pressed)
	join_game_button.pressed.connect(_on_join_game_pressed)
	
	# ConfirmationDialog force config
	var new_panel_style = StyleBoxFlat.new()
	new_panel_style.bg_color = Color("#180000")
	new_panel_style.content_margin_top = 20.0
	new_panel_style.content_margin_bottom = 20.0
	new_panel_style.content_margin_left = 15.0
	new_panel_style.content_margin_right = 15.0
	confirm_deletion_dialog.add_theme_stylebox_override("panel", new_panel_style)
	
	_setup_dialog_layout(error_dialog)
	_setup_dialog_layout(success_dialog)
	
func _on_character_button_selected(data: Dictionary):
	character_selected = data
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
	
	var char_scene = load("res://assets/character/" + character_selected.class.replace(" ", "_") + ".glb").instantiate()
	char_scene.position = Vector3(0, 0, 0)
	if character_selected.class == "Blood Mage":
		char_scene.position = Vector3(0, -1.4, 0)
	char_scene.rotation_degrees = Vector3.ZERO
	char_scene.scale = Vector3.ONE
	preview.add_child(char_scene)
	
	var anim_player = char_scene.get_node("AnimationPlayer") 
	if anim_player:
		var idle_animation = anim_player.get_animation("Idle")
		idle_animation.set_loop_mode(Animation.LOOP_LINEAR)
		anim_player.play("Idle")

func clear_preview() -> void:
	for child in preview.get_children():
		if child.name != "Camera3D" and child.name != "DirectionalLight3D":
			child.queue_free()
			
func _setup_dialog_layout(dialog_node):
	var label = dialog_node.get_label()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	var vbox = label.get_parent()
	
	var top_spacer = Control.new()
	top_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var bottom_spacer = Control.new()
	bottom_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	vbox.add_child(top_spacer)
	vbox.move_child(top_spacer, 0)
	
	vbox.add_child(bottom_spacer)
	
func _on_get_character_list_request_completed(_result, response_code, _headers, body) -> void:
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	
	match response_code:
		200: 
			if response.has("characters") and response.characters.size() > 0:
				characters.clear()
				for child in character_list_container.get_children():
					child.queue_free()
					
				for character_data in response.characters:
					if not class_avatars.has(character_data.class):
						print("AVISO: Avatar não encontrado para a classe: ", character_data.class)
						continue
						
					characters.append(character_data)
					
					var button_instance = CharacterButtonScene.instantiate()
					var avatar_tex = class_avatars[character_data.class]
					
					button_instance.selected.connect(_on_character_button_selected)
					character_list_container.add_child(button_instance)
					button_instance.setup(character_data, avatar_tex)
					
				if characters.size() > 0:
					_on_character_button_selected(characters[0])
			else:
				get_tree().change_scene_to_file("res://character_creation/CharacterCreationScreen.tscn")
			loading_screen.hide()
		_:
			loading_screen.hide()
			error_dialog.dialog_text = "Erro de conexão com o servidor."
			error_dialog.popup_centered()
			
func _on_delete_character_request_completed(result, response_code, headers, body) -> void:
	match response_code:
		204:
			success_dialog.dialog_text = "Personagem removido com sucesso!"
			success_dialog.popup_centered()
		_:
			loading_screen.hide()
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
