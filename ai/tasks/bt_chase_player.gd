class_name BTChasePlayer
extends BTAction

const SPEED: float = 80.0

func _tick(_delta: float) -> Status:
	var enemy: CharacterBody2D = agent as CharacterBody2D
	var player: Node2D = scene_root.get_first_node_in_group("player") as Node2D
	var animated_sprite: AnimatedSprite2D = enemy.get_node("AnimatedSprite2D") as AnimatedSprite2D
	if not player:
		return FAILURE
	var direction: Vector2 = (player.global_position - enemy.global_position).normalized()
	enemy.velocity = direction * SPEED
	enemy.move_and_slide()
	animated_sprite.play("walk")
	animated_sprite.flip_h = direction.x < 0
	return RUNNING
