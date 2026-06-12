extends CharacterBody2D
class_name Player

#region VARIABLES Y EXPORTS
const SPEED: float = 150.0 # Mantenemos tu constante SPEED en mayúsculas como la buscan tus estados
#endregion

#region REFERENCIAS A NODOS
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: HitboxComponent = $HitboxComponent

var current_state: PlayerState
var last_direction: Vector2 = Vector2.RIGHT
#endregion

#region CICLOS DE VIDA
func _ready() -> void:
	add_to_group("player")
	
	# ¡FUNDAMENTAL! Nos aseguramos de que la espada empiece APAGADA por defecto al iniciar el juego
	if hitbox:
		hitbox.monitoring = false
	
	# Inicialización de tu máquina de estados original
	current_state = $States/Idle
	current_state.player = self
	current_state.enter()

func _physics_process(delta: float) -> void:
	# Volvemos a darle el control a los estados para que te puedas mover, caminar y atacar
	if current_state:
		current_state.physics_update(delta)
#endregion

#region MÉTODOS DE CONTROL Y MÁQUINA DE ESTADOS
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

# Elige la animación de ataque según la última dirección del jugador.
func ejecutar_ataque_direccional() -> void:
	velocity = Vector2.ZERO
	if last_direction.y < -0.1:
		play_animation("attack_up", Vector2.ZERO)
	elif last_direction.y > 0.1:
		play_animation("attack_down", Vector2.ZERO)
	else:
		play_animation("attack", Vector2.ZERO)
#endregion
