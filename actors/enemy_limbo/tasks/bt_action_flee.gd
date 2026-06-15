@tool
class_name BTActionFlee
extends BTAction

const FLEE_SPEED: float = 120.0
const SAFE_DISTANCE: float = 200.0

func _tick(_delta: float) -> Status:
	var enemy: EnemyLimbo = agent as EnemyLimbo
	if enemy == null or enemy.player_ref == null:
		return FAILURE

	var distance: float = enemy.global_position.distance_to(enemy.player_ref.global_position)
	if distance >= SAFE_DISTANCE:
		enemy.velocity = Vector2.ZERO
		return SUCCESS

	var flee_direction: Vector2 = (enemy.global_position - enemy.player_ref.global_position).normalized()
	enemy.velocity = flee_direction * FLEE_SPEED

	enemy.animated_sprite.play("walk")
	enemy.animated_sprite.flip_h = flee_direction.x < 0

	return RUNNING
