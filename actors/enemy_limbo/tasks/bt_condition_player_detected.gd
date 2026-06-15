@tool
class_name BTConditionPlayerDetected
extends BTCondition

func _tick(_delta: float) -> Status:
	var enemy: EnemyLimbo = agent as EnemyLimbo
	if enemy == null:
		return FAILURE
	return SUCCESS if enemy.player_ref != null else FAILURE
