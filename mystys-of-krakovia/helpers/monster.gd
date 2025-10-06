extends Node

func configure_monster(monster, value, key, room):
	monster.monster_id = key
	monster.speed = value.speed
	monster.attack_damage = value.attack
	monster.get_node("Name").set_text(value.name)
	monster.position = Vector3(value.x, value.y, value.z)
	monster.spawn_position = Vector3(value.x, value.y, value.z)
	monster.room = room
	return monster
