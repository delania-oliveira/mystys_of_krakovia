extends Node
var Char = preload("res://tests/Player.tscn")
var room
var state
func _ready():
	if Network.client:
		_on_network_ready()
	else:
		Network.connection_ready.connect(_on_network_ready)
	
func _on_network_ready():
	var promise = Network.client.join_or_create(Network.RoomState, "my_room")
	await promise.completed
	if promise.get_state() == promise.State.Failed:
		print("Failed")
		return
	room = promise.get_data()
	state = room.get_state()
	room.on_message("login").on(Callable(self, "_on_login_success"))
	state.listen("players:add").on(Callable(self, "_on_players_add"))
	state.listen("players:remove").on(Callable(self, "_on_players_remove"))
	room.send("login", {"id": Character.character_id})
	
func _on_login_success(data):
	Character.login_x = data.x
	Character.login_y = 0
	Character.login_z = data.z
	var local_value = state.players.at(room.session_id)
	if local_value:
		_on_players_add(null, local_value, room.session_id)
	
func _on_players_add(target, value, key):
	var ch = Char.instantiate()
	ch.position = Vector3(Character.login_x, Character.login_y, Character.login_z)
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
