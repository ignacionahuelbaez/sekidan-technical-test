class_name Player
extends CharacterBody2D

const SPEED: float = 300.0

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

# Corregido: Parámetro en inglés (direction) y tipado estricto (: void)
func controlar_animacion(nombre_animacion: String, direction: Vector2) -> void:
	if sprite.animation != nombre_animacion:
		sprite.play(nombre_animacion)
	
	if direction.x < 0:
		sprite.flip_h = true
	elif direction.x > 0:
		sprite.flip_h = false
