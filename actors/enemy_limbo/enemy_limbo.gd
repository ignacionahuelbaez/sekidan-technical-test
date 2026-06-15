extends CharacterBody2D
class_name EnemyLimbo

const FLASH_COLOR: Color = Color(5.0, 0.3, 0.3, 1.0)
const FLASH_DURATION: float = 0.1
const LOW_HEALTH_THRESHOLD: float = 0.3  # 30% de vida restante

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var detection_range: Area2D = $DetectionRange
@onready var bt_player_node: BTPlayer = $BTPlayer
@onready var body_collision: CollisionShape2D = $CollisionShape2D
@onready var hurtbox_collision: CollisionShape2D = $HurtboxComponent/CollisionShape2D
@onready var hitbox_collision: CollisionShape2D = $HitboxComponent/CollisionShape2D
@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer
@onready var audio_hurt: AudioStreamPlayer2D = $HurtboxComponent/AudioHurt
@onready var audio_death: AudioStreamPlayer2D = $AudioDeath

# Expuesto para que las tareas del BT puedan leerlo
var player_ref: CharacterBody2D = null
var is_dead: bool = false
var is_hurting: bool = false

func _ready() -> void:
	hitbox_component.set_active(false)
	health_component.health_changed.connect(_on_health_changed)
	health_component.health_depleted.connect(_on_death)
	hurtbox_component.damage_received.connect(_on_damage_received)
	detection_range.body_entered.connect(_on_detection_body_entered)
	detection_range.body_exited.connect(_on_detection_body_exited)

func _physics_process(_delta: float) -> void:
	if is_dead:
		return
	if is_hurting:
		velocity = Vector2.ZERO
		return
	move_and_slide()

# Las tareas del BT llaman esto para saber si deben activar la huida
func is_low_health() -> bool:
	return health_component.current_health / health_component.max_health <= LOW_HEALTH_THRESHOLD

func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_ref = body as CharacterBody2D

func _on_detection_body_exited(body: Node2D) -> void:
	if body == player_ref:
		player_ref = null

func _on_damage_received(amount: float, _direction: Vector2) -> void:
	if is_dead:
		return
	health_component.take_damage(amount)

func _on_health_changed(_new_health: float) -> void:
	if is_dead:
		return
	is_hurting = true
	animated_sprite.modulate = FLASH_COLOR
	if audio_hurt.stream:
		audio_hurt.play()
	var tween: Tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color.WHITE, FLASH_DURATION)
	tween.finished.connect(func() -> void: is_hurting = false)

func _on_death() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	bt_player_node.set_active(false)
	hitbox_component.set_active(false)
	body_collision.set_deferred("disabled", true)
	hurtbox_collision.set_deferred("disabled", true)
	hitbox_collision.set_deferred("disabled", true)
	animated_sprite.play("dead")
	if audio_death.stream:
		audio_death.play()
