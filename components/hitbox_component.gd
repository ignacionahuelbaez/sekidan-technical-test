# Área que inflige daño al entrar en contacto con un HurtboxComponent.
class_name HitboxComponent
extends Area2D

@export var damage: float = 10.0

func _ready() -> void:
	monitoring = true
	monitorable = true
