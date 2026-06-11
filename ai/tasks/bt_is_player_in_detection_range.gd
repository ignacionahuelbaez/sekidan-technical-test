@tool
class_name BTIsPlayerInDetectionRange
extends BTCondition

const DETECTION_RANGE: float = 200.0

func _tick(_delta: float) -> Status:
	var player: Node2D = agent.get_tree().get_first_node_in_group("player") as Node2D
	if not is_instance_valid(player):
		return FAILURE
	return SUCCESS if agent.global_position.distance_to(player.global_position) <= DETECTION_RANGE else FAILURE
