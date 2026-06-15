@tool
class_name BTConditionPlayerInAttackRange
extends BTCondition

const ATTACK_RANGE: float = 60.0

func _tick(_delta: float) -> Status:
	var enemy: EnemyLimbo = agent as EnemyLimbo
	if enemy == null or enemy.player_ref == null:
		return FAILURE
	var distance: float = enemy.global_position.distance_to(enemy.player_ref.global_position)
	return SUCCESS if distance <= ATTACK_RANGE else FAILURE
