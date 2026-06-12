extends CharacterBody2D
class_name Enemy

#region VARIABLES Y CONFIGURACIÓN
@export var speed: float = 100.0

var is_dead: bool = false
var is_hurting: bool = false
#endregion

#region REFERENCIAS A NODOS (Árbol de Godot)
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var bt_player: BTPlayer = $BTPlayer
@onready var hitbox_component: HitboxComponent = $HitboxComponent

# Colisiones que se desactivan al morir
@onready var body_collision: CollisionShape2D = $CollisionShape2D
@onready var hurtbox_collision: CollisionShape2D = $HurtboxComponent/CollisionShape2D
@onready var hitbox_collision: CollisionShape2D = $HitboxComponent/CollisionShape2D
#endregion

#region CICLOS DE VIDA
func _ready() -> void:
	if health_component:
		health_component.health_changed.connect(_on_health_changed)
		health_component.death.connect(_on_death)

	# Asegurar que el hitbox empiece desactivado
	if hitbox_component:
		hitbox_component.monitoring = false
		hitbox_component.monitorable = true

func _physics_process(_delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		if animated_sprite and animated_sprite.animation != "dead":
			animated_sprite.play("dead")
		return

	if is_hurting:
		velocity = Vector2.ZERO
		return

	move_and_slide()
#endregion

#region REACCIÓN A DAÑO (Flash de Color)
func _on_health_changed(current_health: int) -> void:
	if is_dead or current_health <= 0:
		return

	is_hurting = true

	if animated_sprite:
		animated_sprite.modulate = Color(5.0, 0.3, 0.3, 1.0)

		var tween = create_tween()
		tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.1)

		tween.finished.connect(func(): is_hurting = false)

#region SISTEMA DE MUERTE
func _on_death() -> void:
	if is_dead:
		return
	is_dead = true

	if bt_player:
		bt_player.set_active(false)

	# Desactivar colisiones
	if body_collision:
		body_collision.set_deferred("disabled", true)
	if hurtbox_collision:
		hurtbox_collision.set_deferred("disabled", true)
	if hitbox_collision:
		hitbox_collision.set_deferred("disabled", true)

	# Desactivar monitoreo del hitbox
	if hitbox_component:
		hitbox_component.monitoring = false

	if animated_sprite and animated_sprite.sprite_frames.has_animation("dead"):
		animated_sprite.play("dead")
