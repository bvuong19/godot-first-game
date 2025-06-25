extends Resource

class_name Character

@export var atk : int
@export var matk : int
@export var luc : int
@export var spd : int
@export var def : int
@export var mdef : int
@export var hp : int
@export var mp : int

@export var headSprite : Texture2D = preload("res://assets/combat/default/defaultplayer-portrait.png")
@export var battlefieldSprite : Texture2D = preload("res://assets/combat/default/defaultplayer.png")
@export var actions = [CombatDetail.ACTION_TYPE.ATTACK,CombatDetail.ACTION_TYPE.FLEE,CombatDetail.ACTION_TYPE.ITEM,CombatDetail.ACTION_TYPE.MOVE,CombatDetail.ACTION_TYPE.DEFEND,CombatDetail.ACTION_TYPE.SKILL]
@export var skills : Array[Resource] = []

# instance-based data
@export var x : int
@export var y : int
@export var current_hp : int
@export var current_mp : int
