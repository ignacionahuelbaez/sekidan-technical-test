extends CharacterBody2D
class_name Enemy

#region VARIABLES Y CONFIGURACIÓN
@export var speed: float = 100.0

var is_dead: bool = false
var is_hurting: bool = false
#endregion

#region REFERENCIAS A NODOS (Árbol de Godot)
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component = $HealthComponent

# Colisiones que vamos a apagar al morir
@onready var body_collision: CollisionShape2D = $CollisionShape2D
@onready var hurtbox_collision: CollisionShape2D = $HurtboxComponent/CollisionShape2D
@onready var hitbox_collision: CollisionShape2D = $HitboxComponent/CollisionShape2D
#endregion

#region CICLOS DE VIDA
func _ready() -> void:
	# Conectamos el fin de animación para limpiar el estado de daño
	if animated_sprite:
		if not animated_sprite.animation_finished.is_connected(_on_animation_finished):
			animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(_delta: float) -> void:
	# Si está muerto o sufriendo daño, congelamos su movimiento por completo
	if is_dead or is_hurting:
		velocity = Vector2.ZERO
		return
		
	# Tu lógica de movimiento/Behavior Tree va acá abajo
	move_and_slide()
#endregion

#region INTERFAZ DE DAÑO Y MUERTE (Llamadas Directas)
## Esta función es llamada directamente por la Hurtbox cuando el jugador te ataca
func recibir_danio() -> void:
	if is_dead:
		return
		
	# Verificamos primero si el componente de vida dice que ya no queda salud
	if health_component:
		# Modificá 'health' o 'current_health' según como se llame la variable en tu HealthComponent
		if health_component.health <= 0:
			ejecutar_muerte()
			return
			
	# Si sobrevivió al golpe, hace la animación de daño
	ejecutar_danio()

func ejecutar_danio() -> void:
	if is_hurting:
		return
	is_hurting = true
	
	# Cambiá "hurt" por el nombre exacto de tu animación de daño
	if animated_sprite and animated_sprite.sprite_frames.has_animation("hurt"):
		animated_sprite.play("hurt")
	else:
		# Si no encuentra la animación, quitamos el candado para que no se quede congelado
		is_hurting = false 

func ejecutar_muerte() -> void:
	if is_dead:
		return
	is_dead = true
	
	# 1. Apagamos de forma segura TODAS las colisiones de inmediato
	if body_collision:
		body_collision.set_deferred("disabled", true)
	if hurtbox_collision:
		hurtbox_collision.set_deferred("disabled", true)
	if hitbox_collision:
		hitbox_collision.set_deferred("disabled", true)
		
	# 2. Ejecutamos la animación del cráneo enterrado. Cambiá "death" por tu animación real.
	if animated_sprite and animated_sprite.sprite_frames.has_animation("death"):
		animated_sprite.play("death")
#endregion

#region CONTROL DE ANIMACIONES
func _on_animation_finished() -> void:
	# Cuando termina la animación de daño, puede volver a moverse
	if animated_sprite and animated_sprite.animation == "hurt":
		is_hurting = false
#endregion
