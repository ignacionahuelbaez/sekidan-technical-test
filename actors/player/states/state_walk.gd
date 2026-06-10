class_name StateWalk
extends PlayerState

func physics_update(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction == Vector2.ZERO:
		player.change_state("Idle")
	else:
		player.velocity = direction * player.SPEED
		player.move_and_slide()
