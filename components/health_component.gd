extends Node
class_name HealthComponent

signal health_changed(current_health: int)
signal death

@export var max_health: int = 100
var current_health: int

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int) -> void:
	if current_health <= 0:
		return
		
	# CORRECCIÓN: Restamos el daño a la vida actual para que vaya bajando progresivamente
	current_health -= amount
	
	# Emitimos cuánta vida le queda (para el flash rojo)
	health_changed.emit(current_health)
	
	# Si llegó a cero o menos, se muere
	if current_health <= 0:
		current_health = 0
		death.emit()
