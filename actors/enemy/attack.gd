extends EnemyState

const FLASH_COLOR: Color = Color(5.0, 0.3, 0.3, 1.0)
const NORMAL_COLOR: Color = Color.WHITE


func enter() -> void:
	enemy.velocity = Vector2.ZERO
	enemy.face_player()
	enemy.sprite.play("attack")
	enemy.hitbox_component.monitoring = true
	enemy.sprite.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)


func exit() -> void:
	enemy.hitbox_component.monitoring = false


func physics_update(_delta: float) -> void:
	pass


func _on_animation_finished() -> void:
	if enemy.get_player_distance() <= enemy.ATTACK_RANGE and enemy.attack_timer <= 0.0:
		enemy.attack_timer = enemy.ATTACK_COOLDOWN
		enemy.change_state("Attack")
	else:
		enemy.change_state("Chase")
