extends Button

@onready var item_id
@onready var item_name
@onready var item_quantity
@onready var item_tex
@onready var room
@onready var base_tex = preload("res://assets/icons/skills/action_bar_slot.png")

func _on_pressed() -> void:
	if item_id and item_name and item_quantity and item_tex:
		room.send("looted", {"playerId": owner.playerId, "itemId": item_id, "itemName": item_name, "itemQuantity": item_quantity})
		get_child(0).texture = base_tex
		get_child(1).text = ""
		owner.check_and_close()
