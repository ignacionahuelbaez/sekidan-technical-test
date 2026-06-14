extends PlayerState

const HIT_STOP_DURATION: float = 0.08
const HITBOX_OFFSET: float = 30.0

var _trail: AttackTrail = null
var _hit_stop_applied: bool = false


func enter() -> void:
	player.hitbox_component.set_active(false)
	player.ejecutar_ataque_direccional()
	_hit_stop_applied = false
	_update_hitbox_position()

	_trail = player.hitbox_component.get_node_or_null("AttackTrail") as AttackTrail

	player.sprite.frame_changed.connect(_on_frame_changed)
	player.sprite.animation_finished.connect(_on_animation_finished)
	player.hitbox_component.hit_landed.connect(_on_hit_landed)


func exit() -> void:
	player.hitbox_component.set_active(false)

	if _trail:
		_trail.deactivate()

	if player.sprite.frame_changed.is_connected(_on_frame_changed):
		player.sprite.frame_changed.disconnect(_on_frame_changed)

	if player.sprite.animation_finished.is_connected(_on_animation_finished):
		player.sprite.animation_finished.disconnect(_on_animation_finished)

	if player.hitbox_component.hit_landed.is_connected(_on_hit_landed):
		player.hitbox_component.hit_landed.disconnect(_on_hit_landed)


func physics_update(_delta: float) -> void:
	pass


func _update_hitbox_position() -> void:
	var direction: Vector2 = player.last_direction

	if direction.y < -0.1:
		player.hitbox_component.position = Vector2(0, -HITBOX_OFFSET)
	elif direction.y > 0.1:
		player.hitbox_component.position = Vector2(0, HITBOX_OFFSET)
	elif direction.x < 0.0:
		player.hitbox_component.position = Vector2(-HITBOX_OFFSET, 0)
	else:
		player.hitbox_component.position = Vector2(HITBOX_OFFSET, 0)


func _on_frame_changed() -> void:
	var current_frame: int = player.sprite.frame
	var total_frames: int = player.sprite.sprite_frames.get_frame_count(player.sprite.animation)
	var impact_frame: int = int(total_frames / 2.0)

	if current_frame == impact_frame:
		player.hitbox_component.set_active(true)
		if _trail:
			_trail.activate()
		if not _hit_stop_applied:
			_hit_stop_applied = true
			_apply_hit_stop()
	else:
		player.hitbox_component.set_active(false)


func _on_animation_finished() -> void:
	player.change_state("Idle")


func _on_hit_landed() -> void:
	player.shake_camera()


func _apply_hit_stop() -> void:
	Engine.time_scale = 0.0
	var timer: SceneTreeTimer = player.get_tree().create_timer(
		HIT_STOP_DURATION, true, false, true
	)
	timer.timeout.connect(func() -> void: Engine.time_scale = 1.0)
