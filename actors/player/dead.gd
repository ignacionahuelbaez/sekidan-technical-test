extends PlayerState


func enter() -> void:
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)
	player.play_animation("dead", Vector2.ZERO)

	var hurtbox: HurtboxComponent = player.get_node("HurtboxComponent") as HurtboxComponent
	hurtbox.disable()

	var collision: CollisionShape2D = player.get_node("CollisionShape2D") as CollisionShape2D
	collision.set_deferred("disabled", true)
