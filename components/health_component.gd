extends Node
class_name HealthComponent

signal health_changed(current_health: int)
signal health_depleted

@export var max_health: int = 100
var current_health: int

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int) -> void:
	if current_health <= 0:
		return

	current_health -= amount
	health_changed.emit(current_health)

	if current_health <= 0:
		current_health = 0
		health_depleted.emit()
