class_name StateAttack
extends PlayerState

# Porcentaje de la animación de ataque en el que el golpe conecta.
const IMPACT_FRAME_RATIO: float = 0.5

# Cantidad de fotogramas que la hitbox permanece activa una vez que conecta el golpe.
const ATTACK_WINDOW_FRAMES: int = 2

var _impact_frame: int = 0
var _window_end_frame: int = 0

func enter() -> void:
	player.ejecutar_ataque_direccional()

	var total_frames: int = player.sprite.sprite_frames.get_frame_count(player.sprite.animation)
	_impact_frame = int(total_frames * IMPACT_FRAME_RATIO)
	_window_end_frame = _impact_frame + ATTACK_WINDOW_FRAMES

	player.sprite.frame_changed.connect(_on_frame_changed)

func physics_update(_delta: float) -> void:
	player.velocity = Vector2.ZERO

	if not player.sprite.is_playing():
		player.change_state("Idle")

func exit() -> void:
	if player.hitbox_shape:
		player.hitbox_shape.set_deferred("disabled", true)

	if player.sprite.frame_changed.is_connected(_on_frame_changed):
		player.sprite.frame_changed.disconnect(_on_frame_changed)

# Activa la hitbox cuando la animación llega al frame de impacto,
# y la desactiva al terminar la ventana de ataque.
func _on_frame_changed() -> void:
	var current_frame: int = player.sprite.frame

	if current_frame >= _impact_frame and player.hitbox_shape.disabled:
		player.hitbox_shape.set_deferred("disabled", false)
	elif current_frame >= _window_end_frame and not player.hitbox_shape.disabled:
		player.hitbox_shape.set_deferred("disabled", true)
