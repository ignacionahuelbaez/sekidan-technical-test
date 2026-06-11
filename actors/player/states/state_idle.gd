class_name StateIdle
extends PlayerState

func enter() -> void:
	player.play_animation("idle", Vector2.ZERO)

func physics_update(_delta: float) -> void:
	if Input.is_action_just_pressed("atacar"):
		player.change_state("Attack")
		return
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		player.change_state("Walk")
