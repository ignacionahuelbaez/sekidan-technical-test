class_name BTIsPlayerInDetectionRange
extends BTCondition

const DETECTION_RANGE: float = 200.0

func _tick(_delta: float) -> Status:
	var enemy: CharacterBody2D = agent as CharacterBody2D
	var player: Node2D = scene_root.get_first_node_in_group("player") as Node2D
	if not player:
		return FAILURE
	var dist: float = enemy.global_position.distance_to(player.global_position)
	return SUCCESS if dist <= DETECTION_RANGE else FAILURE
