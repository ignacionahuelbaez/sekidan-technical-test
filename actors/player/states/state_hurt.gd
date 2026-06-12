class_name StateHurt
extends PlayerState

const HURT_DURATION: float = 0.3
const HURT_COLOR: Color = Color(2.0, 1.0, 1.0, 1.0)  # Rojo intenso
const NORMAL_COLOR: Color = Color.WHITE

var _tween: Tween


func enter() -> void:
	player.velocity = Vector2.ZERO
	player.play_animation("idle", Vector2.ZERO)

	# Efecto de flash rojo con Tween (más jugoso que Timer)
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	player.sprite.modulate = HURT_COLOR
	_tween.tween_property(player.sprite, "modulate", NORMAL_COLOR, HURT_DURATION)

	# Esperar a que termine el flash y luego volver a Idle
	await _tween.finished
	# Verificar que aún siga en estado Hurt antes de cambiar
	if player.current_state == self:
		player.change_state("Idle")


func physics_update(_delta: float) -> void:
	# Congelado durante el hurt, no recibe input de movimiento
	player.velocity = Vector2.ZERO


func exit() -> void:
	# Asegurar que el color vuelva a la normalidad si se sale antes
	if _tween and _tween.is_valid():
		_tween.kill()
	player.sprite.modulate = NORMAL_COLOR
