@tool
class_name BTAttackPlayer
extends BTAction

# Porcentaje de la animación de ataque en el que el golpe conecta.
const IMPACT_FRAME_RATIO: float = 0.5

# Cantidad de fotogramas que la hitbox permanece activa una vez que conecta el golpe.
const ATTACK_WINDOW_FRAMES: int = 2

# Tiempo mínimo entre el final de un ataque y el inicio del siguiente.
const ATTACK_COOLDOWN: float = 0.8

var _animated_sprite: AnimatedSprite2D
var _hitbox_shape: CollisionShape2D
var _cooldown_timer: Timer
var _impact_frame: int = 0
var _window_end_frame: int = 0
var _skip_attack: bool = false
var _timer_initialized: bool = false

# Se ejecuta una sola vez, al empezar a atacar.
func _enter() -> void:
	var enemy: CharacterBody2D = agent as CharacterBody2D
	_cooldown_timer = enemy.get_node("Timer") as Timer

	# La primera vez, nos aseguramos de que el timer no esté
	# corriendo por configuración previa de la escena.
	if not _timer_initialized:
		_cooldown_timer.stop()
		_timer_initialized = true

	# Si todavía estamos en cooldown, no atacamos en este ciclo.
	if not _cooldown_timer.is_stopped():
		_skip_attack = true
		return

	_skip_attack = false
	_animated_sprite = enemy.get_node("AnimatedSprite2D") as AnimatedSprite2D
	_hitbox_shape = enemy.get_node("HitboxComponent/CollisionShape2D") as CollisionShape2D

	# NO move_and_slide() aquí — lo hace enemy.gd en _physics_process
	enemy.velocity = Vector2.ZERO

	_animated_sprite.play("attack")

	var total_frames: int = _animated_sprite.sprite_frames.get_frame_count("attack")
	_impact_frame = int(total_frames * IMPACT_FRAME_RATIO)
	_window_end_frame = _impact_frame + ATTACK_WINDOW_FRAMES

	_animated_sprite.frame_changed.connect(_on_frame_changed)

# Se ejecuta una sola vez, al terminar o ser interrumpido el ataque.
func _exit() -> void:
	if _skip_attack:
		return

	if _hitbox_shape:
		_hitbox_shape.set_deferred("disabled", true)

	if _animated_sprite and _animated_sprite.frame_changed.is_connected(_on_frame_changed):
		_animated_sprite.frame_changed.disconnect(_on_frame_changed)

	# Arrancamos el cooldown para el próximo ataque.
	_cooldown_timer.wait_time = ATTACK_COOLDOWN
	_cooldown_timer.one_shot = true
	_cooldown_timer.start()

# Se ejecuta cada frame mientras el ataque está en curso.
func _tick(_delta: float) -> Status:
	if _skip_attack:
		return FAILURE

	(agent as CharacterBody2D).velocity = Vector2.ZERO

	if not _animated_sprite.is_playing():
		return SUCCESS
	return RUNNING

# Activa la hitbox cuando la animación llega al frame de impacto,
# y la desactiva al terminar la ventana de ataque.
func _on_frame_changed() -> void:
	var current_frame: int = _animated_sprite.frame

	if current_frame >= _impact_frame and _hitbox_shape.disabled:
		_hitbox_shape.set_deferred("disabled", false)
	elif current_frame >= _window_end_frame and not _hitbox_shape.disabled:
		_hitbox_shape.set_deferred("disabled", true)
