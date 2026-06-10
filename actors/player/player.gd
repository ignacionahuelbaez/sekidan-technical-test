class_name Player
extends CharacterBody2D

const SPEED: float = 300.0

# Creamos una referencia directa al nodo del sprite
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var current_state: PlayerState
# Guardamos la última dirección (por defecto mira hacia la derecha)
var ultima_direccion: Vector2 = Vector2.RIGHT

func _ready() -> void:
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

# === FUNCIÓN DE ANIMACIÓN CORREGIDA ===
func controlar_animacion(nombre_animacion: String, direccion: Vector2) -> void:
	# Si nos están pasando una dirección real de movimiento, la recordamos
	if direccion != Vector2.ZERO:
		ultima_direccion = direccion
	
	if sprite.animation != nombre_animacion:
		sprite.play(nombre_animacion)
	
	# Sincronizado para evitar el crash volteando el sprite horizontalmente
	if direccion.x < 0:
		sprite.flip_h = true
	elif direccion.x > 0:
		sprite.flip_h = false

# === SELECCIÓN DE ATAQUE DIRECCIONAL ===
func ejecutar_ataque_direccional() -> void:
	velocity = Vector2.ZERO
	
	if ultima_direccion.y < -0.1:
		controlar_animacion("attack_up", Vector2.ZERO)
	elif ultima_direccion.y > 0.1:
		controlar_animacion("attack_down", Vector2.ZERO)
	else:
		# Aquí probamos llamando a "attack" en minúscula.
		# (Si notas que no hace nada hacia los lados, cámbialo a "Attack" con la A mayúscula)
		controlar_animacion("attack", Vector2.ZERO)
