extends Node

enum {
	ATTACK,
	DEFEND,
	OTHER
}

var event_queue: Array = []
var current_action = -1
var debug = true


var selected_tile = null
var selected_tile_is_enemy = false
var selected_ally = null
var selected_enemy = null


var planning = true

var dmgText = preload("res://scenes/combat/damage_text.tscn")

func add_event(entity: CombatEntity, type: int, target: CombatEntity) -> void:
	event_queue.append({entity=entity, type=type, target=target})
	pass

func process_event_queue() -> void:
	for event in event_queue:
		process_event(event.entity, event.type, event.target)
	event_queue = []

func process_event(entity: CombatEntity, type: int, target: CombatEntity) -> void:
	match type:
		ATTACK:
			print(entity.name + " attacks " + target.name + " with an ATK of " + str(entity.atk) + "!")
			target.apply_damage(entity.atk)


func debug_add_events() -> void:
	#add_event($players.get_children().front(), ATTACK, $enemies.get_children().front())
	for enemy in $enemies.get_children():
		add_event(enemy, ATTACK, $players.get_children().front())

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Combat initiated with player characters: ")
	for entity in $players.get_children():
		print("\n" + entity.name + ' [' + str(entity.current_hp) + "/" + str(entity.hp) + "]")
		$battlefield.add_entity(entity, false)
	print("...and enemy characters: ")
	for entity in $enemies.get_children():
		print("\n" + entity.name + ' [' + str(entity.current_hp) + "/" + str(entity.hp) + "]")
		$battlefield.add_entity(entity, true)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if planning:
		var selected_grid = $battlefield/enemygrid if selected_tile_is_enemy else $battlefield/playergrid 
		if not selected_tile:
			selected_tile = [0,0]
			selected_grid.select_tile(selected_tile[0], selected_tile[1])
		
		var tile_changed = true
		var new_tile = [0.0]
		if Input.is_action_just_pressed("left"):
			new_tile = [max(0, selected_tile[0] - 1), selected_tile[1]] 
		elif Input.is_action_just_pressed("right"):
			new_tile = [min(selected_grid.w - 1, selected_tile[0] + 1), selected_tile[1]]
		elif Input.is_action_just_pressed("down"):
			new_tile = [selected_tile[0], min(selected_grid.h - 1, selected_tile[1] + 1)]
		elif Input.is_action_just_released("up"):
			new_tile = [selected_tile[0], max(0, selected_tile[1] - 1)]
		else:
			tile_changed = false
		if tile_changed:
			selected_grid.unselect_tile(selected_tile[0], selected_tile[1])
			selected_tile = new_tile
			selected_grid.select_tile(new_tile[0], new_tile[1])
		
		if Input.is_action_just_pressed("confirm"):
			if not selected_tile_is_enemy:
				selected_ally = getEntityAtPosition(selected_tile[0], selected_tile[1], false)
				
				if selected_ally:
					# record the selected ally tile and start selecting enemy
					selected_grid.confirm_tile(selected_tile[0], selected_tile[1])
					selected_tile_is_enemy = true
					selected_tile = []
				
			else:
				selected_enemy = getEntityAtPosition(selected_tile[0], selected_tile[1], true)
				if selected_enemy:
					$battlefield/playergrid.unselect_tile(selected_ally.x, selected_ally.y)
					selected_grid.unselect_tile(selected_tile[0], selected_tile[1])
					planning = false
					selected_tile_is_enemy=false
					selected_tile=[]
					add_event(selected_ally, ATTACK, selected_enemy)
					debug_add_events()
	else:
		process_event_queue()

		planning = true

func getEntityAtPosition(x: int, y: int, isEnemy: bool) -> CombatEntity:
	if not isEnemy:
		for player in $players.get_children():
			if player.x == x and player.y == y:
				return player
	else:
		for enemy in $enemies.get_children():
			if enemy.x == x and enemy.y == y:
				return enemy
	return null


func _on_damage_taken(entity : CombatEntity, dmg : int) -> void:
	$combatUI.dmg_text(entity, dmg)
