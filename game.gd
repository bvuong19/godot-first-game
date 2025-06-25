extends Control

func _ready() -> void:
	add_combat()
	
func _on_combat_ended(combat : Node) -> void:
	remove_child(combat)
	combat.queue_free()
	print('combat ended')
	
func add_combat() -> void:
	var combatants : Array[CombatEntity] = []
	var player = CombatEntity.from_character(preload("res://scenes/combat/character/default_player_character.tres"))
	player.x = 2
	player.y = 2
	var jf = CombatEntity.from_character(preload("res://scenes/combat/character/default_enemy.tres"))
	jf.x = 0
	jf.y = 1
	jf.is_enemy = true
	#var jf2 = CombatEntity.from_character(preload("res://scenes/combat/character/default_enemy.tres"))
	#jf2.x = 3
	#jf2.y = 1
	#jf2.is_enemy = true
	var combat = Combat3D.init([player, jf])
	add_child(combat)
	combat.end_combat.connect(_on_combat_ended.bind(combat))
	print('added new combat scene')

func _process(delta: float) -> void:
	pass
