extends Control

class_name PartyBar

const scene : PackedScene = preload("res://scenes/combat/ui/partybaritem3.tscn")
var entity : CombatEntity

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_active(false)
	pass # Replace with function body.

func updateHP() -> void:
	if entity:
		%hplabel.text = "%d / %d" % [entity.current_hp, entity.hp]
		%hpbar.value = entity.current_hp
		%hpbar.min_value = 0
		%hpbar.max_value = entity.hp

func set_active(active : bool) -> void:
	pass
	#if active:
		#%partybarpanel.theme_type_variation = 'Panel_active'
		#%namelabel.theme_type_variation = 'Label_active'
		#%hplabel.theme_type_variation = 'Label_active'
		#%profilePanelActive.show()
	#else:
		#%partybarpanel.theme_type_variation = ''
		#%namelabel.theme_type_variation = ''
		#%hplabel.theme_type_variation = ''
		#%profilePanelActive.hide()

static func from_Entity(entity : CombatEntity) -> PartyBar:
	var node : PartyBar = scene.instantiate()
	node.entity = entity
	node.get_node("%nametag").text = '[b][i]%s' % entity.name
	node.get_node("%hpbar").max_value = entity.hp
	node.get_node("%hpbar").value = entity.current_hp
	node.get_node("%hpbar/label").text = '[b]%s' % entity.current_hp
	node.get_node("%manabar").max_value = entity.mp
	node.get_node("%manabar").value = entity.current_mp
	node.get_node("%manabar/label").text = '[b]%s' % entity.current_mp
	#node.get_node("%sprite").texture = entity.headSprite
	#entity.on_changed.connect(update_ui)
	node.scale = Vector2(0.5,0.5)
	return node
	
