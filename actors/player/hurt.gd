extends PlayerState

const FLASH_COLOR: Color = Color(5.0, 0.3, 0.3, 1.0)
const NORMAL_COLOR: Color = Color.WHITE
const HURT_DURATION: float = 0.4


func enter() -> void:
	player.velocity = Vector2.ZERO
	player.play_animation("idle", Vector2.ZERO)

	# Flash con Tween — seguro, no bloquea el estado
	var tween: Tween = player.create_tween()
	player.sprite.modulate = FLASH_COLOR
	tween.tween_property(player.sprite, "modulate", NORMAL_COLOR, FLASH_COLOR.v * 0.05)

	# Timer para salir del estado después de HURT_DURATION segundos
	var timer: SceneTreeTimer = player.get_tree().create_timer(HURT_DURATION)
	timer.timeout.connect(_on_hurt_finished)


func exit() -> void:
	player.sprite.modulate = NORMAL_COLOR


func physics_update(_delta: float) -> void:
	pass


func _on_hurt_finished() -> void:
	# Verificar que todavía estamos en Hurt antes de transicionar
	if player.current_state == self:
		player.change_state("Idle")
