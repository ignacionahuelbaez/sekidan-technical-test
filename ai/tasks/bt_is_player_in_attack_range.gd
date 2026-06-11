@tool
class_name BTIsPlayerInAttackRange
extends BTCondition

const ATTACK_RANGE: float = 40.0

func _tick(_delta: float) -> Status:
	var player: Node2D = blackboard.get_var(&"player", null) as Node2D
	if not is_instance_valid(player):
		return FAILURE
	var dist: float = agent.global_position.distance_to(player.global_position)
	return SUCCESS if dist <= ATTACK_RANGE else FAILURE
