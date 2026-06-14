class_name HurtboxComponent
extends Area2D

signal damage_received(amount: float, direction: Vector2)

var is_active: bool = true


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if not is_active:
		return
	if not area is HitboxComponent:
		return
	var hitbox: HitboxComponent = area as HitboxComponent
	if hitbox.owner == owner:
		return
	var direction: Vector2 = (global_position - hitbox.global_position).normalized()
	damage_received.emit(hitbox.damage, direction)


func disable() -> void:
	is_active = false


func enable() -> void:
	is_active = true
