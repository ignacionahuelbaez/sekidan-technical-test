class_name Enemy
extends CharacterBody2D

const SPEED: float = 80.0
const DETECTION_RANGE: float = 200.0
const ATTACK_RANGE: float = 40.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var player: Player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	if not player:
		return

	var dist: float = global_position.distance_to(player.global_position)

	if dist <= ATTACK_RANGE:
		_idle()
	elif dist <= DETECTION_RANGE:
		_chase()
	else:
		_idle()

func _chase() -> void:
	var direction: Vector2 = (player.global_position - global_position).normalized()
	velocity = direction * SPEED
	move_and_slide()
	animated_sprite.play("walk")
	animated_sprite.flip_h = direction.x < 0

func _idle() -> void:
	velocity = Vector2.ZERO
	animated_sprite.play("idle")
