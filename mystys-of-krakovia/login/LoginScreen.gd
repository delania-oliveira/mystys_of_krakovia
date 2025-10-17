extends Control

@onready var username_edit = $LayoutLogin/LoginCard/VBoxContainer/UserGroup/UsernameEdit
@onready var password_edit = $LayoutLogin/LoginCard/VBoxContainer/PassGroup/PasswordEdit
@onready var login = $LayoutLogin/LoginCard/VBoxContainer/ButtonsGroup/LoginButton
@onready var new_account = $LayoutLogin/LoginCard/VBoxContainer/ButtonsGroup/NewAccountButton
@onready var exit = $ExitButton

@onready var warning_dialog = $WarningDialog
@onready var http_request = $HTTPRequest

const SERVER_URL = "http://week-characterized.gl.at.ply.gg:29821/api/login"
const REGISTER_URL = "https://www.playmystysofkrakovia.com.br/register"

func _ready():
	login.pressed.connect(_on_login_button_pressed)
	new_account.pressed.connect(_on_create_account_button_pressed)
	exit.pressed.connect(_on_exit_button_pressed)
	
	http_request.request_completed.connect(_on_http_request_completed)
	
	_setup_dialog_layout(warning_dialog)
	
func _on_login_button_pressed():
	var username = username_edit.text
	var password = password_edit.text
	if username.is_empty() or password.is_empty():
		warning_dialog.dialog_text = "Usuário e/ou senha não podem estar vazios"
		warning_dialog.popup_centered()
		return
	
	login.disabled = true
	
	var body = JSON.stringify({
		"username": username,
		"password": password
	})
	var headers = ["Content-Type: application/json"]
	
	http_request.request(SERVER_URL, headers, HTTPClient.METHOD_POST, body)
	
func _on_exit_button_pressed():
	get_tree().quit()

func _on_create_account_button_pressed():
	OS.shell_open(REGISTER_URL)

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
	
func _on_http_request_completed(result, response_code, headers, body):
	login.disabled = false

	var json = JSON.new()

	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	
	match response_code:
		200: 
			Globals.token = response.token
			get_tree().change_scene_to_file("res://character_selection/CharacterSelectionScreen.tscn")
		401:
			warning_dialog.dialog_text = "Senha incorreta. Tente novamente."
			warning_dialog.popup_centered()
			password_edit.text = ""
			password_edit.grab_focus()
		404:
			warning_dialog.dialog_text = "Usuário não encontrado. Digite um nome de usuário válido ou crie uma nova conta."
			warning_dialog.popup_centered()
		_:
			warning_dialog.dialog_text = "Erro de conexão com o servidor."
			warning_dialog.popup_centered()
