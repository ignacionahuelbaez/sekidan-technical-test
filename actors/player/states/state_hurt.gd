class_name StateHurt
extends PlayerState

const HURT_DURATION: float = 0.3
const HURT_COLOR: Color = Color(2.0, 0.5, 0.5, 1.0)
const NORMAL_COLOR: Color = Color(1.0, 1.0, 1.0, 1.0)

var _timer: SceneTreeTimer

func enter() -> void:
	player.velocity = Vector2.ZERO
	player.play_animation("idle", Vector2.ZERO)
	player.sprite.modulate = HURT_COLOR
	_timer = get_tree().create_timer(HURT_DURATION)
	_timer.timeout.connect(_on_hurt_finished)

func physics_update(_delta: float) -> void:
	pass

func exit() -> void:
	# Evita que el timer revierta el estado si Hurt fue interrumpido
	# (por ejemplo, por una transición a Dead o por otro golpe).
	if _timer and _timer.timeout.is_connected(_on_hurt_finished):
		_timer.timeout.disconnect(_on_hurt_finished)
	player.sprite.modulate = NORMAL_COLOR

func _on_hurt_finished() -> void:
	player.change_state("Idle")
