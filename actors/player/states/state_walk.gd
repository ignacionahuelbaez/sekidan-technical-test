class_name StateWalk
extends PlayerState

func physics_update(_delta: float) -> void:
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction == Vector2.ZERO:
		player.change_state("Idle")
	else:
		player.velocity = direction * player.SPEED
		
		# FUNDAMENTO: Aquí llamamos a la función inteligente pasándole la dirección.
		# Como la función chequea si ya está puesta "walk", no va a reiniciar la animación.
		player.controlar_animacion("walk", direction)
		
		player.move_and_slide()
