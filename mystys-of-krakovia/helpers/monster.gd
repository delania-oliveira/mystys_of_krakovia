extends Node

func set_monster_stats(monster, value):
	monster.speed = value.speed
	var name_label = monster.get_node("Name") 
	if value.type == "boss":
		name_label.text = "✪ " + value.name
		name_label.modulate = Color(1, 0, 0)
	else:
		name_label.set_text(value.name)
	if value.name == "Beholder":
		name_label.position.y = 8
	elif value.name == "Galdurg o Obliterador":
		name_label.position.y = 4
	monster.max_health = value.max_health
	monster.current_health = value.health
	monster.character_name = value.name
	monster.defense = value.defense
	monster.difficulty = value.difficulty
	
func get_first_mesh_aabb(node):
	if node is MeshInstance3D:
		return node.get_aabb()
	
	for child in node.get_children():
		var aabb = get_first_mesh_aabb(child)
		if aabb:
			return aabb
			
	return null
