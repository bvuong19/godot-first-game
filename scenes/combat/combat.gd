extends Node

#control flow state
enum {
	PLANNING,
	TURNSTART,
	TARGET,
	BATTLING
}

var event_queue: Array = []
var turn_queue: Array[CombatEntity] = []
var current_action = -1
var debug = true


var dmgText = preload("res://scenes/combat/damage_text.tscn")


var planning = true
var grid_selected_entity = null
var current_phase = PLANNING
var is_phase_change = true
var eventBuilder = {}
var animation_locked = false

func add_event(entity: CombatEntity, type: int, target: CombatEntity) -> void:
	event_queue.append({entity=entity, type=type, target=target})

func process_turn_queue() -> void:
	pass

func process_event_queue() -> void:
	for event in event_queue:
		process_event(event)
	event_queue = []

func process_event(event : Dictionary) -> void:
	match event.type:
		Combat_Action.ATTACK:
			# TODO: add animation callbcaks
			print(event.entity.name + " attacks " + event.targetEntity.name + " with an ATK of " + str(event.entity.atk) + "!")
			$battlefield.animate_entity_attack(event.entity, event.targetEntity, _on_battle_anim_complete)
			event.targetEntity.apply_damage(event.entity.atk)	
		Combat_Action.DEFEND:
			print(event.entity.name + " defends, raising their defense to " + str(event.entity.atk * 2) + "!")
			$battlefield.animate_entity_hop(event.entity, _on_battle_anim_complete)
		Combat_Action.MOVE:
			print(event.entity.name + " moves!")
			event.entity.x = event.target[0]
			event.entity.y = event.target[1]
			$battlefield.animate_entity_move(event.entity, event.entity.x, event.entity.y, _on_battle_anim_complete)
			#$battlefield.refresh_entity_position(event.entity, event.target[2])
			
func debug_add_events() -> void:
	#add_event($players.get_children().front(), ATTACK, $enemies.get_children().front())
	for enemy in $enemies.get_children():
		event_queue.append({'entity': enemy, 'type': Combat_Action.ATTACK, 'targetEntity': $players.get_children().front()})
		#add_event(enemy, Combat_Action.ATTACK, $players.get_children().front())

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Combat initiated with player characters: ")
	$battlefield.onSelect.connect(_on_grid_selected)
	
	for entity in $players.get_children():
		entity.damage_taken.connect(_on_damage_taken)
		print("\n" + entity.name + ' [' + str(entity.current_hp) + "/" + str(entity.hp) + "]")
		$battlefield.add_entity(entity, false)
		$combatUI.add_entity(entity, false)
	print("...and enemy characters: ")
	for entity in $enemies.get_children():
		print("\n" + entity.name + ' [' + str(entity.current_hp) + "/" + str(entity.hp) + "]")
		$battlefield.add_entity(entity, true)
		$combatUI.add_entity(entity, true)
	
	debug_add_events()

func reset_turn_queue() -> void:
	for e in $enemies.get_children():
		turn_queue.append(e)
	for p in $players.get_children():
		turn_queue.append(p)
	turn_queue.sort_custom(sort_entity_priority)
	$combatUI.initialize_turn_queue(turn_queue)
	
func sort_entity_priority(a : CombatEntity, b: CombatEntity) -> bool:
	return a.speed < b.speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	handleControlFlowChange()
	
	match current_phase:
		PLANNING:
			pass
		TURNSTART:
			pass #tbd
		TARGET:
			pass
		BATTLING:
			if not event_queue:
				current_phase = PLANNING
				is_phase_change = true
			if not animation_locked:
				$battlefield.refresh_selections()
				process_event(event_queue.pop_front())
				animation_locked = true

# callback for when battle animation is complete
func _on_battle_anim_complete() -> void:
	animation_locked = false

func _on_grid_selected(x : int, y: int, isEnemy: bool) -> void:
	if current_phase == PLANNING:
		var entity = getEntityAtPosition(x,y,false)
		if (entity):
			updateEventBuilder({'entity': entity})
	else:
		updateEventBuilder({'target': [x,y, isEnemy], 'targetEntity': getEntityAtPosition(x,y,isEnemy)})

func _on_user_input_selected(properties: Dictionary) -> void:
	updateEventBuilder(properties)

func updateEventBuilder(properties: Dictionary) -> void:
	eventBuilder.merge(properties)
	#TODO: need more logic on how to confirm
	if not eventBuilder.has('entity'):
		return
	if not eventBuilder.has('type'):
		current_phase = TURNSTART
		is_phase_change = true
		return
	match eventBuilder['type']:
		Combat_Action.ATTACK:
			if eventBuilder.has('targetEntity') and eventBuilder['targetEntity']:
				current_phase = BATTLING
				is_phase_change = true
				event_queue.append(eventBuilder)
				eventBuilder = {}
			else:
				current_phase = TARGET
				$battlefield.is_select_enemy = true
				is_phase_change = true
		Combat_Action.DEFEND:
			current_phase = BATTLING
			event_queue.append(eventBuilder)
			eventBuilder = {}
		Combat_Action.FLEE:
			current_phase = BATTLING
			event_queue.append(eventBuilder)
			eventBuilder = {}
		Combat_Action.MOVE:
			if eventBuilder.has('target') and eventBuilder['target']:
				# check valid location
				if not getEntityAtPosition(eventBuilder['target'][0], eventBuilder['target'][1], eventBuilder['target'][2]):
					current_phase = BATTLING
					event_queue.append(eventBuilder)
					eventBuilder = {}
					is_phase_change = true
					return
				# invalid location
				else:
					eventBuilder.erase('target')
			# selected character to move, but no target
			is_phase_change = true
			current_phase = TARGET
			$battlefield.is_select_enemy = false

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

func handleControlFlowChange():
	#	show and hide UI elements depending on phase of control flow
	if is_phase_change:
		print("now in "+ str(current_phase) + "!")
		match current_phase:
			PLANNING:
				$combatUI.release_focus()
				$combatUI.make_inactive()
				$battlefield.grab_focus()
				$battlefield.is_select_enemy = false
			TURNSTART:
				$combatUI.make_active(eventBuilder['entity'])
				$battlefield.release_focus()
			TARGET:
				$combatUI.release_focus()
				$battlefield.grab_focus()
			BATTLING:
				$combatUI.make_inactive()
				$combatUI.reset()
				$combatUI.release_focus()
				$battlefield.release_focus()
				
		is_phase_change = false

func _on_damage_taken(entity : CombatEntity, dmg : int) -> void:
	$combatUI.update_party_bar()
	$combatUI.dmg_text(entity, dmg)
