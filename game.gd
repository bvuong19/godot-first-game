extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#add_child(preload("res://scenes/combat/combat_3d.tscn").instantiate())
	pass
	
	
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
	
	print('huh')
	var combat = Combat3D.init([player, jf])
	add_child(combat)
	combat.end_combat.connect(_on_combat_ended.bind(combat))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
