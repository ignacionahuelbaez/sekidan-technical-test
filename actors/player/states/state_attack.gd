class_name StateAttack
extends PlayerState

func enter() -> void:
	# Le pedimos al player que ejecute el ataque según hacia dónde miraba
	player.ejecutar_ataque_direccional()

func physics_update(_delta: float) -> void:
	# Monitoreamos si cualquiera de las animaciones de ataque terminó
	if not player.sprite.is_playing() or not player.sprite.animation.begins_with("attack"):
		player.change_state("Idle")
