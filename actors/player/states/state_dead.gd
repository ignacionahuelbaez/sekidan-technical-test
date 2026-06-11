class_name StateDead
extends PlayerState

func enter() -> void:
	player.velocity = Vector2.ZERO
	player.play_animation("idle", Vector2.ZERO)
	player.set_physics_process(false)
