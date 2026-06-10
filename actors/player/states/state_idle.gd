class_name StateIdle
extends PlayerState

func enter() -> void:
	player.controlar_animacion("idle", Vector2.ZERO)

func physics_update(_delta: float) -> void:
	# También escuchamos el ataque desde el estado de reposo
	if Input.is_action_just_pressed("atacar"):
		player.change_state("Attack")
		return
		
	var direccion: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direccion != Vector2.ZERO:
		player.change_state("Walk")
