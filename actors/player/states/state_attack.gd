class_name StateAttack
extends PlayerState

func enter() -> void:
	player.ejecutar_ataque_direccional()

func physics_update(_delta: float) -> void:
	if not player.sprite.is_playing():
		player.change_state("Idle")
