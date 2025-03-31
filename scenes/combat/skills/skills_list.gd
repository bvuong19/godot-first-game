class_name SKILLS

static var Heal : CombatSkill = CombatSkill.new(
	'Heal',
	CombatSkillDetail.TARGET_TYPE.ALLY, 
	[], 
	CombatSkillDetail.EFFECT_TYPE.INSTANT, 
	func(user : CombatEntity, target : CombatEntity): target.apply_heal(user.atk * 0.5))
	
static var Fire : CombatSkill = CombatSkill.new(
	'Fira',
	CombatSkillDetail.TARGET_TYPE.ENEMY, 
	[], 
	CombatSkillDetail.EFFECT_TYPE.INSTANT, 
	func(user : CombatEntity, target : CombatEntity): target.apply_damage(user.atk * 1.5))
