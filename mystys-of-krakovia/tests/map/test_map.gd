extends Node
var room
var state
@onready var party_ui = preload("res://tests/players/ui/PartyUI.tscn")

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
	var monster_model_scene
	var path = "res://assets/monsters/" + value.name.to_lower().replace(" ", "_") + ".glb"
	if ResourceLoader.exists(path):
		monster_model_scene = load(path)
	else:
		monster_model_scene = load("res://tests/npcs/monsters/monster.glb")
	var monster_model_instance = monster_model_scene.instantiate()
	monster.get_node("Pivot").add_child(monster_model_instance)
	monster.id = key
	MonsterHelper.set_monster_stats(monster, value)
	monster.room = room
	monster.get_node("AggroArea/CollisionShape3D").shape.radius = value.detectionRange
	if value.detectionRange != 0:
		monster.is_aggressive = true
	monster.position = Vector3(value.x, value.y, value.z)
	monster.spawn_position = Vector3(value.x, value.y, value.z)
	monster.network_position = Vector3(value.x, value.y, value.z)
	monster.network_animation = "Idle"
	monster.attack_range = value.attackRange
	add_child(monster)
	monster.model = monster_model_instance
	value.listen(":change").on(Callable(self, "_on_monster").bind(monster))
	room.on_message("set_monster_loot").on(Callable(monster, "_on_set_monster_loot"))
	room.on_message("rangedAttack").on(Callable(monster, "_on_ranged_attack"))
	
func _on_monster(changes, monster_instance):
	if not is_instance_valid(monster_instance):
		return
	monster_instance.network_position = Vector3(changes.x, 2, changes.z)
	monster_instance.is_targeting = changes.isTargeting
	monster_instance.target_id = changes.targetId
	monster_instance.is_attacking = changes.isAttacking
	monster_instance.current_health = changes.health
	if changes.animation:
		monster_instance.network_animation = changes.animation
	if changes.isDead:
		var timer = Timer.new()
		timer.wait_time = 0.25
		timer.one_shot = true
		timer.timeout.connect(monster_instance.queue_free)
		add_child(timer)
		timer.start()

func _on_players_add(target, value, key):
	var characterSceneLocation = "res://tests/players/Player.tscn"
	var Char = load(characterSceneLocation)
	var ch = Char.instantiate()
	var model_scene = load("res://assets/character/" + value.character_class.replace(" ", "_") + ".glb")
	var model_instance = model_scene.instantiate()
	model_instance.transform = Transform3D.IDENTITY
	ch.get_node("Pivot").add_child(model_instance)
	ch.position = Vector3(value.x, value.y, value.z)
	ch.get_node("Name").set_text(value.name)
	ch.model = model_instance
	add_child(ch)
	value.node = ch
	ch.room = room
	ch.id = key
	ch.name = key
	ch.character_name = value.name
	ch.current_health = value.health
	ch.current_mana = value.mana
	ch.max_mana = value.max_mana
	ch.current_gold = 0
	ch.defense = value.defense
	ch.attack = value.attack
	ch.max_health = value.max_health
	ch.character_class = value.character_class
	ch.get_node("Target").hide()
	value.listen(":change").on(Callable(self, "_on_player"))
	if key == room.session_id:
		room.on_message("set_skills").on(Callable(ch, "_on_set_skills"))
		room.on_message("looted_item").on(Callable(ch, "_on_looted_item"))
		room.on_message("skillFail").on(Callable(ch, "_on_skill_fail"))
		room.on_message("playerTargetHealthUpdate").on(Callable(ch, "_on_target_health_update"))
		room.on_message("playerAttack").on(Callable(ch, "_on_player_attack"))
		room.on_message("resistDamage").on(Callable(ch, "_on_resist_damage"))
		room.on_message("damageDealt").on(Callable(ch, "_on_damage_dealt"))
		room.on_message("experienceGained").on(Callable(ch, "_on_experience_gained"))
		room.on_message("partyMemberLevelUp").on(Callable(ch, "_on_party_member_level_up"))
		room.on_message("partyInvite").on(Callable(ch, "_on_party_invite"))
		room.on_message("setPartyTarget").on(Callable(ch, "_on_set_party_target"))
		room.on_message("partyJoined").on(Callable(ch, "_on_party_joined"))
		room.on_message("inviteFail").on(Callable(ch, "_on_invite_fail"))
		room.on_message("partyHealthUpdate").on(Callable(ch, "_on_party_health_update"))
		room.on_message("leaveParty").on(Callable(ch, "_on_party_leave"))
		ch.get_node("Inventory/HBoxContainer/InventoryItems/Gold/TextureRect/GoldAmount").text = "Gold: " + str(value.gold)
		ch.get_node("Inventory/PlayerStats").text = "⚔️ " + str(value.attack) + "🛡️ " + str(value.defense)
		CharacterHelper.prepare_health_bar(ch, value.health, value.max_health)
		CharacterHelper.prepare_mana_bar(ch, value.mana, value.max_mana)
		CharacterHelper.prepare_experience_bar(ch, value.experience, value.level, value.max_exp)
		ch.is_local = true
		ch.get_node("Camera3D").current = true
		var spellbook = ch.get_node("SpellBook")
		var action_bar = ch.get_node("ActionBar")
		var inventory = ch.get_node("Inventory")
		inventory.hide()
		action_bar.player = ch
		inventory.player = ch
		ch.skills_updated.connect(spellbook.display_player_skills)
		spellbook.hide()
		ch.get_node("PlayerMenu").hide()
		ch.get_node("CastBar").visible = false
	else:
		CharacterHelper.setup_remote_player(ch)
	
func _on_player(target):
	var ch = target.node
	ch.on_network_data_received(target) 
	
func _on_players_remove(target, value, key):
	if value.node:
		value.node.queue_free()
