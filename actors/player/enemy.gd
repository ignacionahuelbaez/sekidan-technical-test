class_name Enemy
extends CharacterBody2D

const SPEED: float = 80.0
const DETECTION_RANGE: float = 200.0
const ATTACK_RANGE: float = 40.0
const ATTACK_COOLDOWN: float = 1.5

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent

var current_state: EnemyState
var player: Player
var attack_timer: float = 0.0


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Player
	health_component.health_depleted.connect(_on_health_depleted)
	var hurtbox: HurtboxComponent = $HurtboxComponent as HurtboxComponent
	hurtbox.damage_received.connect(_on_damage_received)
	current_state = $States/Patrol
	current_state.enemy = self
	current_state.enter()


func change_state(state_name: String) -> void:
	current_state.exit()
	current_state = $States.get_node(state_name) as EnemyState
	current_state.enemy = self
	current_state.enter()


func _physics_process(delta: float) -> void:
	if attack_timer > 0.0:
		attack_timer -= delta
	current_state.physics_update(delta)


func get_player_distance() -> float:
	if not player:
		return INF
	return global_position.distance_to(player.global_position)


func face_player() -> void:
	if not player:
		return
	sprite.flip_h = player.global_position.x < global_position.x


func _on_damage_received(amount: float) -> void:
	health_component.take_damage(amount)
	if current_state != $States/Dead:
		change_state("Hurt")


func _on_health_depleted() -> void:
	change_state("Dead")
