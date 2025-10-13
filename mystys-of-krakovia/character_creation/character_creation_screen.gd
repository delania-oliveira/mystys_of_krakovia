extends Control

#panel class
@onready var warrior_button = $MarginContainer/LayoutCreation/Panels/ClassContainer/Classes/GridContainer/WarriorButton
@onready var assassin_button = $MarginContainer/LayoutCreation/Panels/ClassContainer/Classes/GridContainer/AssassinButton
@onready var archer_button = $MarginContainer/LayoutCreation/Panels/ClassContainer/Classes/GridContainer/ArcherButton
@onready var bloodmage_button = $MarginContainer/LayoutCreation/Panels/ClassContainer/Classes/BloodMageButton
@onready var mage_button = $MarginContainer/LayoutCreation/Panels/ClassContainer/Classes/GridContainer/MageButton

#panel char
@onready var preview = $MarginContainer/LayoutCreation/Panels/CharacterContainer/CharacterPreview/CharacterPreview3D
@onready var name_input = $MarginContainer/LayoutCreation/Panels/CharacterContainer/Namebox/NameLineEdit
@onready var create_button = $MarginContainer/LayoutCreation/Panels/CharacterContainer/Namebox/CreateButton

#panel info
@onready var info_title_label = $MarginContainer/LayoutCreation/Panels/InfoContainer/bgPanel/MarginContainer/VBoxContainer/TitleLabel
@onready var info_description_label = $MarginContainer/LayoutCreation/Panels/InfoContainer/bgPanel/MarginContainer/VBoxContainer/DescriptionLabel

@onready var alert_panel = $WarningDialog
@onready var http_request = $HTTPRequest
@onready var exit_button = $MarginContainer/LayoutCreation/Panels/ClassContainer/ExitButton


const SERVER_URL = "http://localhost:2567/api/characters"

var selected_class = ""

var class_info = {
	"Warrior": {
		"title": "Warrior",
		"description": "Um mestre em armas e armaduras, o Guerreiro se destaca no combate corpo a corpo, usando força bruta para superar seus inimigos. Eles são a linha de frente inabalável de qualquer batalha."
	},
	"Assassin": {
		"title": "Assassin",
		"description": "Um especialista em furtividade e subterfúgio. Assassinos atacam das sombras com precisão mortal, usando adagas e venenos para eliminar alvos antes que eles saibam o que os atingiu."
	},
	"Archer": {
		"title": "Arqueiro",
		"description": "Mestres inigualáveis do arco, Arqueiros causam dano devastador à distância. Seus olhos aguçados podem encontrar uma fraqueza em qualquer defesa, tornando-os um inimigo formidável no campo de batalha."
	},
	"Mage": {
		"title": "Mage",
		"description": "Manipuladores de energias arcanas, Magos comandam os elementos para obliterar seus inimigos. O seu poder é tão vasto quanto seu conhecimento."
	},
	"Blood Mage": {
		"title": "Blood Mage",
		"description": "Um temido praticante de hemomancia, o Mago de Sangue usa sua própria força vital para alimentar feitiços poderosos e proibidos, um curador altruísta que canaliza o próprio sangue para realizar milagres. Pagando um preço em sua própria vitalidade."
	}
}

func _ready():
	var label = alert_panel.get_label()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	create_button.pressed.connect(_on_create_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	http_request.request_completed.connect(_on_http_request_completed)
	
	warrior_button.pressed.connect(_on_class_button_pressed.bind("Warrior"))
	#assassin_button.pressed.connect(_on_class_button_pressed.bind("Assassin"))
	archer_button.pressed.connect(_on_class_button_pressed.bind("Archer"))
	mage_button.pressed.connect(_on_class_button_pressed.bind("Mage"))
	#bloodmage_button.pressed.connect(_on_class_button_pressed.bind("Blood Mage"))

	_on_class_button_pressed("Warrior")
	
func _on_class_button_pressed(character_name):
	selected_class = character_name
	print("classe selecionada: ", selected_class)
	
	clear_preview()
	prepare_preview(selected_class)
	
	if class_info.has(character_name):
		var info = class_info[character_name]
		info_title_label.text = info["title"]
		info_description_label.text = "[fill]" + info["description"] + "[/fill]"
	else:
		info_title_label.text = "Classe Desconhecida"
		info_description_label.text = "Nenhuma informação para essa classe"

func _on_create_pressed():
	var char_name = name_input.text.strip_edges()
	#var char_name = name_input.text.strip_edges()

	if selected_class == "":
		alert_panel.dialog_text = "Selecione uma classe!"
		alert_panel.popup_centered()
		return
	
	if char_name == "":
		alert_panel.dialog_text = "O nome não pode ficar em branco!"
		alert_panel.popup_centered()
		return
	
	var body = JSON.stringify({
		"name": char_name,
		"character_class": selected_class
	})
	var token = Globals.token
	var headers = ["Content-Type: application/json", "Authorization: Bearer " + token]

	http_request.request(SERVER_URL, headers, HTTPClient.METHOD_POST, body)

func prepare_preview(character_name: String) -> void:
	var camera = preview.get_node("Camera3D")
	camera.position = Vector3(0, 2, 5)
	camera.look_at(Vector3.ZERO, Vector3.UP)

	var light = preview.get_node("DirectionalLight3D")
	light.rotation_degrees = Vector3(-45, 45, 0)

	var char_scene_path = "res://assets/character/" + character_name.replace(" ", "") + ".glb"
	var char_scene = load(char_scene_path).instantiate()
	char_scene.position = Vector3(0, 0, 0)
	char_scene.rotation_degrees = Vector3.ZERO
	char_scene.scale = Vector3.ONE
	preview.add_child(char_scene)

	var anim_player = char_scene.get_node("AnimationPlayer")
	if anim_player:
		var idle_animation = anim_player.get_animation("Idle")
		idle_animation.set_loop_mode(Animation.LOOP_LINEAR)
		anim_player.play("Idle")

func clear_preview():
	for child in preview.get_children():
		if child.name != "Camera3D" and child.name != "DirectionalLight3D":
			child.queue_free()

func _on_http_request_completed(result, response_code, headers, body):
	match response_code:
		201:
			_on_character_created_success_confirmed()
		401:
			alert_panel.dialog_text = "Nome já existe!"
			alert_panel.popup_centered()
		_:
			alert_panel.dialog_text = "Erro de conexão com o servidor."
			alert_panel.popup_centered()

func _on_character_created_success_confirmed():
	get_tree().change_scene_to_file("res://character_selection/CharacterSelectionScreen.tscn")

func _on_exit_pressed():
	get_tree().change_scene_to_file("res://character_selection/CharacterSelectionScreen.tscn")
