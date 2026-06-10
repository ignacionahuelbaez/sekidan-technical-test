class_name StateHurt
extends PlayerState

func enter() -> void:
	# Frenamos al jugador por el impacto
	player.velocity = Vector2.ZERO
	
	# Como no hay sprite de hurt, usamos la animación "idle" de base
	player.controlar_animacion("idle", Vector2.ZERO)
	
	# TRUCO VISUAL: Pintamos el sprite de color rojo puro (R:2, G:0.5, B:0.5 hace un efecto brillante)
	player.sprite.modulate = Color(2.0, 0.5, 0.5, 1.0)
	
	# Creamos un temporizador rápido de 0.3 segundos (el tiempo que dura el golpe)
	# Al terminar el tiempo, llamamos automáticamente a la función 'terminar_golpe'
	get_tree().create_timer(0.3).timeout.connect(terminar_golpe)

func physics_update(_delta: float) -> void:
	# Dejamos esta función vacía para que el jugador no pueda moverse mientras dura el temporizador
	pass

func terminar_golpe() -> void:
	# IMPORTANTE: Devolvemos el color original al sprite (Blanco puro es el estado normal)
	player.sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	# Regresamos el control al jugador mandándolo a Idle
	player.change_state("Idle")
