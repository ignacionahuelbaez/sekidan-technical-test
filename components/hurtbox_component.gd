extends Area2D
class_name HurtboxComponent

@onready var health_component: HealthComponent = $"../HealthComponent"

func _ready() -> void:
	# Conectamos la señal para detectar cuando entra un ataque
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	# Si lo que entró es una Hitbox, le mandamos el daño al componente de vida
	if area is HitboxComponent:
		if health_component:
			health_component.take_damage(area.damage)
