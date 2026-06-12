# Detiene al enemigo y ejecuta la animación de ataque completa.
@tool
class_name BTAttackPlayer
extends BTAction

func _tick(_delta: float) -> Status:
	var enemy: CharacterBody2D = agent as CharacterBody2D
	var animated_sprite: AnimatedSprite2D = enemy.get_node("AnimatedSprite2D") as AnimatedSprite2D
	enemy.velocity = Vector2.ZERO
	enemy.move_and_slide()
	# Reproduce ataque solo si no está ya reproduciéndose
	if animated_sprite.animation != "attack":
		animated_sprite.play("attack")
	# Espera a que termine la animación antes de retornar SUCCESS
	if not animated_sprite.is_playing():
		return SUCCESS
	return RUNNING
