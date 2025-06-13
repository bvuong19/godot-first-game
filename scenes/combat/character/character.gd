extends Resource

class_name Character

# unit's base stats
@export var atk : int
@export var matk : int
@export var luc : int
@export var spd : int
@export var def : int
@export var mdef : int
@export var hp : int
@export var mp : int

@export var headSprite : Texture2D = preload("res://assets/defaultplayer-portrait.png")
@export var battlefieldSprite : Texture2D:
	set(v): 
		battlefieldSprite = v
		%sprite.texture = v
@export var actions = [CombatDetail.ACTION_TYPE.ATTACK,CombatDetail.ACTION_TYPE.FLEE,CombatDetail.ACTION_TYPE.ITEM,CombatDetail.ACTION_TYPE.MOVE,CombatDetail.ACTION_TYPE.DEFEND,CombatDetail.ACTION_TYPE.SKILL]
var skills : Array[CombatAction] = []
