extends Control
class_name ActionMenu

signal userInput(Dictionary)

var entity : CombatEntity
var partyItems : Dictionary = {}
var action_buttons : Array[Button] = []
var active_menu : int
var skillmenuitem = preload('res://scenes/combat/ui/skillmenubutton.tscn')

enum {
	ACTION,
	SKILL,
	ITEM
}

var skillCallBack = func():
	userInput.emit({'entity': entity, 'type' : Combat_Action.SKILL})


func initialize_menu(entity : CombatEntity):
	for b in %skillmenucontainer/skillmenu.get_children():
		b.queue_free()
	%skillmenucontainer.hide()
	%itemmenucontainer.hide()
	entity = entity
	#TODO: add entity skills to the container
	var skillbutton = skillmenuitem.instantiate()
	skillbutton.text = "skill"
	skillbutton.pressed.connect(skillCallBack)
	%skillmenucontainer/skillmenu.add_child(skillbutton)
	reactivate_action_select()

func deactivate_action_select():
	%actionselectcontainer.focus_mode = FOCUS_NONE
	%actionselectcontainer.release_focus()
	for b in action_buttons:
		b.mouse_filter = MOUSE_FILTER_IGNORE
		b.focus_mode = FOCUS_NONE

func reactivate_action_select(selectedButton : Button = %ATTACK):
	%actionselectcontainer.focus_mode = FOCUS_ALL
	%actionselectcontainer.grab_focus()
	for b in action_buttons:
		b.mouse_filter = MOUSE_FILTER_PASS
		b.focus_mode = FOCUS_ALL
		b.button_pressed = false
	selectedButton.grab_focus()

func _ready() -> void:
	active_menu = ACTION
	action_buttons = [%ATTACK, %SKILL, %DEFEND, %MOVE, %ITEM, %FLEE]
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
	userInput.emit({'entity': entity, 'type': Combat_Action.ATTACK})


func _on_skill_pressed() -> void:
	deactivate_action_select()
	%skillmenucontainer.show()
	%skillmenucontainer.grab_focus()
	%skillmenu.get_children()[0].grab_focus()
	active_menu = SKILL

func _on_defend_pressed() -> void:
	userInput.emit({'entity': entity, 'type': Combat_Action.DEFEND})

func _on_move_pressed() -> void:
	userInput.emit({'entity': entity, 'type': Combat_Action.MOVE})

func _on_item_pressed() -> void:
	deactivate_action_select()
	%itemmenucontainer.show()
	%itemmenucontainer.grab_focus()
	%itemmenu.get_children()[0].grab_focus()
	active_menu = ITEM

func _on_flee_pressed() -> void:
	userInput.emit({'entity': entity, 'type': Combat_Action.FLEE})
