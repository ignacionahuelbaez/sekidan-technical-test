@tool
class_name BTAttackPlayer
extends BTAction

# Duración del ataque en segundos (ajustar según animación)
const ATTACK_DURATION: float = 0.4
# Momento en que el hitbox se activa (porcentaje de la duración)
const HITBOX_ACTIVATE_TIME: float = 0.2
# Duración que el hitbox permanece activo
const HITBOX_DURATION: float = 0.15

var _elapsed: float = 0.0
var _hitbox_activated: bool = false
var _hitbox: HitboxComponent = null
var _animated_sprite: AnimatedSprite2D = null
var _enemy: CharacterBody2D = null
var _deactivation_timer: SceneTreeTimer = null


func _enter() -> void:
	_elapsed = 0.0
	_hitbox_activated = false
	_enemy = agent as CharacterBody2D
	if not _enemy:
		return

	_animated_sprite = _enemy.get_node("AnimatedSprite2D") as AnimatedSprite2D
	_hitbox = _enemy.get_node("HitboxComponent") as HitboxComponent

	if _animated_sprite:
		_animated_sprite.play("attack")
		_animated_sprite.sprite_frames.set_animation_loop("attack", false)

	# Detener movimiento del enemigo durante el ataque
	_enemy.velocity = Vector2.ZERO
	_enemy.move_and_slide()

	# Cancelar cualquier timer pendiente de una ejecución anterior
	if _deactivation_timer:
		if _deactivation_timer.timeout.is_connected(_deactivate_hitbox):
			_deactivation_timer.timeout.disconnect(_deactivate_hitbox)
		_deactivation_timer = null


func _tick(delta: float) -> Status:
	if not _enemy or not _animated_sprite:
		return FAILURE

	_elapsed += delta

	# Activar hitbox en el momento justo del ataque
	if not _hitbox_activated and _elapsed >= HITBOX_ACTIVATE_TIME:
		_hitbox_activated = true
		if _hitbox:
			_hitbox.monitoring = true
			_hitbox.monitorable = true
			# Programar desactivación después de un breve tiempo
			var tree = _enemy.get_tree()
			if tree:
				_deactivation_timer = tree.create_timer(HITBOX_DURATION)
				_deactivation_timer.timeout.connect(_deactivate_hitbox)

	# Esperar a que termine la animación
	if not _animated_sprite.is_playing():
		return SUCCESS

	return RUNNING


func _deactivate_hitbox() -> void:
	if _hitbox:
		_hitbox.monitoring = false
	if _deactivation_timer:
		# Desconectar para evitar llamadas residuales
		if _deactivation_timer.timeout.is_connected(_deactivate_hitbox):
			_deactivation_timer.timeout.disconnect(_deactivate_hitbox)
		_deactivation_timer = null


func _exit() -> void:
	# Limpieza final
	if _hitbox:
		_hitbox.monitoring = false
	if _deactivation_timer:
		if _deactivation_timer.timeout.is_connected(_deactivate_hitbox):
			_deactivation_timer.timeout.disconnect(_deactivate_hitbox)
		_deactivation_timer = null
	if _animated_sprite:
		_animated_sprite.stop()
		_animated_sprite.sprite_frames.set_animation_loop("attack", false)
