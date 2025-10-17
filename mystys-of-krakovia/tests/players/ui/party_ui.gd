extends VBoxContainer

var room
var local_player_id
var current_party
var dragging := false
var drag_offset := Vector2.ZERO
@onready var leave_party_container = $PanelContainer
func _ready() -> void:
	leave_party_container.hide()
	
func _create_party(members, leader):
	for player in members:
		_add_member(player, leader)

func _add_member(player, leader):
	# Create an HBox for each member (name + HP bar)
	var member_box = VBoxContainer.new()
	member_box.name = player.id
	member_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	member_box.alignment = BoxContainer.ALIGNMENT_CENTER
	# Create name label
	var name_label = Label.new()
	if player.id == leader:
		name_label.text = "👑 " + "Lv." + str(player.level) + " " + player.name + " - " + player.character_class
		name_label.add_theme_color_override("font_color", Color("ffd500ff"))
	else:
		name_label.text = "Lv." + str(player.level) + " " + player.name + " - " + player.character_class
	name_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	name_label.name = player.name
	# Create HP bar
	var hp_bar = ProgressBar.new()
	hp_bar.name = "HealthBar"
	hp_bar.min_value = 0
	hp_bar.max_value = player.max_health
	hp_bar.value = player.current_health
	hp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hp_bar.show_percentage = false
	var fill_style = StyleBoxFlat.new()
	hp_bar.add_theme_stylebox_override("fill", fill_style)
	fill_style.bg_color = Color.SEA_GREEN
	hp_bar.add_theme_stylebox_override("fill", fill_style)
	hp_bar.custom_minimum_size = Vector2(240, 30)
	hp_bar.connect("gui_input", Callable(self, "_on_member_box_gui_input").bind(player))
	member_box.connect("gui_input", Callable(self, "_on_member_box_gui_input").bind(player))
	member_box.add_child(name_label)
	member_box.add_child(hp_bar)
	
	add_child(member_box)
	
func _on_member_box_gui_input(event: InputEvent, player):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		room.send("setPartyTarget", {"targetId": player.id})

	return null
	
func _update_member_health(data):
	var member_box = get_node_or_null(str(data.member))
	if member_box:
		var health_bar = member_box.get_node("HealthBar")
		health_bar.value = data.health
		
func _update_member_level(member):
	var member_box = get_node(str(member.id))
	if not member_box:
		print("No member box found for id:", member.id)
		return

	var name_label = member_box.get_node(member.name)
	if not name_label:
		print("No name label found for:", member.name)
		return

	if member.id == member.partyId:
		name_label.text = "👑 Lv." + str(member.level) + " " + member.name + " - " + member.character_class
		name_label.add_theme_color_override("font_color", Color("ffd500ff"))
	else:
		name_label.text = "Lv." + str(member.level) + " " + member.name + " - " + member.character_class
		name_label.add_theme_color_override("font_color", Color.WHITE)

		
func clear_members():
	for child in get_children():
		child.queue_free()
		
func toggle_party_leave_ui():
	if leave_party_container.visible:
		leave_party_container.hide()
	else:
		leave_party_container.show()
		
func _on_leave_party_button_down() -> void:
	clear_members()
	room.send("leaveParty", {"leavingPlayerId": local_player_id})
	
func _on_cancel_button_down() -> void:
	leave_party_container.hide()

# This function is called when any input event occurs over the control node.
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		toggle_party_leave_ui()
		get_viewport().set_input_as_handled()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_offset = get_global_mouse_position() - global_position
			else:
				dragging = false
	elif event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() - drag_offset
