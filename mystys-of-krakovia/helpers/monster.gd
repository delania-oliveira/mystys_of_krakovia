extends Node

func set_monster_stats(monster, value):
	monster.speed = value.speed
	monster.get_node("Name").set_text(value.name)
	monster.position = Vector3(value.x, value.y, value.z)
	monster.spawn_position = Vector3(value.x, value.y, value.z)
	monster.max_health = value.health
	monster.current_health = value.health
	monster.character_name = value.name
