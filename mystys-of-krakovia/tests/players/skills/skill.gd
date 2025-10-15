# SkillDisplay.gd
extends TextureRect

@onready var name_label = $NameLabel

var skill_data: Dictionary = {}

func setup_skill(data: Dictionary, icon_texture: Texture2D):
	skill_data = data

	self.texture = icon_texture
	name_label.text = data.name

	var description = data.get("description", "No description available.")
	self.tooltip_text = "%s\nDano Base: %s\nClasse: %s\nDescrição: %s" % [data.name, data.baseDamage, data.characterClass, description]

func _get_drag_data(at_position: Vector2):
	var data_to_drag = {
		"type": "skill",
		"skill_id": skill_data.id,
		"skill_name": skill_data.name,
		"skill_full_data": skill_data,
		"source_texture": self.texture,
		"cooldown": skill_data.cooldown
	}
		
	var drag_preview = TextureRect.new()
	drag_preview.texture = self.texture
	drag_preview.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	drag_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	drag_preview.size = self.size
	set_drag_preview(drag_preview)

	return data_to_drag
