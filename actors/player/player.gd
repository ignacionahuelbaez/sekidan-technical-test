class_name Player
extends CharacterBody2D

const SPEED: float = 300.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent

var current_state: PlayerState
var last_direction: Vector2 = Vector2.RIGHT


func _ready() -> void:
	add_to_group("player")
	health_component.health_depleted.connect(_on_health_depleted)
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
	if last_direction.y < -0.1:
		play_animation("attack_up", Vector2.ZERO)
	elif last_direction.y > 0.1:
		play_animation("attack_down", Vector2.ZERO)
	else:
		play_animation("attack", Vector2.ZERO)


func _on_health_depleted() -> void:
	change_state("Dead")
