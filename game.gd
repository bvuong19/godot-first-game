extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#add_child(preload("res://scenes/combat/combat_3d.tscn").instantiate())
	var combatants : Array[CombatEntity] = []
	var player = CombatEntity.from_character(preload("res://scenes/combat/character/default_player_character.tres"))
	player.x = 2
	player.y = 2
	var jf = CombatEntity.from_character(preload("res://scenes/combat/character/default_enemy.tres"))
	jf.x = 0
	jf.y = 1
	jf.is_enemy = true
	var jf2 = CombatEntity.from_character(preload("res://scenes/combat/character/default_enemy.tres"))
	jf2.x = 3
	jf2.y = 1
	jf2.is_enemy = true
	
	print('huh')
	var combat = Combat3D.init([player, jf, jf2])
	add_child(combat)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("confirm"):
		#if not $Combat.event_queue:
			#$Combat.debug_add_events()
		#else:
			#$Combat.process_event_queue()
	pass
