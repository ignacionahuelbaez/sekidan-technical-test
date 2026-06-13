extends EnemyState


func enter() -> void:
	enemy.velocity = Vector2.ZERO
	enemy.set_physics_process(false)
	enemy.hitbox_component.monitoring = false
	enemy.sprite.play("dead")

	var hurtbox: HurtboxComponent = enemy.get_node("HurtboxComponent") as HurtboxComponent
	hurtbox.disable()

	var collision: CollisionShape2D = enemy.get_node("CollisionShape2D") as CollisionShape2D
	collision.set_deferred("disabled", true)
