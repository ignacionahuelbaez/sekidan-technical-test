class_name Player
extends CharacterBody2D

const SPEED: float = 300.0

# Creamos una referencia directa al nodo del sprite
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var current_state: PlayerState

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

# === ESTA FUNCIÓN ES LA SOLUCIÓN DEFINTIVA ===
func controlar_animacion(nombre_animacion: String, direccion: Vector2) -> void:
	# FUNDAMENTO: Solo le damos .play() si la animación nueva es DISTINTA a la que ya se está reproduciendo.
	# Esto evita que se congele en el frame 1.
	if sprite.animation != nombre_animacion:
		sprite.play(nombre_animacion)
	
	# Aprovechamos de una vez para voltear el personaje a la izquierda o derecha
	if direccion.x < 0:
		sprite.flip_h = true
	elif direction.x > 0:
		sprite.flip_h = false
