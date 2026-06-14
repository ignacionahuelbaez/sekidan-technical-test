extends PlayerState

const FLASH_COLOR: Color = Color(5.0, 0.3, 0.3, 1.0)
const NORMAL_COLOR: Color = Color.WHITE
const HURT_DURATION: float = 0.4
const KNOCKBACK_DECAY: float = 10.0


func enter() -> void:
	player.play_animation("idle", Vector2.ZERO)

	var tween: Tween = player.create_tween()
	player.sprite.modulate = FLASH_COLOR
	tween.tween_property(player.sprite, "modulate", NORMAL_COLOR, FLASH_COLOR.v * 0.05)

	var timer: SceneTreeTimer = player.get_tree().create_timer(HURT_DURATION)
	timer.timeout.connect(_on_hurt_finished)


func exit() -> void:
	player.sprite.modulate = NORMAL_COLOR
	player.velocity = Vector2.ZERO


func physics_update(delta: float) -> void:
	player.velocity = player.velocity.move_toward(Vector2.ZERO, KNOCKBACK_DECAY * 60.0 * delta)
	player.move_and_slide()


func _on_hurt_finished() -> void:
	if player.current_state == self:
		player.change_state("Idle")
