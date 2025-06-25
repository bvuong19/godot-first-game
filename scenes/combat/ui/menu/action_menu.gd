extends Control
class_name ActionMenu

signal userInput(Dictionary)

var entity : CombatEntity
var partyItems : Dictionary = {}
#var action_buttons : Array[Button] = []
var action_buttons : Dictionary = {}
var active_menu : int
var skillmenuitem = preload('res://scenes/combat/ui/menu/skill_menu_button.tscn')

enum {
	ACTION,
	SKILL,
	ITEM
}

var skillCallBack = func(skill : CombatAction):
	userInput.emit({'entity': entity, 'action' : skill})


func initialize_menu(entity : CombatEntity):
	self.entity = entity
	for b in %skillmenucontainer/skillmenu.get_children():
		b.queue_free()
	%skillmenucontainer.hide()
	%itemmenucontainer.hide()

	for button in action_buttons.values():
		button.disabled = true
	for actionType in entity.effective_stats.get('actions', entity.actions):
		action_buttons[actionType].disabled = false
		
	for skill in entity.skills:
		var isDisabled = skill.skillCostType and entity.current_mp < skill.skillCost
		var skillButton = SkillMenuItem.from_skill(skill, isDisabled)
		skillButton.pressed.connect(skillCallBack.bind(skillButton.skill))
		%skillmenucontainer/skillmenu.add_child(skillButton)
		
	reactivate_action_select()

func deactivate_action_select():
	%actionselectcontainer.focus_mode = FOCUS_NONE
	%actionselectcontainer.release_focus()
	for b in action_buttons.values():
		b.mouse_filter = MOUSE_FILTER_IGNORE
		b.focus_mode = FOCUS_NONE

func reactivate_action_select(selectedButton : Button = %ATTACK):
	%actionselectcontainer.focus_mode = FOCUS_ALL
	%actionselectcontainer.grab_focus()
	for b in action_buttons.values():
		b.mouse_filter = MOUSE_FILTER_PASS
		b.focus_mode = FOCUS_ALL
		b.button_pressed = false
	selectedButton.grab_focus()

func _ready() -> void:
	active_menu = ACTION
	action_buttons[CombatDetail.ACTION_TYPE.ATTACK] = %ATTACK
	action_buttons[CombatDetail.ACTION_TYPE.SKILL] = %SKILL
	action_buttons[CombatDetail.ACTION_TYPE.DEFEND] = %DEFEND
	action_buttons[CombatDetail.ACTION_TYPE.MOVE] = %MOVE
	action_buttons[CombatDetail.ACTION_TYPE.ITEM] = %ITEM
	action_buttons[CombatDetail.ACTION_TYPE.FLEE] = %FLEE
	#action_buttons = [%ATTACK, %SKILL, %DEFEND, %MOVE, %ITEM, %FLEE]
	reactivate_action_select()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		match active_menu:
			SKILL:
				%skillmenucontainer.hide()
				reactivate_action_select(%SKILL)
			ITEM:
				%itemmenucontainer.hide()
				reactivate_action_select(%ITEM)
	
func _on_attack_pressed() -> void:
	userInput.emit({'entity': entity, 'action': preload("res://scenes/combat/skills/basic_actions_list/attack.gd").new()})

func _on_skill_pressed() -> void:
	deactivate_action_select()
	%skillmenucontainer.show()
	%skillmenucontainer.grab_focus()
	for child in %skillmenu.get_children():
		if not child.disabled:
			child.grab_focus()
			break
	active_menu = SKILL

func _on_defend_pressed() -> void:
	userInput.emit({'entity': entity, 'action' : preload("res://scenes/combat/skills/basic_actions_list/defend.gd").new()})

func _on_move_pressed() -> void:
	userInput.emit({'entity': entity, 'action': preload("res://scenes/combat/skills/basic_actions_list/move.gd").new()})

func _on_item_pressed() -> void:
	deactivate_action_select()
	%itemmenucontainer.show()
	%itemmenucontainer.grab_focus()
	%itemmenu.get_children()[0].grab_focus()
	active_menu = ITEM

func _on_flee_pressed() -> void:
	userInput.emit({'entity': entity, 'type': CombatDetail.ACTION_TYPE.FLEE})
