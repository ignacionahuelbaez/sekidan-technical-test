@tool
class_name BTActionPatrol
extends BTAction

const PATROL_SPEED: float = 40.0
const PATROL_DISTANCE: float = 120.0

var _origin: Vector2
var _initialized: bool = false
var _direction: int = 1

func _enter() -> void:
	var enemy: EnemyLimbo = agent as EnemyLimbo
	if enemy == null:
		return
	if not _initialized:
		_origin = enemy.global_position
		_initialized = true

func _tick(_delta: float) -> Status:
	var enemy: EnemyLimbo = agent as EnemyLimbo
	if enemy == null:
		return FAILURE

	var traveled: float = enemy.global_position.x - _origin.x
	if traveled >= PATROL_DISTANCE:
		_direction = -1
	elif traveled <= -PATROL_DISTANCE:
		_direction = 1

	enemy.velocity = Vector2(float(_direction) * PATROL_SPEED, 0.0)
	enemy.animated_sprite.play("walk")
	enemy.animated_sprite.flip_h = _direction < 0

	return RUNNING
