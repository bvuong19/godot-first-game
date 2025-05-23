extends Control

var activeCombatEntity = null
signal userInput(Dictionary)

var damagetext = preload('res://scenes/combat/ui/damage_text.tscn')
var partyBarItem = preload('res://scenes/combat/ui/menu/party_bar.tscn')
var buttons = ['%ATTACK', '%SKILL', '%DEFEND', '%MOVE', '%ITEM', '%FLEE']

func initialize_turn_queue_bar(turn_queue : Array[CombatEntity]) -> void:
	for c in %turnqueue.get_children():
		%turnqueue.remove_child(c)
		c.queue_free()
	for e in turn_queue:
		var turnqueuechild = TextureRect.new()
		turnqueuechild.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		turnqueuechild.size = Vector2(40,40)
		turnqueuechild.texture = e.headSprite
		%turnqueue.add_child(turnqueuechild)

func on_turn_queue_change(turn_queue : Array[CombatEntity]) -> void:
	initialize_turn_queue_bar(turn_queue)
	#for party : PartyBarItem in $partybarcontainer/partybar.get_children():
		#if turn_queue[0] == party.entity:
			#party.set_active(true)
		#else:
			#party.set_active(false)

func add_entity(entity : CombatEntity, isEnemy: bool) -> void:
	if not isEnemy:
		var item = PartyBar.from_Entity(entity)
		$partybarcontainer/partybar.add_child(item)
		item.refresh()
	
func update_party_bar() -> void:
	for party_member_ui in %partybar.get_children():
		print('refreshing')
		party_member_ui.refresh()

func dmg_text(entity: CombatEntity, post_mit_dmg: int) -> void:
	var dmgTextLabel = damagetext.instantiate()
	dmgTextLabel.set_damage(post_mit_dmg)
	entity.add_child(dmgTextLabel)

func make_active(entity : CombatEntity) -> void:
	$actionmenu.show()
	$actionmenu.get_node('%ATTACK').grab_focus()
	activeCombatEntity = entity
	$actionmenu.initialize_menu(entity)
	$EntityMenu.add_entity(entity)
	$EntityMenu.show()

func make_inactive() -> void:
	$actionmenu.release_focus()
	$actionmenu.hide()
	$EntityMenu.hide()
	
func reset() -> void:
	for b in buttons:
		$actionmenu.get_node(b).set_pressed(false)
