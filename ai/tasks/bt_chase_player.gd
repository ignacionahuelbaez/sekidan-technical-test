# Mueve al enemigo hacia el jugador mientras esté en rango de detección.
@tool
class_name BTChasePlayer
extends BTAction

const SPEED: float = 80.0

func _tick(_delta: float) -> Status:
	var player: Node2D = blackboard.get_var(&"player", null) as Node2D
	var animated_sprite: AnimatedSprite2D = agent.get_node("AnimatedSprite2D") as AnimatedSprite2D
	if not is_instance_valid(player):
		return FAILURE
	var direction: Vector2 = (player.global_position - agent.global_position).normalized()
	(agent as CharacterBody2D).velocity = direction * SPEED
	(agent as CharacterBody2D).move_and_slide()
	animated_sprite.play("walk")
	animated_sprite.flip_h = direction.x < 0
	return RUNNING
