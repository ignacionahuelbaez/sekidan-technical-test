class_name StateHurt
extends PlayerState

const HURT_DURATION: float = 0.3
const HURT_COLOR: Color = Color(2.0, 0.5, 0.5, 1.0)
const NORMAL_COLOR: Color = Color(1.0, 1.0, 1.0, 1.0)

func enter() -> void:
	player.velocity = Vector2.ZERO
	player.play_animation("idle", Vector2.ZERO)
	player.sprite.modulate = HURT_COLOR
	get_tree().create_timer(HURT_DURATION).timeout.connect(_on_hurt_finished)

func physics_update(_delta: float) -> void:
	pass

func _on_hurt_finished() -> void:
	player.sprite.modulate = NORMAL_COLOR
	player.change_state("Idle")
