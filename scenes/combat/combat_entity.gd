extends Node3D

class_name CombatEntity

# unit's grid position
@export var x : int
@export var y : int

# unit's base stats.
# TODO: add other stats that we think would be cool and poggers.
@export var atk : int
@export var matk : int
@export var luc : int
@export var spd : int
@export var def : int
@export var mdef : int
@export var hp : int
@export var mp : int

@export var current_hp : int
@export var current_mp : int
@export var headSprite : Texture2D = preload("res://assets/defaultplayer-portrait.png")
@export var battlefieldSprite : Texture2D:
	set(v): 
		battlefieldSprite = v
		%sprite.texture = v

@export var is_enemy = true
@export var actions = [Combat_Action_Type.ATTACK,Combat_Action_Type.FLEE,Combat_Action_Type.ITEM,Combat_Action_Type.MOVE,Combat_Action_Type.DEFEND,Combat_Action_Type.SKILL]

var effective_stats : Dictionary = {}
var skills : Array[CombatAction] = []
var effects : Array[CombatStatusEffect] = []

# other
signal damage_taken(Node2D, float)
signal entity_death(CombatEntity)

func apply_damage(dmg: float, dmg_type : Combat_Detail.DAMAGE_TYPE) -> void:
	var post_mit_dmg : float
	# determine post-mitigation dmg
	if dmg_type == Combat_Detail.DAMAGE_TYPE.PHYSICAL:
		post_mit_dmg = dmg - effective_stats.get('def', def)
	elif dmg_type == Combat_Detail.DAMAGE_TYPE.MAGIC:
		post_mit_dmg = dmg * (1 - (effective_stats.get('mdef', mdef)/100))
	else:
		post_mit_dmg = dmg
	if post_mit_dmg > 0:
		print("%s takes %d damage!" % [name, post_mit_dmg])
		current_hp -= post_mit_dmg
	damage_taken.emit(self, post_mit_dmg)
	%HPLabel.text = "%s/%s" % [str(current_hp), str(hp)]	
	if (current_hp <= 0):
		print(name + " has been defeated!")
		entity_death.emit(self)

func apply_status(statusEffect : CombatStatusEffect, duration : int):
	effects.append(statusEffect)
	statusEffect.duration = duration
	add_buff_bar(statusEffect)


func apply_heal(dmg: float) -> void:
	var amount_healed = min(dmg, hp - current_hp)
	current_hp = min(hp, current_hp + dmg)
	print("%s was healed for %d damage, now has %d HP" % [name, amount_healed, current_hp])
	damage_taken.emit(self, amount_healed * -1)
	%HPLabel.text = "%s/%s" % [str(current_hp), str(hp)]

# when the unit's turn starts, apply lingering effects and tick them down
func on_turn_start() -> void:
	effective_stats = {}
	for child in %buffbar.get_children():
		%buffbar.remove_child(child)
		child.queue_free()
	var expired = []
	for effect : CombatStatusEffect in effects:
		effect.duration -= 1
		if effect.duration <= 0:
			expired.append(effect)
		else:
			add_buff_bar(effect)
			effect.apply_effect(self)
	for effect in expired:
		effects.erase(effect)

func apply_skill_cost(skill : CombatAction) -> bool:
	if not skill.skillCost or skill.skillCostType == CombatSkillDetail.COST_TYPE.NONE:
		return true
	elif skill.skillCostType == CombatSkillDetail.COST_TYPE.MP and current_mp > skill.skillCost:
		current_mp -= skill.skillCost
		return true
	elif skill.skillCostType == CombatSkillDetail.COST_TYPE.HP and current_hp > skill.skillCost:
		current_hp -= skill.skillCost
		return true
	return false


func add_buff_bar(effect : CombatStatusEffect) -> void:
	var buffbaritem = TextureRect.new()
	buffbaritem.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	buffbaritem.size = Vector2(40,40)
	buffbaritem.texture = effect.hud_icon
	buffbaritem.show()
	%buffbar.add_child(buffbaritem)


func _ready() -> void:
	$battlefieldSprite/sprite.texture = battlefieldSprite
	current_hp = hp 
	current_mp = mp
	%HPLabel.text = "%s/%s" % [str(current_hp), str(hp)]

func _process(delta: float) -> void:
	pass
