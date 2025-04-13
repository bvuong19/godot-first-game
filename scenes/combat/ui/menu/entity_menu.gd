extends PanelContainer

var entity : CombatEntity = null
var stat_menu_item = preload("res://scenes/combat/ui/menu/stats_menu_item.tscn")

func add_entity(entity : CombatEntity) -> void:
	for child in %statsmenu.get_children():
		child.free()
	self.entity = entity
	addStatMenuItem(entity.atk, entity.effective_stats.get('atk', entity.atk), 'ATK')
	addStatMenuItem(entity.matk, entity.effective_stats.get('matk', entity.matk), 'MATK')
	addStatMenuItem(entity.luc, entity.effective_stats.get('luc', entity.luc), 'LUC')
	addStatMenuItem(entity.spd, entity.effective_stats.get('spd', entity.spd), 'SPD')
	addStatMenuItem(entity.def, entity.effective_stats.get('def', entity.def), 'DEF')
	addStatMenuItem(entity.mdef, entity.effective_stats.get('mdef', entity.mdef), 'MDEF')
	%entityPortrait.texture = entity.headSprite
	%nameLabel.text = entity.name
	%hpbar.max_value = entity.hp
	%hpbar.min_value = 0
	%hpbar.value = entity.current_hp
	%hpbarLabel.text = '%s / %s' % [entity.current_hp, entity.hp]
	%resourcebar.max_value = entity.mp
	%resourcebar.min_value = 0
	%resourcebar.value = entity.current_mp
	%resourcebarLabel.text = '%s / %s' % [entity.current_mp, entity.mp]
	
	
func addStatMenuItem(base : float, effective : float, display_name : String) -> void:
	var color = Color.LIME_GREEN if effective > base else Color.INDIAN_RED if effective < base else null
	var menu_item = stat_menu_item.instantiate()
	menu_item.get_node('statNameLabel').text = display_name
	var stat_value_label : Label = menu_item.get_node('statValueLabel')
	stat_value_label.text = str(int(effective))
	if color:
		stat_value_label.add_theme_color_override("font_color", color)
	%statsmenu.add_child(menu_item)
