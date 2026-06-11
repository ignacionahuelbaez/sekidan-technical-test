@tool
class_name BTPatrol
extends BTAction

const SPEED: float = 50.0
const PATROL_DISTANCE: float = 100.0

var _direction: Vector2 = Vector2.RIGHT
var _distance_traveled: float = 0.0

func _tick(delta: float) -> Status:
	var animated_sprite: AnimatedSprite2D = agent.get_node("AnimatedSprite2D") as AnimatedSprite2D
	(agent as CharacterBody2D).velocity = _direction * SPEED
	(agent as CharacterBody2D).move_and_slide()
	animated_sprite.play("walk")
	animated_sprite.flip_h = _direction.x < 0
	_distance_traveled += SPEED * delta
	if _distance_traveled >= PATROL_DISTANCE:
		_direction = -_direction
		_distance_traveled = 0.0
	return RUNNING
