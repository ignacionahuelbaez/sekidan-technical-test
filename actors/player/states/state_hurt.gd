class_name StateHurt
extends PlayerState

func enter() -> void:
	player.velocity = Vector2.ZERO
	player.play_animation("idle", Vector2.ZERO)
	player.sprite.modulate = Color(2.0, 0.5, 0.5, 1.0)
	get_tree().create_timer(0.3).timeout.connect(_on_hurt_finished)

func physics_update(_delta: float) -> void:
	pass

func _on_hurt_finished() -> void:
	player.sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
	player.change_state("Idle")
