extends EnemyState

const IMPACT_FRAME: int = 3
const HITBOX_OFFSET_X: float = 35.0


func enter() -> void:
	enemy.velocity = Vector2.ZERO
	enemy.face_player()
	enemy.sprite.play("attack")
	enemy.hitbox_component.set_active(false)
	_update_hitbox_position()
	enemy.sprite.frame_changed.connect(_on_frame_changed)
	enemy.sprite.animation_finished.connect(_on_animation_finished)


func exit() -> void:
	enemy.hitbox_component.set_active(false)

	if enemy.sprite.frame_changed.is_connected(_on_frame_changed):
		enemy.sprite.frame_changed.disconnect(_on_frame_changed)

	if enemy.sprite.animation_finished.is_connected(_on_animation_finished):
		enemy.sprite.animation_finished.disconnect(_on_animation_finished)


func physics_update(_delta: float) -> void:
	pass


func _update_hitbox_position() -> void:
	var offset_x: float = -HITBOX_OFFSET_X if enemy.sprite.flip_h else HITBOX_OFFSET_X
	enemy.hitbox_component.position.x = offset_x


func _on_frame_changed() -> void:
	if enemy.sprite.frame == IMPACT_FRAME:
		enemy.hitbox_component.set_active(true)
	else:
		enemy.hitbox_component.set_active(false)


func _on_animation_finished() -> void:
	if enemy.player_detected and enemy.get_player_distance() <= enemy.ATTACK_RANGE and enemy.attack_timer <= 0.0:
		enemy.attack_timer = enemy.ATTACK_COOLDOWN
		enemy.change_state("Attack")
	else:
		enemy.change_state("Chase")
