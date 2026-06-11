class_name StateAttack
extends PlayerState

func enter() -> void:
	player.ejecutar_ataque_direccional()

# Vuelve a Idle cuando la animación de ataque termina.
func physics_update(_delta: float) -> void:
	if not player.sprite.is_playing():
		player.change_state("Idle")
