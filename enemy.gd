class_name Enemy
extends CharacterBody2D

@export var speed: float = 120.0
@export var detection_range: float = 180.0
@export var attack_range: float = 28.0
@export var attack_damage: float = 15.0
@export var max_health: float = 60.0

@onready var health_compon: HealthComponent = $HealthCompon
@onready var hurtbox: HurtboxComponent = $Hurtbox
@onready var hitbox: HitboxComponent = $Hitbox
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSp
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent
@onready var attack_timer: Timer = $Timer

var player: Player = null
var is_attacking: bool = false

func _ready() -> void:
	if not health_compon:
		push_error("Enemy: No se encontró nodo HealthCompon")
		return
	
	health_compon.max_health = max_health
	health_compon.current_health = max_health
	health_compon.health_depleted.connect(_on_health_depleted)
	
	if hurtbox:
		hurtbox.health_component = health_compon
	
	if hitbox:
		hitbox.damage = attack_damage
	
	player = get_tree().get_first_node_in_group("player")
	if not player:
		push_warning("Enemy: No se encontró jugador en grupo 'player'")
	
	if attack_timer:
		attack_timer.wait_time = 1.2
		attack_timer.one_shot = true
		attack_timer.timeout.connect(_on_attack_timer_timeout)


func _physics_process(_delta: float) -> void:
	if not health_compon or health_compon.current_health <= 0 or player == null:
		velocity = Vector2.ZERO
		if animated_sprite:
			animated_sprite.play("idle")
		return

	var distance_to_player: float = global_position.distance_to(player.global_position)
	
	if distance_to_player <= attack_range and not is_attacking:
		_start_attack()
	elif distance_to_player <= detection_range:
		_chase_player()
	else:
		_idle()


func _chase_player() -> void:
	navigation_agent.target_position = player.global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var direction: Vector2 = (next_path_position - global_position).normalized()
	
	velocity = direction * speed
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
	
	if hitbox:
		hitbox.monitoring = true
	
	if attack_timer:
		attack_timer.start()


func _on_attack_timer_timeout() -> void:
	is_attacking = false
	if hitbox:
		hitbox.monitoring = false


func _update_animation(direction: Vector2, anim_name: String) -> void:
	if animated_sprite:
		animated_sprite.play(anim_name)
		if direction.x < 0:
			animated_sprite.flip_h = true
		elif direction.x > 0:
			animated_sprite.flip_h = false


func _on_health_depleted() -> void:
	set_physics_process(false)
	if animated_sprite:
		animated_sprite.play("dead")
	await get_tree().create_timer(1.5).timeout
	queue_free()
