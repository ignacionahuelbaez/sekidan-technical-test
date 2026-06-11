class_name StateWalk
extends PlayerState

func physics_update(_delta: float) -> void:
	if Input.is_action_just_pressed("atacar"):
		player.change_state("Attack")
		return
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction == Vector2.ZERO:
		player.change_state("Idle")
	else:
		player.velocity = direction * player.SPEED
		player.play_animation("walk", direction)
		player.move_and_slide()
