extends Node

const colyseus = preload("res://addons/godot_colyseus/lib/colyseus.gd")

signal connection_ready

class RoomState extends colyseus.Schema:
	static func define_fields():
		return [
			colyseus.Field.new("players", colyseus.MAP, Player),
			colyseus.Field.new("monsters", colyseus.MAP, Monster),
		]
class Monster extends colyseus.Schema:
	static func define_fields():
		return [
			colyseus.Field.new("monster_id", colyseus.STRING),
			colyseus.Field.new("name", colyseus.STRING),
			colyseus.Field.new("x", colyseus.NUMBER),
			colyseus.Field.new("y", colyseus.NUMBER),
			colyseus.Field.new("z", colyseus.NUMBER),
			colyseus.Field.new("spawn_x", colyseus.NUMBER),
			colyseus.Field.new("spawn_y", colyseus.NUMBER),
			colyseus.Field.new("spawn_z", colyseus.NUMBER),
			colyseus.Field.new("type", colyseus.STRING),
			colyseus.Field.new("inputX", colyseus.NUMBER),
			colyseus.Field.new("inputZ", colyseus.NUMBER),
			colyseus.Field.new("speed", colyseus.NUMBER),
			colyseus.Field.new("isTargeting", colyseus.BOOLEAN),
			colyseus.Field.new("attack", colyseus.NUMBER),
			colyseus.Field.new("health", colyseus.NUMBER),
			colyseus.Field.new("max_health", colyseus.NUMBER),
			colyseus.Field.new("detectionRange", colyseus.NUMBER),
			colyseus.Field.new("targetId", colyseus.STRING),
			colyseus.Field.new("attackTimer", colyseus.NUMBER),
			colyseus.Field.new("attackCooldown", colyseus.NUMBER),
			colyseus.Field.new("attackRange", colyseus.NUMBER),
			colyseus.Field.new("difficulty", colyseus.NUMBER),
			colyseus.Field.new("defense", colyseus.NUMBER),
			colyseus.Field.new("experience", colyseus.NUMBER),
			colyseus.Field.new("isDead", colyseus.BOOLEAN),
			colyseus.Field.new("isAggroed", colyseus.BOOLEAN),
			colyseus.Field.new("taggedPlayerId", colyseus.STRING)
		]
class Player extends colyseus.Schema:
	static func define_fields():
		return [
			colyseus.Field.new("id", colyseus.STRING),
			colyseus.Field.new("x", colyseus.NUMBER),
			colyseus.Field.new("y", colyseus.NUMBER),
			colyseus.Field.new("z", colyseus.NUMBER),
			colyseus.Field.new("vx", colyseus.NUMBER),
			colyseus.Field.new("vy", colyseus.NUMBER),
			colyseus.Field.new("vz", colyseus.NUMBER),
			colyseus.Field.new("dirX", colyseus.NUMBER),
			colyseus.Field.new("dirY", colyseus.NUMBER),
			colyseus.Field.new("dirZ", colyseus.NUMBER),
			colyseus.Field.new("inputX", colyseus.NUMBER),
			colyseus.Field.new("inputZ", colyseus.NUMBER),
			colyseus.Field.new("isGrounded", colyseus.BOOLEAN),
			colyseus.Field.new("name", colyseus.STRING),
			colyseus.Field.new("character_class", colyseus.STRING),
			colyseus.Field.new("health", colyseus.NUMBER),
			colyseus.Field.new("max_health", colyseus.NUMBER),
			colyseus.Field.new("mana", colyseus.NUMBER),
			colyseus.Field.new("max_mana", colyseus.NUMBER),
			colyseus.Field.new("level", colyseus.NUMBER),
			colyseus.Field.new("experience", colyseus.NUMBER),
			colyseus.Field.new("animation", colyseus.STRING),
			colyseus.Field.new("isDead", colyseus.BOOLEAN),
			colyseus.Field.new("targetId", colyseus.STRING),
			colyseus.Field.new("targetHealth", colyseus.NUMBER),
			colyseus.Field.new("targetName", colyseus.STRING),
			colyseus.Field.new("defense", colyseus.NUMBER),
			colyseus.Field.new("skillEffect", colyseus.STRING),
			colyseus.Field.new("isAttacking", colyseus.BOOLEAN),
			colyseus.Field.new("max_exp", colyseus.NUMBER),
		]
	
	var node
	
	func _to_string():
		return str("(",self.x,",",self.y,",",self.z,")")

var client

func _ready():
	client = colyseus.Client.new("ws://localhost:2567")
	connection_ready.emit()

func join_room():
	var join_options = { "character_id": CharacterHelper.character_id }
	var promise = Network.client.join_or_create(Network.RoomState, "Krakovia", join_options)
	await promise.completed
	if promise.get_state() == promise.State.Failed:
		print("Failed")
		return
	var room = promise.get_data()
	var state = room.get_state()

	return {"state": state, "room": room}
	
func prepare_room_state(state, owner):
	state.listen("monsters:add").on(Callable(owner, "_on_monster_add"))
	state.listen("monsters:remove").on(Callable(owner, "_on_monster_remove"))
	state.listen("players:add").on(Callable(owner, "_on_players_add"))
	state.listen("players:remove").on(Callable(owner, "_on_players_remove"))
