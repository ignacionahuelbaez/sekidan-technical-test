extends PlayerState


func enter() -> void:
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)
	player.play_animation("dead", Vector2.ZERO)
