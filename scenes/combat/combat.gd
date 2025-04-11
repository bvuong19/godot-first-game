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
signal turn_queue_updated(Array)
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
	var e : CombatEntity = turn_queue[0]
	e.on_turn_start()
	turn_queue_updated.emit(turn_queue)
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
		process_turn_queue()

func process_event(event : Dictionary) -> void:
	event['battlefield'] = $battlefield
	match event.type:
		Combat_Action.ATTACK:
			# TODO: add animation callbcaks
			print(event.entity.name + " attacks " + event.targetEntity.name + " with an ATK of " + str(event.entity.atk) + "!")
			$battlefield.animate_entity_attack(event.entity, event.targetEntity, _on_battle_anim_complete)
			event.targetEntity.apply_damage(event.entity.atk, Combat_Detail.DAMAGE_TYPE.PHYSICAL)
		Combat_Action.DEFEND:
			var entity : CombatEntity = event.entity
			var guard_status = preload('res://scenes/combat/status/status_list/status_guarding.gd').new()
			print(guard_status)
			entity.apply_status(guard_status, 1)
			guard_status.apply_effect(entity)
			$battlefield.animate_entity_hop(event.entity, _on_battle_anim_complete)
			print(event.entity.name + " defends, raising their defense to " + str(entity.effective_stats.get('def', entity.def)) + "!")
		Combat_Action.MOVE:
			print(event.entity.name + " moves!")
			event.entity.x = event.targetPosition[0]
			event.entity.y = event.targetPosition[1]
			$battlefield.animate_entity_move(event.entity, event.entity.x, event.entity.y, _on_battle_anim_complete)
		Combat_Action.SKILL:
			print(event.entity.name + " casts the %s skill!" % event['skillDetail'].skillName)
			event.callback = _on_battle_anim_complete
			event['skillDetail'].play_skill(event)
			
# Called when grid selected. Provides the eventBuilder with the following fields:
# targetPosition: the targeted position selected explicitly by the player cursor
# targetTiles: targeted tiles covered by an AoE, if the player was targeting an AoE skill.
# targetGridTiles: targeted tiles covered by an AoE, if the player was targeting an AoE skill.
# isEnemy
func _on_grid_selected(targetPosition : Vector2, targetTiles : Array[Vector2i], isEnemy : bool) -> void:
	var properties = {'targetGridTiles': [], 'targetEntities' : [], 'targetPosition' : targetPosition, 'targetTiles': targetTiles}
	
	for tile in targetTiles:
		var tileEntity = getEntityAtPosition(tile.x, tile.y, isEnemy)	
		if tileEntity: 
			properties.targetEntities.append(tileEntity)
		properties.targetGridTiles.append($battlefield.get_tile(tile.x,tile.y, isEnemy))
	
	print("getting enemy at %s" % targetPosition)
	var cursorEntity = getEntityAtPosition(targetPosition[0], targetPosition[1], isEnemy)
	print("found %s" % cursorEntity)
	if cursorEntity:
		properties['targetEntity'] = cursorEntity
		
	updateEventBuilder(properties)
	
func _on_grid_cancel() -> void:
	eventBuilder = { 'entity': eventBuilder.entity }
	$battlefield.refresh_selections()
	updateEventBuilder({})

func _on_user_input_selected(properties: Dictionary) -> void:
	updateEventBuilder(properties)

# The eventBuilder contains the action that the user is planning.
# entity: the CombatEntity making the move
# type: the type of action that the user is taking.
# targetEntity: for single-target actions, a targeted entity
# targetPosition: a targeted tile
# targetTiles: targeted tiles covered by an AoE, if the player was targeting an AoE skill.
# targetEntities: all entities within targetTiles, if the player was targeting an AoE skill.
# skillDetail: details for the skill. Refer to combat_skill.gd for more info
func updateEventBuilder(properties: Dictionary) -> void:
	eventBuilder.merge(properties)
	#TODO: need more logic on how to confirm
	if not eventBuilder.has('entity'):
		return
	$battlefield.highlight_entity(eventBuilder['entity'])
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
			elif (skillDetail.targetType in [CombatSkillDetail.TARGET_TYPE.ALLY_RANGE, CombatSkillDetail.TARGET_TYPE.ENEMY_RANGE]) and eventBuilder.has('targetTiles') and eventBuilder['targetTiles']:
				$battlefield.targetRange = null
				event_queue.append(eventBuilder)
				change_phase(BATTLING)
			# 3: needs target
			else:
				$battlefield.is_select_enemy = skillDetail.targetType in [CombatSkillDetail.TARGET_TYPE.ENEMY, CombatSkillDetail.TARGET_TYPE.ENEMY_RANGE]
				if skillDetail.targetRange:
					$battlefield.targetRange = skillDetail.targetRange
				change_phase(TARGET)
				
		Combat_Action.DEFEND:
			change_phase(BATTLING)
			event_queue.append(eventBuilder)
		Combat_Action.FLEE:
			change_phase(BATTLING)
			event_queue.append(eventBuilder)
		Combat_Action.MOVE:
			if eventBuilder.has('targetPosition') and eventBuilder['targetPosition']:
				# check valid location
				if not getEntityAtPosition(eventBuilder['targetPosition'].x, eventBuilder['targetPosition'].y, eventBuilder['entity'].isEnemy):
					event_queue.append(eventBuilder)
					change_phase(BATTLING)
				# invalid location
				else:
					eventBuilder.erase('targetPosition')
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
	turn_queue_updated.connect($combatUI.on_turn_queue_change)

	for entity in $combatants.get_children():
		entity.damage_taken.connect(_on_damage_taken)
		entity.entity_death.connect(_on_entity_death)
		
	for entity in get_players():
		print("\n" + entity.name + ' [' + str(entity.current_hp) + "/" + str(entity.hp) + "]")
		$battlefield.add_entity(entity, false)
		$combatUI.add_entity(entity, false)
		entity.skills.append(load("res://scenes/combat/skills/skills_list/heal.tres"))
		entity.skills.append(load("res://scenes/combat/skills/skills_list/fire_t1.tres"))
		entity.skills.append(load("res://scenes/combat/skills/skills_list/fire_t2.tres"))
		#entity.skills.append(SKILLS.Fire)
		
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
	#$combatUI.turn_queue_remove(entity)
	turn_queue.erase(entity)
	entity.queue_free()
	turn_queue_updated.emit(turn_queue)
	
	
