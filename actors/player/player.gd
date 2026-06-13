func _ready() -> void:
	add_to_group("player")
	health_component.health_depleted.connect(_on_health_depleted)

	# LÍNEA NUEVA — conectar hurtbox al health component
	var hurtbox: HurtboxComponent = $HurtboxComponent as HurtboxComponent
	hurtbox.damage_received.connect(_on_damage_received)

	current_state = $States/Idle
	current_state.player = self
	current_state.enter()


# FUNCIÓN NUEVA
func _on_damage_received(amount: float) -> void:
	health_component.take_damage(amount)
	if current_state != $States/Dead:
		change_state("Hurt")
