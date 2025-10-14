extends StaticBody3D

@onready var loot_ui = $LootUI
var playerId
var room
@onready var base_texture = preload("res://assets/loot/loot_slot.png")

func _ready() -> void:
	loot_ui.hide()

func _process(delta: float) -> void:
	if loot_ui.visible:
		var camera = get_viewport().get_camera_3d()
		if camera:
			loot_ui.global_position = camera.unproject_position(global_position)
			
func _unhandled_input(event): if event.is_action_pressed("ui_cancel"): 
	if loot_ui.visible: 
		loot_ui.hide() 
		get_viewport().set_input_as_handled()
		
func toggle_loot_ui(playerId) -> void:
	loot_ui.visible = not loot_ui.visible
	self.playerId = playerId
	
func hide_loot_ui() -> void:
	loot_ui.hide()

func check_and_close():
	for button_icon in get_node("LootUI/LootContainer").get_children():
		if button_icon.get_child(0).texture != base_texture:
			return
	queue_free()
