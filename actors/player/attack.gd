extends PlayerState

const HIT_STOP_DURATION: float = 0.08

var _trail: AttackTrail = null
var _hit_stop_applied: bool = false


func enter() -> void:
	player.hitbox_component.monitoring = false
	player.ejecutar_ataque_direccional()
	_hit_stop_applied = false

	# Buscar la estela
	_trail = player.hitbox_component.get_node_or_null("AttackTrail") as AttackTrail

	# Conectar al cambio de frame para activar hitbox y trail en el momento exacto
	player.sprite.frame_changed.connect(_on_frame_changed)

	# Conectar al final de animación para volver a Idle
	player.sprite.animation_finished.connect(_on_animation_finished)


func exit() -> void:
	player.hitbox_component.monitoring = false

	if _trail:
		_trail.deactivate()

	if player.sprite.frame_changed.is_connected(_on_frame_changed):
		player.sprite.frame_changed.disconnect(_on_frame_changed)

	if player.sprite.animation_finished.is_connected(_on_animation_finished):
		player.sprite.animation_finished.disconnect(_on_animation_finished)


func physics_update(_delta: float) -> void:
	pass


func _on_frame_changed() -> void:
	var current_frame: int = player.sprite.frame
	var total_frames: int = player.sprite.sprite_frames.get_frame_count(player.sprite.animation)
	var impact_frame: int = total_frames / 2

	if current_frame == impact_frame:
		player.hitbox_component.monitoring = true
		if _trail:
			_trail.activate()
		if not _hit_stop_applied:
			_hit_stop_applied = true
			_apply_hit_stop()
	elif current_frame > impact_frame:
		player.hitbox_component.monitoring = false


func _on_animation_finished() -> void:
	player.change_state("Idle")


func _apply_hit_stop() -> void:
	Engine.time_scale = 0.0
	var timer: SceneTreeTimer = player.get_tree().create_timer(
		HIT_STOP_DURATION, true, false, true
	)
	timer.timeout.connect(func() -> void: Engine.time_scale = 1.0)
