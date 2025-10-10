# ActionBar.gd
extends Control

@onready var slots_container = $HBoxContainer
var player
func _ready():
	for i in range(slots_container.get_child_count()):
		var slot = slots_container.get_child(i)
		slot.set_index(i)
		
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
			slots[1].activate_skill()
			get_viewport().set_input_as_handled()
			
	# Check for Action 3 (Key "3")
	if Input.is_action_just_pressed("action_3"):
		if slots.size() > 2:
			slots[2].activate_skill()
			get_viewport().set_input_as_handled()
	
