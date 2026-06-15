@tool
class_name BTActionAttack
extends BTAction

const ATTACK_COOLDOWN: float = 1.5
const IMPACT_FRAME: int = 3
const HITBOX_OFFSET_X: float = 35.0

var _can_attack: bool = true
var _hitbox_activated: bool = false

func _enter() -> void:
	if not _can_attack:
		return
	var enemy: EnemyLimbo = agent as EnemyLimbo
	if enemy == null:
		return
	_hitbox_activated = false
	enemy.velocity = Vector2.ZERO
	enemy.animated_sprite.play("attack")
	if not enemy.animated_sprite.frame_changed.is_connected(_on_frame_changed):
		enemy.animated_sprite.frame_changed.connect(_on_frame_changed)

func _exit() -> void:
	var enemy: EnemyLimbo = agent as EnemyLimbo
	if enemy == null:
		return
	enemy.hitbox_component.set_active(false)
	_hitbox_activated = false
	if enemy.animated_sprite.frame_changed.is_connected(_on_frame_changed):
		enemy.animated_sprite.frame_changed.disconnect(_on_frame_changed)

func _tick(_delta: float) -> Status:
	if not _can_attack:
		return FAILURE
	var enemy: EnemyLimbo = agent as EnemyLimbo
	if enemy == null:
		return FAILURE
	enemy.velocity = Vector2.ZERO
	if not enemy.animated_sprite.is_playing():
		_can_attack = false
		enemy.get_tree().create_timer(ATTACK_COOLDOWN).timeout.connect(
			func() -> void: _can_attack = true
		)
		return SUCCESS
	return RUNNING

func _on_frame_changed() -> void:
	var enemy: EnemyLimbo = agent as EnemyLimbo
	if enemy == null or _hitbox_activated:
		return
	if enemy.animated_sprite.frame == IMPACT_FRAME:
		_hitbox_activated = true
		var hitbox_col: CollisionShape2D = enemy.hitbox_component.get_node("CollisionShape2D") as CollisionShape2D
		if hitbox_col:
			hitbox_col.position.x = -HITBOX_OFFSET_X if enemy.animated_sprite.flip_h else HITBOX_OFFSET_X
		enemy.hitbox_component.set_active(true)
