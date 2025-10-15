# SpellbookUI.gd (Revised)
extends Control

@onready var skills_grid_container = $SkillsGridContainer

const SKILL_DISPLAY_SCENE = preload("res://tests/players/skills/Skill.tscn")

var skill_icons: Dictionary = {
	"default_skill_archer": preload("res://assets/icons/skills/default_skill_archer_icon.png"),
	"default_skill_mage": preload("res://assets/icons/skills/default_skill_mage_icon.png"),
	"arcane_explosion_mage": preload("res://assets/icons/skills/arcane_explosion_mage_icon.png"),
	"multi_shot_archer": preload("res://assets/icons/skills/multi_shot_archer_icon.png"),
	"flame_arrow_archer": preload("res://assets/icons/skills/flame_arrow_archer_icon.png"),
}

func display_player_skills(player_skills_data: Array):
	for child in skills_grid_container.get_children():
		child.queue_free()

	for skill in player_skills_data:
		var skill_display_instance = SKILL_DISPLAY_SCENE.instantiate()
		skills_grid_container.add_child(skill_display_instance)
		
		var icon = skill_icons.get(skill.id)
		if icon:
			skill_display_instance.setup_skill(skill, icon)
		else:
			skill_display_instance.setup_skill(skill, null)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if visible:
			hide()
			get_viewport().set_input_as_handled()
