extends Area2D
class_name HurtboxComponent

@onready var health_component: HealthComponent = $"../HealthComponent"


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	# Verificar que el área sea una HitboxComponent
	if not (area is HitboxComponent):
		return

	# IMPORTANTE: evitar auto-daño. El hitbox no debe dañar al mismo dueño.
	# El dueño del hurtbox es el personaje (player o enemigo).
	# El dueño del hitbox es el atacante.
	var hitbox_owner = area.owner
	if hitbox_owner == owner:
		# El hitbox pertenece al mismo personaje -> ignorar
		return

	if health_component:
		health_component.take_damage(area.damage)
