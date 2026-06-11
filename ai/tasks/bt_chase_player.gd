extends BTAction

func _tick(_delta: float) -> Status:
	# Obtener referencias desde la Blackboard de LimboAI
	var enemy: Enemy = blackboard.get_var("enemy")
	var player: CharacterBody2D = blackboard.get_var("player")
	
	if not enemy or not player:
		return FAILURE
		
	# Calculamos distancia
	var distance = enemy.global_position.distance_to(player.global_position)
	
	# Si está muy cerca, pasa el control al estado de ataque de LimboAI
	if distance <= 30.0:
		enemy.velocity = Vector2.ZERO
		return SUCCESS
		
	# Movemos usando el método seguro del enemigo
dd	enemy.move_towards_position(player.global_position)
	return RUNNING
