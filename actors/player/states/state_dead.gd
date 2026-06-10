class_name StateDead
extends PlayerState

func enter() -> void:
	# Asegura que el personaje no flote ni se deslice muerto
	player.velocity = Vector2.ZERO
	
	# Llama a la animación de muerte (creala abajo como "dead" con el cuadro más bajo de dolor)
	player.controlar_animacion("dead", Vector2.ZERO)
	
	# REQUISITO RECOMENTADO DE LA PRUEBA: Apagamos el procesamiento del Player
	# para que el teclado deje de funcionar y los enemigos lo ignoren.
	player.set_physics_process(false)
