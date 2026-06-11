class_name HurtboxComponent
extends Area2D

@export var health_component: HealthComponent

func _ready() -> void:
	monitorable = true
	monitoring = true
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		var hitbox: HitboxComponent = area as HitboxComponent
		health_component.take_damage(hitbox.damage)
