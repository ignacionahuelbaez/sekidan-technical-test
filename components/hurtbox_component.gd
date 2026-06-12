extends Area2D
class_name HurtboxComponent

@onready var health_component: HealthComponent = $"../HealthComponent"

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	# 1. Validamos que lo que entró sea una HitboxComponent
	if area is HitboxComponent:
		# 2. ¡Clave! Si la hitbox del jugador está desactivada o no está atacando, no hacemos nada
		if area.monitoring == false or area.monitorable == false:
			return
			
		if health_component:
			health_component.take_damage(area.damage)
