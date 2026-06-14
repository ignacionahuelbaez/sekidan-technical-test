class_name Player
extends CharacterBody2D

const SPEED: float = 300.0
const SHAKE_STRENGTH: float = 12.0
const SHAKE_DURATION: float = 0.25
const KNOCKBACK_FORCE: float = 250.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var camera: Camera2D = $Camera2D

var current_state: PlayerState
var last_direction: Vector2 = Vector2.RIGHT
var last_attack_index: int = 1


func _ready() -> void:
	add_to_group("player")
	camera.make_current()
	health_component.health_depleted.connect(_on_health_depleted)
	var hurtbox: HurtboxComponent = $HurtboxComponent as HurtboxComponent
	hurtbox.damage_received.connect(_on_damage_received)
	current_state = $States/Idle
	current_state.player = self
	current_state.enter()


func change_state(state_name: String) -> void:
	current_state.exit()
	current_state = $States.get_node(state_name)
	current_state.player = self
	current_state.enter()


func _physics_process(delta: float) -> void:
	current_state.physics_update(delta)


func play_animation(anim_name: String, direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		last_direction = direction
	if sprite.animation != anim_name:
		sprite.play(anim_name)
	if direction.x < 0:
		sprite.flip_h = true
	elif direction.x > 0:
		sprite.flip_h = false


func ejecutar_ataque_direccional() -> void:
	velocity = Vector2.ZERO
	last_attack_index = 2 if last_attack_index == 1 else 1

	var anim_name: String

	if last_direction.y < -0.1:
		anim_name = "attack_up" + str(last_attack_index)
	elif last_direction.y > 0.1:
		anim_name = "attack_down" + str(last_attack_index)
	else:
		anim_name = "attack_" + str(last_attack_index)

	sprite.play(anim_name)


func shake_camera() -> void:
	var tween: Tween = create_tween()
	var steps: int = 8
	var step_duration: float = SHAKE_DURATION / steps

	for i: int in range(steps):
		var decay: float = 1.0 - (float(i) / steps)
		var offset: Vector2 = Vector2(
			randf_range(-SHAKE_STRENGTH, SHAKE_STRENGTH) * decay,
			randf_range(-SHAKE_STRENGTH, SHAKE_STRENGTH) * decay
		)
		tween.tween_property(camera, "offset", offset, step_duration)

	tween.tween_property(camera, "offset", Vector2.ZERO, step_duration)


func _on_damage_received(amount: float, direction: Vector2) -> void:
	health_component.take_damage(amount)
	velocity = direction * KNOCKBACK_FORCE
	shake_camera()
	if current_state != $States/Dead:
		change_state("Hurt")


func _on_health_depleted() -> void:
	change_state("Dead")
