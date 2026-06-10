class_name StateIdle
extends PlayerState

func enter() -> void:
	# Le pasamos "idle" y Vector2.ZERO porque está quieto
	player.controlar_animacion("idle", Vector2.ZERO)

func physics_update(_delta: float) -> void:
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		player.change_state("Walk")
