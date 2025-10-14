# ActionBarSlot.gd
extends Panel

@onready var icon: TextureRect = $Icon
@onready var index_label: Label = $IndexLabel
var current_skill_data: Dictionary
var current_skill_id: String
var slot_index: int = -1

func set_index(i: int):
	slot_index = i
	index_label.text = str(i + 1)
	
func _can_drop_data(at_position: Vector2, data) -> bool:
	return data is Dictionary and data.get("type") == "skill"

func _drop_data(at_position: Vector2, data):
	current_skill_data = data.skill_full_data
	current_skill_id = data.skill_id
	icon.tooltip_text = "Nome: %s\nDano Base: %s" % [current_skill_data.name, current_skill_data.baseDamage]
	icon.texture = data.source_texture
	
func activate_skill(player):
	if not current_skill_data.is_empty():
		if current_skill_id.contains("default_skill"):
			player.play_default_skill(player.current_target)
		if current_skill_id.contains("arcane_explosion_mage"):
			player.play_arcane_explosion()
		if current_skill_id.contains("multi_shot_archer"):
			player.play_multi_shot(player.current_target)
		if current_skill_id.contains("flame_arrow_archer"):
			player.play_flame_arrow(player.current_target)
	else:
		print("This action slot is empty.")
