class_name StateIdle
extends PlayerState

func enter() -> void:
	pass

func physics_update(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		player.change_state("Walk")
