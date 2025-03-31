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
var debug = true


var dmgText = preload("res://scenes/combat/ui/damage_text.tscn")

var current_phase = BATTLING
var is_phase_change = true
var eventBuilder = {}
var animation_locked = false

func add_event(entity: CombatEntity, type: int, target: CombatEntity) -> void:
	event_queue.append({entity=entity, type=type, target=target})

func process_turn_queue() -> void:
	if not turn_queue:
		reset_turn_queue()
	eventBuilder = {}
	var e = turn_queue[0]
	if e.isEnemy:
		# TODO: more support for enemy actions. Currently we just let them attack.
		event_queue.append({'entity': e, 'type': Combat_Action.ATTACK, 'targetEntity': get_players().front()})
		change_phase(BATTLING)
	else:
		# start player turn
		updateEventBuilder({'entity': e})
		change_phase(TURNSTART)

func reset_turn_queue() -> void:
	for c in $combatants.get_children():
		turn_queue.append(c)
	turn_queue.sort_custom(sort_entity_priority)
	$combatUI.initialize_turn_queue(turn_queue)
	
func sort_entity_priority(a : CombatEntity, b: CombatEntity) -> bool:
	return a.spd > b.spd

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	if current_phase == BATTLING:
		if not animation_locked and event_queue:
			eventBuilder = {}
			$battlefield.refresh_selections()
			if event_queue:
				process_event(event_queue.pop_front())
			animation_locked = true

# callback for when battle animation is complete
func _on_battle_anim_complete() -> void:
	animation_locked = false
	if not event_queue:
		turn_queue.pop_front()
		$combatUI.next_turn_queue()
		process_turn_queue()

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
		Combat_Action.SKILL:
			print(event.entity.name + " casts the %s skill!" % event['skillDetail'].skillName)
			#func animate_entity_spell(entity : CombatEntity, skillName : String, callback : Callable) -> void:
			$battlefield.animate_entity_spell(event['targetEntity'], event['skillDetail'].skillName, _on_battle_anim_complete)
			#event.targetEntity.apply_damage(event.entity.atk*2)
			event['skillDetail'].apply_effect.call(event.entity, event.targetEntity)
			
func _on_grid_selected(x : int, y: int, isEnemy: bool) -> void:
	updateEventBuilder({'target': [x,y, isEnemy], 'targetEntity': getEntityAtPosition(x,y,isEnemy)})

func _on_grid_cancel() -> void:
	eventBuilder = { 'entity': eventBuilder.entity }
	$battlefield.refresh_selections()
	updateEventBuilder({})

func _on_user_input_selected(properties: Dictionary) -> void:
	updateEventBuilder(properties)

func updateEventBuilder(properties: Dictionary) -> void:
	eventBuilder.merge(properties)
	#TODO: need more logic on how to confirm
	if not eventBuilder.has('entity'):
		return
	if not eventBuilder.has('type'):
		change_phase(TURNSTART)
		return
	match eventBuilder['type']:
		Combat_Action.ATTACK:
			if eventBuilder.has('targetEntity') and eventBuilder['targetEntity']:
				event_queue.append(eventBuilder)
				change_phase(BATTLING)
			else:
				$battlefield.is_select_enemy = true
				change_phase(TARGET)
		Combat_Action.SKILL:
			# should check targeting type.
			# 1: does not need targeting
			var skillDetail : CombatSkill = eventBuilder['skillDetail']
			if (skillDetail.targetType in [CombatSkillDetail.TARGET_TYPE.NONE, CombatSkillDetail.TARGET_TYPE.SELF, CombatSkillDetail.TARGET_TYPE.GLOBAL]):
				event_queue.append(eventBuilder)
				change_phase(BATTLING)
			# 2: has target
			# 2a: targets a unit
			elif (skillDetail.targetType in [CombatSkillDetail.TARGET_TYPE.ALLY, CombatSkillDetail.TARGET_TYPE.ENEMY]) and eventBuilder.has('targetEntity') and eventBuilder['targetEntity']:
				event_queue.append(eventBuilder)
				change_phase(BATTLING)
			# 2b: targets an area
			elif (skillDetail.targetType in [CombatSkillDetail.TARGET_TYPE.ALLY_RANGE, CombatSkillDetail.TARGET_TYPE.ENEMY_RANGE]) and eventBuilder.has('target') and eventBuilder['target']:
				event_queue.append(eventBuilder)
				change_phase(BATTLING)
			# 3: needs target
			else:
				$battlefield.is_select_enemy = skillDetail.targetType in [CombatSkillDetail.TARGET_TYPE.ENEMY, CombatSkillDetail.TARGET_TYPE.ENEMY_RANGE]
				change_phase(TARGET)
				
		Combat_Action.DEFEND:
			change_phase(BATTLING)
			event_queue.append(eventBuilder)
		Combat_Action.FLEE:
			change_phase(BATTLING)
			event_queue.append(eventBuilder)
		Combat_Action.MOVE:
			if eventBuilder.has('target') and eventBuilder['target']:
				# check valid location
				if not getEntityAtPosition(eventBuilder['target'][0], eventBuilder['target'][1], eventBuilder['target'][2]):
					event_queue.append(eventBuilder)
					change_phase(BATTLING)
				# invalid location
				else:
					eventBuilder.erase('target')
			else:
				$battlefield.is_select_enemy = false
				change_phase(TARGET)

func change_phase(new_phase : int):
	#	show and hide UI elements depending on phase of control flow
	match new_phase:
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
	current_phase = new_phase

func getEntityAtPosition(x: int, y: int, isEnemy: bool) -> CombatEntity:
	if not isEnemy:
		for player in get_players():
			if player.x == x and player.y == y:
				return player
	else:
		for enemy in get_enemies():
			if enemy.x == x and enemy.y == y:
				return enemy
	return null

func get_enemies() -> Array[CombatEntity]:
	var result : Array[CombatEntity] = []
	for c in $combatants.get_children():
		if c.isEnemy:
			result.append(c)
	return result
	
func get_players() -> Array[CombatEntity]:
	var result : Array[CombatEntity] = []
	for c in $combatants.get_children():
		if !c.isEnemy:
			result.append(c)
	return result
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Combat initiated with player characters: ")
	$battlefield.onSelect.connect(_on_grid_selected)
	$battlefield.onCancel.connect(_on_grid_cancel)
	$combatUI/actionmenu.userInput.connect(_on_user_input_selected)

	for entity in $combatants.get_children():
		entity.damage_taken.connect(_on_damage_taken)
		entity.entity_death.connect(_on_entity_death)
		
	for entity in get_players():
		print("\n" + entity.name + ' [' + str(entity.current_hp) + "/" + str(entity.hp) + "]")
		$battlefield.add_entity(entity, false)
		$combatUI.add_entity(entity, false)
		entity.skills.append(SKILLS.Heal)
		entity.skills.append(SKILLS.Fire)
		
	print("...and enemy characters: ")
	for entity in get_enemies():
		print("\n" + entity.name + ' [' + str(entity.current_hp) + "/" + str(entity.hp) + "]")
		$battlefield.add_entity(entity, true)
		$combatUI.add_entity(entity, true)
	process_turn_queue()
	
func _on_damage_taken(entity : CombatEntity, dmg : int) -> void:
	if not entity.isEnemy:
		$combatUI.update_party_bar()
	$combatUI.dmg_text(entity, dmg)
	
func _on_entity_death(entity : CombatEntity) -> void:
	turn_queue.erase(entity)
	entity.queue_free()
	$combatants.remove_child(entity)
	
