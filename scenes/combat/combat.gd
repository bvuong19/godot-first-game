extends Node

#control flow state
enum {
	PLANNING,
	TURNSTART,
	TARGET,
	BATTLING
}

var event_queue: Array = []
var current_action = -1
var debug = true


var dmgText = preload("res://scenes/combat/damage_text.tscn")


var planning = true
var grid_selected_entity = null
var current_phase = PLANNING
var is_phase_change = true
var eventBuilder = {}

func add_event(entity: CombatEntity, type: int, target: CombatEntity) -> void:
	event_queue.append({entity=entity, type=type, target=target})
	pass

func process_event_queue() -> void:
	for event in event_queue:
		process_event(event)
	event_queue = []

func process_event(event : Dictionary) -> void:
	match event.type:
		Combat_Action.ATTACK:
			print(event.entity.name + " attacks " + event.targetEntity.name + " with an ATK of " + str(event.entity.atk) + "!")
			event.targetEntity.apply_damage(event.entity.atk)
		Combat_Action.DEFEND:
			print(event.entity.name + " defends, raising their defense to " + str(event.entity.atk * 2) + "!")
		Combat_Action.MOVE:
			print(event.entity.name + " moves!")
			event.entity.x = event.target[0]
			event.entity.y = event.target[1]
			$battlefield.refresh_entity_position(event.entity, event.target[2])
			
func debug_add_events() -> void:
	#add_event($players.get_children().front(), ATTACK, $enemies.get_children().front())
	for enemy in $enemies.get_children():
		event_queue.append({'entity': enemy, 'type': Combat_Action.ATTACK, 'targetEntity': $players.get_children().front()})
		#add_event(enemy, Combat_Action.ATTACK, $players.get_children().front())

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

	handleControlFlowChange()
	
	match current_phase:
		PLANNING:
			pass
		TURNSTART:
			pass #tbd
		TARGET:
			pass
		BATTLING:
			$battlefield.refresh_selections()
			print("we battlin")
			process_event_queue()
			current_phase = PLANNING
			is_phase_change = true
			debug_add_events()
			
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
	print(eventBuilder)
	print(properties)
	eventBuilder.merge(properties)
	print(eventBuilder)
	#TODO: need more logic on how to confirm
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
			print("we move")
			if eventBuilder.has('target') and eventBuilder['target']:
				current_phase = BATTLING
				event_queue.append(eventBuilder)
				eventBuilder = {}
			else:
				current_phase = TARGET
				$battlefield.is_select_enemy = false
			is_phase_change = true
		

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
				$combatUI.hide()
				$battlefield.grab_focus()
				$battlefield.is_select_enemy = false
			TURNSTART:
				$combatUI.make_active(eventBuilder['entity'])
				$battlefield.release_focus()
			TARGET:
				$combatUI.release_focus()
				$battlefield.grab_focus()
			BATTLING:
				$combatUI.hide()
				$combatUI.reset()
				$combatUI.release_focus()
				$battlefield.release_focus()
				
		is_phase_change = false

func _on_damage_taken(entity : CombatEntity, dmg : int) -> void:
	$combatUI.dmg_text(entity, dmg)
