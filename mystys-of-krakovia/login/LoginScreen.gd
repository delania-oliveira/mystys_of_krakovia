extends Control

@onready var username_edit = $VBoxContainer/UsernameEdit
@onready var password_edit = $VBoxContainer/PasswordEdit
@onready var login = $VBoxContainer/HBoxContainer/LoginButton
@onready var exit = $VBoxContainer/HBoxContainer/ExitButton

@onready var wrong_password_dialog = $WrongPassword
@onready var user_not_found_dialog = $UserNotFound
@onready var http_request = $HTTPRequest

const SERVER_URL = "#"
const REGISTER_URL = "#"

func _ready():
	login.pressed.connect(_on_login_button_pressed)
	exit.pressed.connect(_on_exit_button_pressed)
	
	http_request.request_completed.connect(_on_http_request_completed)
	
	user_not_found_dialog.confirmed.connect(_on_create_account_button_pressed)
	
func _on_login_button_pressed():
	var username = username_edit.text
	var password = password_edit.text
	if username.is_empty() or password.is_empty():
		wrong_password_dialog.dialog_text = "Usuário e/ou senha não podem estar vazios"
		wrong_password_dialog.popup_centered()
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

func _on_http_request_completed(result, response_code, headers, body):
	login.disabled = false

	var json = JSON.new()

	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	
	match response_code:
		200: 
			print("Login bem sucedido!")
		401:
			wrong_password_dialog.dialog_text = "Senha incorreta. Tente novamente."
			wrong_password_dialog.popup_centered()
			password_edit.text = ""
			password_edit.grab_focus()
		404:
			user_not_found_dialog.popup_centered()
		_:
			wrong_password_dialog.dialog_text = "Erro de conexão com o servidor."
			wrong_password_dialog.popup_centered()
func _on_create_account_button_pressed():
	OS.shell_open(REGISTER_URL)
	
