class_name Player
extends CharacterBody2D

const SPEED: float = 300.0

var current_state: PlayerState

func _ready() -> void:
	current_state = $States/Idle
	current_state.player = self
	current_state.enter()
	$AnimatedSprite2D.play("idle")

func change_state(state_name: String) -> void:
	current_state.exit()
	current_state = $States.get_node(state_name)
	current_state.player = self
	current_state.enter()

func _physics_process(delta: float) -> void:
	current_state.physics_update(delta)
