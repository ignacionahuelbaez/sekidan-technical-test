class_name BTAttackPlayer
extends BTAction

func _tick(_delta: float) -> Status:
	var enemy: CharacterBody2D = agent as CharacterBody2D
	var animated_sprite: AnimatedSprite2D = enemy.get_node("AnimatedSprite2D") as AnimatedSprite2D
	enemy.velocity = Vector2.ZERO
	enemy.move_and_slide()
	animated_sprite.play("attack")
	return SUCCESS
