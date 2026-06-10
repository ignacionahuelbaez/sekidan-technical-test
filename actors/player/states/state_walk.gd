class_name StateWalk
extends PlayerState

func physics_update(_delta: float) -> void:
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction == Vector2.ZERO:
		player.change_state("Idle")
	else:
		player.velocity = direction * player.SPEED
		
		# Llama a "walk" en minúscula tal como está en tus SpriteFrames
		player.controlar_animacion("walk", direction)
		
		player.move_and_slide()
