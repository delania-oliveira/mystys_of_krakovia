extends Control

var invitedPlayer
var invitingPlayer
var room

func _on_refuse_button_down() -> void:
	queue_free()

func _on_accept_button_down() -> void:
	room.send("addToParty", {"playerInvitedId": invitedPlayer, "playerInvitingId": invitingPlayer})
	queue_free()
