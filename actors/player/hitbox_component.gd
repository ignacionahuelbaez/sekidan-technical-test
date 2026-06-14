class_name HitboxComponent
extends Area2D

signal hit_landed

@export var damage: float = 10.0


func _ready() -> void:
	set_active(false)


func set_active(active: bool) -> void:
	monitoring = active
	set_deferred("monitorable", active)


func notify_hit() -> void:
	hit_landed.emit()
