class_name StateDead
extends PlayerState


func enter() -> void:
	# Detener cualquier movimiento
	player.velocity = Vector2.ZERO

	# Reproducir animación de muerte (debe existir "dead" en SpriteFrames)
	player.play_animation("dead", Vector2.ZERO)

	# Desactivar el procesamiento de entrada y físicas
	player.set_physics_process(false)
	player.set_process_input(false)

	# Opcional: desactivar colisiones para que no interfiera con otros objetos
	player.set_collision_layer_value(1, false)   # Capa de jugador
	player.set_collision_mask_value(1, false)    # Máscara de colisión

	# Desactivar hitbox y hurtbox para que no pueda ser dañado ni dañar
	if player.hitbox_shape:
		player.hitbox_shape.set_deferred("disabled", true)

	var hurtbox_shape = player.get_node("HurtboxComponent/CollisionShape2D")
	if hurtbox_shape:
		hurtbox_shape.set_deferred("disabled", true)


func physics_update(_delta: float) -> void:
	# No hacer nada, el jugador está muerto
	player.velocity = Vector2.ZERO


func exit() -> void:
	# No debería salir del estado Dead, pero por seguridad:
	pass
