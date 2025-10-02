extends Node

const colyseus = preload("res://addons/godot_colyseus/lib/colyseus.gd")

signal connection_ready

class RoomState extends colyseus.Schema:
	static func define_fields():
		return [
			colyseus.Field.new("players", colyseus.MAP, Player),
		]
		
class Player extends colyseus.Schema:
	static func define_fields():
		return [
			colyseus.Field.new("x", colyseus.NUMBER),
			colyseus.Field.new("y", colyseus.NUMBER),
			colyseus.Field.new("z", colyseus.NUMBER),
			colyseus.Field.new("vx", colyseus.NUMBER),
			colyseus.Field.new("vy", colyseus.NUMBER),
			colyseus.Field.new("vz", colyseus.NUMBER),
			colyseus.Field.new("dirX", colyseus.NUMBER),
			colyseus.Field.new("dirY", colyseus.NUMBER),
			colyseus.Field.new("dirZ", colyseus.NUMBER),
			colyseus.Field.new("isGrounded", colyseus.BOOLEAN),
			colyseus.Field.new("name", colyseus.STRING),
			colyseus.Field.new("health", colyseus.NUMBER),
			colyseus.Field.new("mana", colyseus.NUMBER),
			colyseus.Field.new("level", colyseus.NUMBER),
			colyseus.Field.new("experience", colyseus.NUMBER),
			colyseus.Field.new("animation", colyseus.STRING)
		]
	
	var node
	
	func _to_string():
		return str("(",self.x,",",self.y,",",self.z,")")

var client
func _ready():
	client = colyseus.Client.new("ws://localhost:2567")
	connection_ready.emit()
	
