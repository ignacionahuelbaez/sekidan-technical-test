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

	# La forma de colisión del hitbox arranca apagada
	if hitbox_shape:
		hitbox_shape.disabled = true

	# Estado inicial
	current_state = $States/Idle
	current_state.player = self
	current_state.enter()

	# Conectar señales del componente de salud
	if health_component:
		health_component.health_changed.connect(_on_health_changed)
		health_component.death.connect(_on_death)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func change_state(state_name: String) -> void:
	# Validar transiciones prohibidas
	if current_state is StateDead:
		# Si ya está muerto, no cambiar a ningún otro estado
		return
	if current_state is StateHurt and state_name == "Attack":
		# No puede atacar mientras está herido
		return
	if current_state is StateAttack and state_name == "Hurt":
		# No interrumpir ataque con daño (opcional, se puede permitir)
		return

	if current_state:
		current_state.exit()

	var new_state_node = $States.get_node(state_name)
	if not new_state_node:
		push_error("Estado no encontrado: ", state_name)
		return

	current_state = new_state_node
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


func ejecutar_ataque_direccional() -> void:
	velocity = Vector2.ZERO
	if last_direction.y < -0.1:
		play_animation("attack_up", Vector2.ZERO)
	elif last_direction.y > 0.1:
		play_animation("attack_down", Vector2.ZERO)
	else:
		play_animation("attack", Vector2.ZERO)


# ============================================================
# REACCIÓN AL DAÑO Y MUERTE
# ============================================================

func _on_health_changed(current_health: int) -> void:
	# Si ya está muerto, ignorar
	if current_state is StateDead:
		return

	# Si la vida es mayor a 0, entrar en estado Hurt
	if current_health > 0:
		# No interrumpir el ataque si ya está atacando
		if not (current_state is StateAttack):
			change_state("Hurt")
	# Nota: la muerte se maneja en _on_death


func _on_death() -> void:
	if current_state is StateDead:
		return
	change_state("dead")  # El nodo se llama "dead" (minúscula)
