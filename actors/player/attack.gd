extends PlayerState

@onready var attack_trail: AttackTrail = player.hitbox_component.get_node("AttackTrail")


func enter() -> void:
	player.hitbox_component.monitoring = true
	player.ejecutar_ataque_direccional()
	attack_trail.emit()
	player.sprite.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)


func exit() -> void:
	player.hitbox_component.monitoring = false


func _on_animation_finished() -> void:
	player.change_state("Idle")
