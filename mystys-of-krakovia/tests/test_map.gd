extends Node
var room
var state

func _ready():
	if Network.client:
		_on_network_ready()
	else:
		Network.connection_ready.connect(_on_network_ready)
	
func _on_network_ready():
	var join_options = { "character_id": Character.character_id }
	var promise = Network.client.join_or_create(Network.RoomState, "Krakovia", join_options)
	await promise.completed
	if promise.get_state() == promise.State.Failed:
		print("Failed")
		return
	room = promise.get_data()
	state = room.get_state()
	state.listen("players:add").on(Callable(self, "_on_players_add"))
	state.listen("players:remove").on(Callable(self, "_on_players_remove"))
	
func _on_players_add(target, value, key):
	var characterScene = "res://tests/" + value.character_class + ".tscn"
	var Char = load(characterScene)
	var ch = Char.instantiate()
	ch.position = Vector3(value.x, value.y, value.z)
	ch.get_node("Name").set_text(value.name)
	add_child(ch)	
	value.node = ch
	ch.room = room
	if key == room.session_id:
		ch.is_local = true
		ch.get_node("Camera3D").current = true
	else:
		ch.is_local = false
		ch.get_node("Camera3D").current = false
		value.listen(":change").on(Callable(self, "_on_player"))
		
func _on_player(target):
	var ch = target.node
	ch.on_network_data_received(target) 
		
func _on_players_remove(target, value, key):
	if value.node:
		value.node.queue_free()
