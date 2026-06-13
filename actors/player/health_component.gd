class_name HealthComponent
extends Node

signal health_changed(new_health: float)
signal health_depleted

@export var max_health: float = 100.0

var current_health: float


func _ready() -> void:
	current_health = max_health


func take_damage(amount: float) -> void:
	if current_health <= 0.0:
		return
	current_health = clamp(current_health - amount, 0.0, max_health)
	health_changed.emit(current_health)
	if current_health <= 0.0:
		health_depleted.emit()
