# SpellbookUI.gd (Revised)
extends Control

@onready var skills_grid_container = $SkillsGridContainer
const SKILL_DISPLAY_SCENE = preload("res://tests/players/skills/Skill.tscn")

var skill_icons: Dictionary = {
	"auto_attack_hunter": preload("res://assets/icons/auto_attack_archer_icon.png"),
	"auto_attack_hunter2": preload("res://assets/icons/auto_attack_archer_icon.png"),
	"auto_attack_hunter3": preload("res://assets/icons/auto_attack_archer_icon.png"),
	"auto_attack_mage": preload("res://assets/icons/auto_attack_mage_icon.png"),
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
