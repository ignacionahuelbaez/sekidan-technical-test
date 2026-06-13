extends EnemyState


func enter() -> void:
	enemy.sprite.play("walk")


func physics_update(_delta: float) -> void:
	if enemy.get_player_distance() > enemy.DETECTION_RANGE:
		enemy.change_state("Patrol")
		return

	if enemy.get_player_distance() <= enemy.ATTACK_RANGE:
		enemy.change_state("Attack")
		return

	var direction: Vector2 = (enemy.player.global_position - enemy.global_position).normalized()
	enemy.velocity = direction * enemy.SPEED
	enemy.move_and_slide()
	enemy.face_player()
	enemy.sprite.play("walk")
