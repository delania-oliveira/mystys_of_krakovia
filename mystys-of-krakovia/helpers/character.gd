extends Node

var character_id: String = ""
var login_x: int = 0
var login_y: int = 0
var login_z: int = 0
var character_name: String = ""
var health: int = 0
var mana: int = 0
var level: int = 0
var experience: int = 0
var character_class: String = ""

func prepare_health_bar(character, current_health, max_health):
	character.current_health = current_health
	character.max_health = max_health
	var health_bar = character.get_node("HealthBar/ProgressHealthBar")
	var health_label = character.get_node("HealthBar/ProgressHealthBar/HealthLabel")
	health_bar.max_value = max_health
	health_bar.value = current_health
	health_label.text = str(current_health) + " / " + str(max_health)
	health_bar.show_percentage = false
	
func prepare_mana_bar(character, current_mana, max_mana):
	var mana_bar = character.get_node("ManaBar/ProgressManaBar")
	var mana_label = character.get_node("ManaBar/ProgressManaBar/ManaLabel")
	mana_bar.max_value = max_mana
	mana_bar.value = current_mana
	mana_label.text = str(current_mana) + " / " + str(max_mana)
	mana_bar.show_percentage = false

func setup_remote_player(player):
	player.get_node("ActionBar").hide()
	player.get_node("SpellBook").hide()
	player.get_node("ManaBar").hide()
	player.get_node("HealthBar").hide()
	player.get_node("ExperienceBar").hide()
	player.is_local = false
	player.get_node("Camera3D").current = false
	player.get_node("CastBar").hide()
func prepare_experience_bar(character, current_exp, current_level, max_exp):
	var exp_bar = character.get_node("ExperienceBar/ProgressExperienceBar")
	var exp_label = character.get_node("ExperienceBar/ProgressExperienceBar/ExperienceLabel")
	var lvl_label = character.get_node("ExperienceBar/ProgressExperienceBar/LevelLabel")
	exp_bar.max_value = max_exp
	exp_bar.value = current_exp
	character.max_exp = max_exp
	character.current_experience = current_exp
	character.current_level = current_level
	lvl_label.text = "Level: " + str(current_level)
	exp_label.text = str(int(current_exp)) + " / " + str(max_exp)
	exp_bar.show_percentage = false
	
func configure_character(character, value, key, room, model):
	character.get_node("Pivot").add_child(model)
	character.position = Vector3(value.x, value.y, value.z)
	character.get_node("Name").set_text(value.name)
	value.node = character
	character.room = room
	character.player_key = key
	return character
