extends PlayerState


func enter() -> void:
	player.velocity = Vector2.ZERO
	player.play_animation("idle", Vector2.ZERO)


func physics_update(_delta: float) -> void:
	var input: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if input != Vector2.ZERO:
		player.change_state("Walk")
		return

	if Input.is_action_just_pressed("atacar"):
		player.change_state("Attack")
		return
