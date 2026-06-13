extends EnemyState

const FLASH_COLOR: Color = Color(5.0, 0.3, 0.3, 1.0)
const NORMAL_COLOR: Color = Color.WHITE
const HURT_DURATION: float = 0.3


func enter() -> void:
	enemy.velocity = Vector2.ZERO
	enemy.hitbox_component.monitoring = false

	var tween: Tween = enemy.create_tween()
	enemy.sprite.modulate = FLASH_COLOR
	tween.tween_property(enemy.sprite, "modulate", NORMAL_COLOR, HURT_DURATION)

	var timer: SceneTreeTimer = enemy.get_tree().create_timer(HURT_DURATION)
	timer.timeout.connect(_on_hurt_finished)


func exit() -> void:
	enemy.sprite.modulate = NORMAL_COLOR


func physics_update(_delta: float) -> void:
	pass


func _on_hurt_finished() -> void:
	if enemy.current_state == self:
		enemy.change_state("Chase")
