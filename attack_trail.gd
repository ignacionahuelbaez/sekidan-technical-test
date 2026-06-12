extends GPUParticles2D
class_name AttackTrail

var _active: bool = false


func _ready() -> void:
	emitting = false
	one_shot = true
	local_coords = false


func activate() -> void:
	if _active:
		return
	_active = true
	restart()
	emitting = true


func deactivate() -> void:
	_active = false
	emitting = false
