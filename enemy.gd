class_name Enemy
extends CharacterBody2D

@export var speed: float = 120.0
@export var detection_range: float = 200.0
@export var attack_range: float = 32.0
@export var attack_damage: float = 15.0
@export var max_health: float = 60.0

@onready var health_compon: HealthComponent = $HealthComponent
@onready var hurtbox: HurtboxComponent = $HurtboxComponent
@onready var hitbox: HitboxComponent = $HitboxComponent
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $Timer

var player: Player = null
var is_attacking: bool = false

func _ready() -> void:
	if health_compon:
		health_compon.max_health = max_health
		health_compon.current_health = max_health
		health_compon.health_depleted.connect(_on_health_depleted)
	
	if hitbox:
		hitbox.damage = attack_damage
		hitbox.monitoring = false
	
	player = get_tree().get_first_node_in_group("player")
	if not player:
		push_warning("Enemy: No se encontró jugador en grupo 'player'")
	
	if attack_timer:
		attack_timer.wait_time = 1.2
		attack_timer.one_shot = true
		attack_timer.timeout.connect(_on_attack_timer_timeout)


func _physics_process(_delta: float) -> void:
	if not player or (health_compon and health_compon.current_health <= 0):
		_idle()
		return
	
	var distance: float = global_position.distance_to(player.global_position)
	
	if distance <= attack_range and not is_attacking:
		_start_attack()
	elif distance <= detection_range:
		_chase_player()
	else:
		_idle()


func _chase_player() -> void:
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	
	# Debug
	print("Persiguiendo | Distancia: ", global_position.distance_to(player.global_position), " | Vel: ", velocity.length())
	
	move_and_slide()
	_update_animation(direction, "walk")


func _idle() -> void:
	velocity = Vector2.ZERO
	if animated_sprite:
		animated_sprite.play("idle")


func _start_attack() -> void:
	is_attacking = true
	velocity = Vector2.ZERO
	
	if animated_sprite:
		animated_sprite.play("attack")
	
	# Timing del daño
	if hitbox:
		hitbox.monitoring = false
	
	await get_tree().create_timer(0.4).timeout
	
	if hitbox and is_attacking:
		hitbox.monitoring = true
	
	await get_tree().create_timer(0.25).timeout
	if hitbox:
		hitbox.monitoring = false
	
	if animated_sprite:
		await animated_sprite.animation_finished
	
	_end_attack()


func _end_attack() -> void:
	is_attacking = false
	if attack_timer:
		attack_timer.start()


func _update_animation(direction: Vector2, anim: String) -> void:
	if animated_sprite:
		animated_sprite.play(anim)
		if direction.x < 0:
			animated_sprite.flip_h = true
		else:
			animated_sprite.flip_h = false


func _on_health_depleted() -> void:
	set_physics_process(false)
	if animated_sprite:
		animated_sprite.play("dead")
	await get_tree().create_timer(1.5).timeout
	queue_free()


func _on_attack_timer_timeout() -> void:
	pass
