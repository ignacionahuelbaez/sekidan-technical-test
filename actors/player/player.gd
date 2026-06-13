extends CharacterBody2D
class_name Player

const SPEED: float = 150.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: HitboxComponent = $HitboxComponent
@onready var hitbox_shape: CollisionShape2D = $HitboxComponent/CollisionShape2D
@onready var health_component: HealthComponent = $HealthComponent

var current_state: PlayerState
var last_direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	add_to_group("player")

	# La forma de colisión del hitbox arranca apagada.
	# Esto evita que inflija daño solo por estar cerca de un enemigo.
	if hitbox_shape:
		hitbox_shape.disabled = true

	current_state = $States/Idle
	current_state.player = self
	current_state.enter()

	health_component.health_changed.connect(_on_health_changed)
	health_component.health_depleted.connect(_on_death)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func change_state(state_name: String) -> void:
	if current_state:
		current_state.exit()
	current_state = $States.get_node(state_name)
	current_state.player = self
	current_state.enter()

func play_animation(anim_name: String, direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		last_direction = direction
	if sprite.animation != anim_name:
		sprite.play(anim_name)

	if direction.x < 0:
		sprite.flip_h = true
	elif direction.x > 0:
		sprite.flip_h = false

# Elige la animación de ataque según la última dirección
func ejecutar_ataque_direccional() -> void:
	velocity = Vector2.ZERO
	if last_direction.y < -0.1:
		play_animation("attack_up", Vector2.ZERO)
	elif last_direction.y > 0.1:
		play_animation("attack_down", Vector2.ZERO)
	else:
		play_animation("attack", Vector2.ZERO)

# Reacciona a daño no letal con el estado Hurt.
# Si el golpe fue letal, _on_death se encarga de la transición a Dead.
func _on_health_changed(current_health: int) -> void:
	if current_health <= 0:
		return
	change_state("Hurt")

func _on_death() -> void:
	change_state("Dead")	
