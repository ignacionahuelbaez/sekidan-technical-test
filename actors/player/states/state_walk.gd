class_name StateWalk
extends PlayerState

func physics_update(_delta: float) -> void:
	# Si presiona la acción que configuramos en el paso 1, entra a atacar
	if Input.is_action_just_pressed("atacar"):
		player.change_state("Attack")
		return
		
	var direccion: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direccion == Vector2.ZERO:
		player.change_state("Idle")
	else:
		player.velocity = direccion * player.SPEED
		
		# Sincronizado: "walk" en minúscula como está en tus SpriteFrames
		player.controlar_animacion("walk", direccion)
		
		player.move_and_slide()
