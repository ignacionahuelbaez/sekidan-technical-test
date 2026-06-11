extends CharacterBody2D
class_name Player

@export var speed: float = 150.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var health_component = $HealthComponent
@onready var hitbox_component = $HitboxComponent

var is_attacking: bool = false

func _ready() -> void:
	add_to_group("player")
	# Validación segura para que no crashee si te falta el componente de vida
	if health_component and health_component.has_signal("health_depleted"):
		health_component.connect("health_depleted", Callable(self, "_on_death"))

func _physics_process(_delta: float) -> void:
	if is_attacking:
		return

	# Movimiento en 4 direcciones nativo de Godot 4
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()

	# Usamos ui_accept (Espacio/Enter) para atacar por defecto y evitar errores de InputMap
	if Input.is_action_just_pressed("ui_accept"):
		_perform_attack()
	else:
		_update_animations()

func _update_animations() -> void:
	if not animated_sprite:
		return
		
	if velocity.length() > 0:
		animated_sprite.play("walk")
		if velocity.x != 0:
			animated_sprite.flip_h = velocity.x < 0
	else:
		animated_sprite.play("idle")

func _perform_attack() -> void:
	if not animated_sprite:
		return
		
	is_attacking = true
	velocity = Vector2.ZERO
	animated_sprite.play("attack")
	
	# Activa el área de daño si tenés el componente
	if hitbox_component:
		hitbox_component.set_deferred("monitoring", true)

	await animated_sprite.animation_finished
	
	if hitbox_component:
		hitbox_component.set_deferred("monitoring", false)
	is_attacking = false

func _on_death() -> void:
	set_physics_process(false)
	if animated_sprite:
		animated_sprite.play("dead")
