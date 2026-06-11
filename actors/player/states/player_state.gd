# Clase base para todos los estados del jugador.
# Cada estado hereda de esta clase e implementa los métodos que necesita.
class_name PlayerState
extends Node

var player: Player

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
