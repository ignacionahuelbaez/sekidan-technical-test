@tool
class_name BTActionChase
extends BTAction

const CHASE_SPEED: float = 80.0


func _tick(_delta: float) -> Status:
	var enemy: EnemyLimbo = agent as EnemyLimbo
	if enemy == null or enemy.player_ref == null:
		return FAILURE

	var direction: Vector2 = (enemy.player_ref.global_position - enemy.global_position).normalized()
	enemy.velocity = direction * CHASE_SPEED

	enemy.animated_sprite.play("walk")
	if direction.x < 0:
		enemy.animated_sprite.flip_h = true
	elif direction.x > 0:
		enemy.animated_sprite.flip_h = false

	return SUCCESS
