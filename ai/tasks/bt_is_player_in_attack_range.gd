class_name BTIsPlayerInAttackRange
extends BTCondition

const ATTACK_RANGE: float = 40.0

func _tick(_delta: float) -> Status:
	var enemy: CharacterBody2D = agent as CharacterBody2D
	var player: Node2D = scene_root.get_first_node_in_group("player") as Node2D
	if not player:
		return FAILURE
	var dist: float = enemy.global_position.distance_to(player.global_position)
	return SUCCESS if dist <= ATTACK_RANGE else FAILURE
