@tool
class_name BTConditionLowHealth
extends BTCondition

func _tick(_delta: float) -> Status:
	var enemy: EnemyLimbo = agent as EnemyLimbo
	if enemy == null:
		return FAILURE
	return SUCCESS if enemy.is_low_health() else FAILURE
