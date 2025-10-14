extends Node

func set_monster_stats(monster, value):
	monster.speed = value.speed
	monster.get_node("Name").set_text(value.name)
	monster.max_health = value.max_health
	monster.current_health = value.health
	monster.character_name = value.name
	monster.defense = value.defense
	monster.difficulty = value.difficulty
