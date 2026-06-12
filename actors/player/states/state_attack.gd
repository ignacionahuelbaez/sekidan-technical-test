extends PlayerState # O la clase que uses como base para tus estados

#region REFERENCIAS
# Asegurate de que player.hitbox apunte a tu nodo HitboxComponent
#endregion

func enter() -> void:
	# 1. Ejecutamos la animación de ataque
	player.ejecutar_ataque_direccional()
	
	# 2. ACTIVAMOS la Hitbox solo al empezar el ataque
	if player.hitbox:
		player.hitbox.monitoring = true
		# Si usas collision shape, podrías necesitar: 
		# player.hitbox.get_node("CollisionShape2D").disabled = false

func physics_update(_delta: float) -> void:
	# Mantenemos al jugador quieto mientras ataca
	player.velocity = Vector2.ZERO
	
	# Cuando la animación termina, volvemos a Idle
	if not player.sprite.is_playing():
		player.change_state("Idle")

func exit() -> void:
	# 3. DESACTIVAMOS la Hitbox al terminar el ataque
	if player.hitbox:
		player.hitbox.monitoring = false
		# Si usas collision shape, podrías necesitar:
		# player.hitbox.get_node("CollisionShape2D").disabled = true
