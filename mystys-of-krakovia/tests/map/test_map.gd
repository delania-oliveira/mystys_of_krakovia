extends Node
var room
var state

func _ready():
	if Network.client:
		_on_network_ready()
	else:
		Network.connection_ready.connect(_on_network_ready)
	
func _on_network_ready():
	var room_status = await Network.join_room()
	room = room_status.get("room")
	state = room_status.get("state")
	Network.prepare_room_state(state, self)

func _on_monster_add(target, value, key):
	_spawn_monster(value, key)
	
func _on_monster_remove(monster, key):
	if has_node(key):
		get_node(key).queue_free()
	
func _spawn_monster(value, key):
	var MonsterSceneLocation = "res://tests/npcs/monsters/monster.tscn"
	var MonsterScene = load(MonsterSceneLocation)
	var monster = MonsterScene.instantiate()
	var monster_model_scene = load("res://tests/npcs/monsters/monster.glb")
	var monster_model_instance = monster_model_scene.instantiate()
	monster.get_node("Pivot").add_child(monster_model_instance)
	monster.monster_id = key
	MonsterHelper.set_monster_stats(monster, value)
	monster.room = room
	add_child(monster)
	monster.model = monster_model_instance
	value.listen(":change").on(func():
		monster.position = Vector3(value.x, value.y, value.z)
	)
	
func _on_players_add(target, value, key):
	var characterSceneLocation = "res://tests/players/player.tscn"
	var Char = load(characterSceneLocation)
	var ch = Char.instantiate()
	var model_scene = load("res://assets/character/" + value.character_class + ".glb")
	var model_instance = model_scene.instantiate()
	model_instance.transform = Transform3D.IDENTITY
	ch.get_node("Pivot").add_child(model_instance)
	ch.get_node("Target").hide()
	ch.position = Vector3(value.x, value.y, value.z)
	ch.get_node("Name").set_text(value.name)
	ch.model = model_instance
	add_child(ch)
	value.node = ch
	ch.room = room
	ch.player_key = key
	ch.character_name = value.name
	value.listen(":change").on(Callable(self, "_on_player"))
	if key == room.session_id:
		CharacterHelper.prepare_health_bar(ch, value.health, value.max_health)
		CharacterHelper.prepare_mana_bar(ch, value.mana, value.max_mana)
		ch.is_local = true
		ch.get_node("Camera3D").current = true
	else:
		ch.get_node("ManaBar").hide()
		ch.get_node("HealthBar").hide()
		ch.is_local = false
		ch.get_node("Camera3D").current = false

func _on_player(target):
	var ch = target.node
	ch.on_network_data_received(target) 
func _on_players_remove(target, value, key):
	if value.node:
		value.node.queue_free()

func prepare_health_bar(character, current_health, max_health):
	character.current_health = current_health
	character.max_health = max_health
	var health_bar = character.get_node("HealthBar/ProgressHealthBar")
	var health_label = character.get_node("HealthBar/HealthLabel")
	health_bar.max_value = max_health
	health_bar.value = current_health
	health_label.text = str(current_health) + " / " + str(max_health)
	health_bar.show_percentage = false
	
func prepare_mana_bar(character, current_mana, max_mana):
	var mana_bar = character.get_node("ManaBar/ProgressManaBar")
	var mana_label = character.get_node("ManaBar/ManaLabel")
	mana_bar.max_value = max_mana
	mana_bar.value = current_mana
	mana_label.text = str(current_mana) + " / " + str(max_mana)
	mana_bar.show_percentage = false
