extends Control
var room
var player

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass

func _on_respawn_button_button_down() -> void:
	queue_free()
	room.send("respawnPlayer")
	player.dead = false
