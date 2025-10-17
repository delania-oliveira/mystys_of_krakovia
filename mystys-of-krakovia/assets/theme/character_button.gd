extends Button

@onready var avatar_texture_rect = $HBoxContainer/Avatar
@onready var name_label = $HBoxContainer/VBoxContainer/NameLabel
@onready var class_label = $HBoxContainer/VBoxContainer/ClassLabel
@onready var level_label = $HBoxContainer/VBoxContainer/LevelLabel

signal selected(character_data)

var character_data: Dictionary

func _ready():
	pressed.connect(_on_pressed)

func setup(data: Dictionary, avatar_texture: Texture2D):
	character_data = data
	
	name_label.text = character_data.name
	class_label.text = "%s" % [character_data.class]
	level_label.text = "level %d" % [character_data.level]
	avatar_texture_rect.texture = avatar_texture

func _on_pressed():
	emit_signal("selected", character_data)
