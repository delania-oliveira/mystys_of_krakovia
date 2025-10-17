extends Control

# --- Node References ---
@onready var container = $HBoxContainer/InventoryItems/InventoryContainer
@onready var stats = $PlayerStats
@onready var gold_label = $HBoxContainer/InventoryItems/Gold/TextureRect/GoldAmount
@onready var helmet_equipment_slot = $HBoxContainer/PlayerEquipment/VBoxContainer/Helmet/TextureRect
@onready var armor_equipment_slot = $HBoxContainer/PlayerEquipment/VBoxContainer/Body/TextureRect
@onready var weapon_equipment_slot = $HBoxContainer/PlayerEquipment/Weapon/TextureRect
var player
const SLOT_COUNT := 60
var equipment_slots = {}

const RARITY_COLORS = {
	"Comum": Color("#a9a9a9"),      # Dark Gray
	"Incomum": Color("#2ecc71"),    # Green
	"Raro": Color("#3498db"),        # Blue
	"Épico": Color("#9b59b6"),        # Purple
	"Lendário": Color("#f1c40f")     # Gold
}
const DEFAULT_SLOT_COLOR = Color("#333333")
func _ready() -> void:
	equipment_slots = {
		"Helmet": helmet_equipment_slot,
		"Armor": armor_equipment_slot,
		"Weapon": weapon_equipment_slot
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
				_equip_item(slot, data)
			else:
				player.show_player_alert("Você não pode equipar esse item.")
				
func clear_slot(slot: Button):
	slot.remove_meta("item_data")

	var icon = slot.get_child(0)
	var label = slot.get_child(1)

	icon.texture = null
	icon.tooltip_text = ""
	label.text = ""

	var default_stylebox = StyleBoxFlat.new()
	default_stylebox.bg_color = DEFAULT_SLOT_COLOR
	slot.add_theme_stylebox_override("normal", default_stylebox)
	
func _equip_item(inventory_slot, new_item_data):
	var target_slot = equipment_slots[new_item_data.type]
	var old_item_data = target_slot.get_meta("item_data", null)

	target_slot.set_meta("item_data", new_item_data)
	if old_item_data:
		inventory_slot.set_meta("item_data", old_item_data)
	else:
		clear_slot(inventory_slot)

	target_slot.texture = load("res://assets/icons/items/" + str(new_item_data.id) + ".png")
	set_slot_tooltip(target_slot, new_item_data.type, new_item_data)
	_apply_rarity_style(target_slot, new_item_data) # <-- Update color

	var inv_icon = inventory_slot.get_child(0)
	var inv_label = inventory_slot.get_child(1)

	if old_item_data:
		inv_icon.texture = load("res://assets/icons/items/" + str(old_item_data.id) + ".png")
		inv_label.text = str(old_item_data.get("quantity", ""))
		set_slot_tooltip(inv_icon, old_item_data.type, old_item_data)
	else:
		inv_icon.texture = null
		inv_label.text = ""
		inv_icon.tooltip_text = ""

	_apply_rarity_style(inventory_slot, old_item_data)
	if old_item_data:
		player.room.send("equipItem", {"newItemId": new_item_data.id, "oldItemId": old_item_data.id})
	else:
		player.room.send("equipItem", {"newItemId": new_item_data.id})
func _apply_rarity_style(slot_node, item_data):
	var color_to_apply = DEFAULT_SLOT_COLOR

	if item_data and item_data.has("rarity"):
		color_to_apply = RARITY_COLORS.get(item_data.rarity, DEFAULT_SLOT_COLOR)
	var new_stylebox = StyleBoxFlat.new()
	new_stylebox.bg_color = color_to_apply
	if slot_node is Button:
		slot_node.add_theme_stylebox_override("normal", new_stylebox)
	elif slot_node is Panel or slot_node is TextureRect:
		slot_node.add_theme_stylebox_override("panel", new_stylebox)

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
				"defense": loot_data.get("defense", 0),
				"attack": loot_data.get("attack", 0),
				"limitedClasses": loot_data.get("limitedClasses", null),
				"rarity": loot_data.get("rarity", "Comum")
			}
			
			slot.set_meta("item_data", item_data)
			var rarity_color = RARITY_COLORS.get(item_data.rarity, RARITY_COLORS["Comum"])
			var new_stylebox = StyleBoxFlat.new()
			new_stylebox.bg_color = rarity_color
			new_stylebox.border_width_left = 2
			new_stylebox.border_width_top = 2
			new_stylebox.border_width_right = 2
			new_stylebox.border_width_bottom = 2
			new_stylebox.border_color = Color(rarity_color.r * 0.7, rarity_color.g * 0.7, rarity_color.b * 0.7)
			slot.add_theme_stylebox_override("normal", new_stylebox)
			var texture_path = "res://assets/icons/items/%d.png" % loot_data.itemId
			if ResourceLoader.exists(texture_path):
				icon.texture = load(texture_path)
			
			set_slot_tooltip(icon, item_data.type, item_data)

			label.text = str(item_data.quantity)
			return
		index += 1
	print("No vacant slots available!")


func set_slot_tooltip(icon, itemType, data):
	var limited_classes_text = ""
	if data.limitedClasses:
		limited_classes_text = "\nClasses permitidas: " + ", ".join(data.limitedClasses)
		
	if itemType == "Armor" or itemType == "Helmet":
		icon.tooltip_text = "%s\nDefesa: %s\n%s\n%s%s" % [
			data.name,
			data.defense,
			data.description,
			data.rarity,
			limited_classes_text
		]
	elif itemType == "Weapon":
		icon.tooltip_text = "%s\nAtaque: %s\n%s\n%s%s" % [
			data.name,
			data.attack,
			data.description,
			data.rarity,
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
