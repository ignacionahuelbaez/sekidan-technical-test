class_name HitboxComponent
extends Area2D

@export var damage: float = 10.0


func _ready() -> void:
	set_active(false)


func set_active(active: bool) -> void:
	monitoring = active
	set_deferred("monitorable", active)
