extends Control

@onready var container = $VBoxContainer/InventoryContainer
@onready var player
const SLOT_COUNT := 60
@onready var current_gold = 0
@onready var vbox = $VBoxContainer
@onready var gold_label = $VBoxContainer/Gold/TextureRect/GoldAmount

func _on_slot_mouse_entered(slot: Button) -> void:
	slot.modulate.a = 0.85
	
func _on_slot_mouse_exited(slot: Button) -> void:
	slot.modulate.a = 1.0
	
func _ready() -> void:
	if player and player.current_gold:
		gold_label.text = "Gold: " + player.current_gold
	else:
		gold_label.text = "Gold: 0"
		 
	for i in range(SLOT_COUNT):
		var slot = Button.new()
		slot.name = "Slot_%d" % i
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
		slot.custom_minimum_size = Vector2(32, 32)
		slot.mouse_entered.connect(_on_slot_mouse_entered.bind(slot))
		slot.mouse_exited.connect(_on_slot_mouse_exited.bind(slot))
		var icon = TextureRect.new()
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon.expand = true
		icon.stretch_mode = TextureRect.STRETCH_SCALE
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		slot.add_child(icon)
		
		var label = Label.new()
		label.anchor_bottom = 1
		label.anchor_right = 1
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		slot.add_child(label)
		
		container.add_child(slot)

func update_inventory(loot_id: int, quantity: int, defense: int, attack: int, description, name):
	for slot in container.get_children():
		if not slot is Button:
			continue
		var icon = slot.get_child(0)
		var label = slot.get_child(1)
		
		if icon.texture == null:
			var texture_path = "res://assets/icons/items/%d.png" % loot_id
			if ResourceLoader.exists(texture_path):
				icon.texture = load(texture_path)
				if defense != 0:
					icon.tooltip_text = "%s\nDefesa: %s\n%s" % [name, defense, description]
				elif attack != 0:
					icon.tooltip_text = "%s\nAtaque: %s\n%s" % [name, attack, description]
				else:
					icon.tooltip_text = "%s\n%s\n" % [name, description]
			label.text = str(quantity)
			return
	
	print("No vacant slots available!")

	
