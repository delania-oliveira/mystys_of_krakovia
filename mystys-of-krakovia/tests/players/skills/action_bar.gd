# ActionBar.gd
extends Control

@onready var slots_container = $HBoxContainer
var player
var active_cooldowns: Dictionary = {}
func _ready():
	for i in range(slots_container.get_child_count()):
		var slot = slots_container.get_child(i)
		slot.set_index(i)
		if slot is Panel and slot.has_signal("skill_activated"):
			slot.skill_activated.connect(_on_skill_activated)
func _process(delta: float):
	var skills_to_remove = []
	for skill_id in active_cooldowns:
		active_cooldowns[skill_id] -= delta
		if active_cooldowns[skill_id] <= 0:
			skills_to_remove.append(skill_id)
	
	for skill_id in skills_to_remove:
		active_cooldowns.erase(skill_id)
		
func _on_skill_activated(skill_id: String, cooldown_duration: float):
	if not active_cooldowns.has(skill_id):
		active_cooldowns[skill_id] = cooldown_duration
	for slot in slots_container.get_children():
		if slot is Panel and slot.current_skill_id == skill_id:
			slot.start_cooldown(cooldown_duration)
			
func _unhandled_input(event):
	if not player:
		return
	var slots = slots_container.get_children()
	if Input.is_action_just_pressed("action_1"):
		if slots.size() > 0:
			slots[0].activate_skill(player)
			get_viewport().set_input_as_handled()

	# Check for Action 2 (Key "2")
	if Input.is_action_just_pressed("action_2"):
		if slots.size() > 1:
			slots[1].activate_skill(player)
			get_viewport().set_input_as_handled()
			
	# Check for Action 3 (Key "3")
	if Input.is_action_just_pressed("action_3"):
		if slots.size() > 2:
			slots[2].activate_skill(player)
			get_viewport().set_input_as_handled()
			
	if Input.is_action_just_pressed("action_4"):
		if slots.size() > 3:
			slots[3].activate_skill(player)
			get_viewport().set_input_as_handled()
	
	if Input.is_action_just_pressed("action_5"):
		if slots.size() > 4:
			slots[4].activate_skill(player)
			get_viewport().set_input_as_handled()
			
	if Input.is_action_just_pressed("action_6"):
		if slots.size() > 5:
			slots[5].activate_skill(player)
			get_viewport().set_input_as_handled()
			
	if Input.is_action_just_pressed("action_7"):
		if slots.size() > 6:
			slots[6].activate_skill(player)
			get_viewport().set_input_as_handled()
			
func check_cooldown_for_slot(slot: Panel):
	var skill_id = slot.current_skill_id
	
	if active_cooldowns.has(skill_id):
		var remaining_time = active_cooldowns[skill_id]
		if remaining_time > 0:
			slot.start_cooldown(remaining_time)
