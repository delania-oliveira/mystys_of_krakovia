extends Panel

@onready var icon: TextureRect = $Icon
@onready var index_label: Label = $IndexLabel
@onready var cooldown_overlay: ColorRect = $CooldownOverlay
@onready var cooldown_label: Label = $CooldownLabel

var current_skill_data: Dictionary
var current_skill_id: String
var slot_index: int = -1
var is_on_cooldown: bool = false
var cooldown_time: float = 0.0
var total_cooldown_duration: float = 0.0 
var initial_overlay_size: Vector2

var cooldown_timer: Timer

func _ready():
	cooldown_overlay.visible = false
	cooldown_label.visible = false

	initial_overlay_size = cooldown_overlay.size

	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)
	cooldown_timer.connect("timeout", _on_cooldown_finished)

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
	if is_on_cooldown:
		return
		
	if not current_skill_data.is_empty():
		if current_skill_id.contains("default_skill"):
			player.play_default_skill(player.current_target)
		elif current_skill_id.contains("arcane_explosion_mage"):
			player.play_arcane_explosion(self)
		elif current_skill_id.contains("multi_shot_archer"):
			player.play_multi_shot(player.current_target, self)
		elif current_skill_id.contains("flame_arrow_archer"):
			player.play_flame_arrow(player.current_target, self)
		start_cooldown(current_skill_data.cooldown)
	else:
		print("This action slot is empty.")
		
func start_cooldown(duration: float):
	is_on_cooldown = true
	cooldown_time = duration
	total_cooldown_duration = duration

	cooldown_overlay.visible = true
	cooldown_overlay.modulate = Color(0, 0, 0, 0.6)
	cooldown_overlay.size = initial_overlay_size

	cooldown_label.visible = true
	cooldown_label.text = str(round(duration))

	cooldown_timer.start(duration)
	set_process(true)

func _process(delta: float):
	if is_on_cooldown:
		cooldown_time -= delta
		
	if cooldown_time > 0:
		cooldown_label.text = str(ceil(cooldown_time))
		var remaining_ratio = cooldown_time / total_cooldown_duration
		cooldown_overlay.size.y = initial_overlay_size.y * remaining_ratio

	else:
		cooldown_label.text = ""
		cooldown_overlay.visible = false
		set_process(false)

func _on_cooldown_finished():
	is_on_cooldown = false
	cooldown_overlay.visible = false
	cooldown_label.visible = false
	cooldown_overlay.size = initial_overlay_size
