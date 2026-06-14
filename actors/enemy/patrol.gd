extends EnemyState

const PATROL_SPEED: float = 40.0
const PATROL_DISTANCE: float = 80.0

var _start_position: Vector2
var _direction: float = 1.0


func enter() -> void:
	_start_position = enemy.global_position
	enemy.sprite.play("idle")


func physics_update(_delta: float) -> void:
	if enemy.player_detected:
		enemy.change_state("Chase")
		return

	var target_x: float = _start_position.x + _direction * PATROL_DISTANCE
	var diff: float = target_x - enemy.global_position.x

	if abs(diff) < 2.0:
		_direction *= -1.0
		enemy.sprite.play("idle")
		return

	enemy.velocity.x = _direction * PATROL_SPEED
	enemy.velocity.y = 0.0
	enemy.move_and_slide()
	enemy.sprite.play("walk")
	enemy.sprite.flip_h = _direction < 0.0
