extends Control

# --- Node References ---
@onready var container = $HBoxContainer/InventoryItems/InventoryContainer
@onready var stats = $PlayerStats
@onready var gold_label = $HBoxContainer/InventoryItems/Gold/TextureRect/GoldAmount
@onready var helmet_equipment_slot = $HBoxContainer/PlayerEquipment/VBoxContainer/Helmet/TextureRect
@onready var armor_equipment_slot = $HBoxContainer/PlayerEquipment/VBoxContainer/Body/TextureRect
var player
const SLOT_COUNT := 60
var equipment_slots = {}


func _ready() -> void:
	equipment_slots = {
		"Helmet": helmet_equipment_slot,
		"Armor": armor_equipment_slot
	}
	
	for i in range(SLOT_COUNT):
		var slot = Button.new()
		slot.name = "Slot_%d" % i
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
		slot.custom_minimum_size = Vector2(32, 32)
		slot.mouse_entered.connect(_on_slot_mouse_entered.bind(slot))
		slot.mouse_exited.connect(_on_slot_mouse_exited.bind(slot))
		slot.gui_input.connect(_on_slot_gui_input.bind(slot))
		
		var icon = TextureRect.new()
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		slot.add_child(icon)
		
		var label = Label.new()
		label.anchor_bottom = 1
		label.anchor_right = 1
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		slot.add_child(label)
		
		container.add_child(slot)

func _on_slot_gui_input(event: InputEvent, slot):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
		var data = slot.get_meta("item_data")
		if not data:
			return

		if equipment_slots.has(data.type):
			if data.limitedClasses.has(player.character_class) or data.limitedClasses.has("Todas"):
				_equip_item(slot, data) # Single call to our new, clean function
			else:
				player.show_player_alert("Você não pode equipar esse item.")
				
func _equip_item(inventory_slot, new_item_data):
	var target_slot = equipment_slots[new_item_data.type]
	if target_slot.get_meta("item_data"):
		var old_item_data = target_slot.get_meta("item_data")
		inventory_slot.set_meta("item_data", old_item_data)
		inventory_slot.get_child(0).texture = target_slot.texture
		inventory_slot.get_child(1).text = str(old_item_data.get("quantity", ""))
		set_slot_tooltip(inventory_slot.get_child(0), old_item_data.type, old_item_data)
	else:
		empty_slot_data(inventory_slot)
	target_slot.set_meta("item_data", new_item_data)
	target_slot.texture = load("res://assets/icons/items/" + str(new_item_data.id) + ".png")
	set_slot_tooltip(target_slot, new_item_data.type, new_item_data)
	
	player.room.send("equipItem", {"itemId": new_item_data.id})



func update_inventory(loot_data):
	var index = 0
	for slot in container.get_children():
		if not slot is Button:
			continue
		if not slot.get_meta("item_data"):
			var icon = slot.get_child(0)
			var label = slot.get_child(1)
			var item_data = {
				"id": loot_data.itemId,
				"name": loot_data.name,
				"quantity": loot_data.quantity,
				"description": loot_data.description,
				"type": loot_data.type,
				"index": index,
				"defense": loot_data.get("defense", null),
				"attack": loot_data.get("attack", null),
				"limitedClasses": loot_data.get("limitedClasses", null)
			}
			
			slot.set_meta("item_data", item_data)
			
			var texture_path = "res://assets/icons/items/%d.png" % loot_data.itemId
			if ResourceLoader.exists(texture_path):
				icon.texture = load(texture_path)
			
			if item_data.type == "Armor" or item_data.type == "Helmet":
				set_slot_tooltip(icon, item_data.type, item_data)
			elif item_data.attack != null:
				icon.tooltip_text = "%s\nAtaque: %s\n%s" % [item_data.name, item_data.attack, item_data.description]
			else:
				icon.tooltip_text = "%s\n%s\n" % [item_data.name, item_data.description]

			label.text = str(item_data.quantity)
			return
		index += 1
	print("No vacant slots available!")


func set_slot_tooltip(icon, itemType, data):
	var limited_classes_text = ""
	if data.limitedClasses:
		limited_classes_text = "\nClasses permitidas: " + ", ".join(data.limitedClasses)
		
	if itemType == "Armor" or itemType == "Helmet":
		icon.tooltip_text = "%s\nDefesa: %s\n%s%s" % [
			data.name,
			data.defense,
			data.description,
			limited_classes_text
		]


func empty_slot_data(slot):
	slot.set_meta("item_data", null)
	var icon = slot.get_child(0)
	icon.texture = null
	icon.tooltip_text = ""
	slot.get_child(1).text = ""


func _on_slot_mouse_entered(slot: Button) -> void:
	slot.modulate.a = 0.85
	
func _on_slot_mouse_exited(slot: Button) -> void:
	slot.modulate.a = 1.0
