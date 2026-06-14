extends EnemyState

const FLASH_COLOR: Color = Color(5.0, 0.3, 0.3, 1.0)
const NORMAL_COLOR: Color = Color.WHITE
const HURT_DURATION: float = 0.3
const KNOCKBACK_DECAY: float = 10.0


func enter() -> void:
	enemy.hitbox_component.set_active(false)

	var tween: Tween = enemy.create_tween()
	enemy.sprite.modulate = FLASH_COLOR
	tween.tween_property(enemy.sprite, "modulate", NORMAL_COLOR, HURT_DURATION)

	var timer: SceneTreeTimer = enemy.get_tree().create_timer(HURT_DURATION)
	timer.timeout.connect(_on_hurt_finished)


func exit() -> void:
	enemy.sprite.modulate = NORMAL_COLOR
	enemy.velocity = Vector2.ZERO


func physics_update(delta: float) -> void:
	enemy.velocity = enemy.velocity.move_toward(Vector2.ZERO, KNOCKBACK_DECAY * 60.0 * delta)
	enemy.move_and_slide()


func _on_hurt_finished() -> void:
	if enemy.current_state == self:
		enemy.change_state("Chase")
