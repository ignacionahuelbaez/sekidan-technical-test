class_name StateAttack
extends PlayerState

func enter() -> void:
	pass

func physics_update(delta: float) -> void:
	player.change_state("Idle")
