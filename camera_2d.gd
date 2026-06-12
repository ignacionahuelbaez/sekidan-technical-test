## CameraShake.gd
## Adjuntar este script a la Camera2D principal (res://world/camera_2d.gd o equivalente).
## Sistema de trauma: el trauma decae exponencialmente y el shake es proporcional a trauma².
## Llamar add_trauma(amount) desde cualquier nodo para activar el temblor.
## 
## Uso desde cualquier nodo:
##   var cam := get_viewport().get_camera_2d() as CameraShake
##   cam.add_trauma(0.5)
extends Camera2D
class_name CameraShake

## Velocidad a la que decae el trauma por segundo.
const TRAUMA_DECAY_SPEED: float = 1.5
## Desplazamiento máximo en píxeles durante el shake máximo.
const MAX_OFFSET: float = 12.0
## Rotación máxima en radianes durante el shake máximo.
const MAX_ROTATION_RAD: float = 0.05
## Multiplicador de la frecuencia del ruido Perlin.
const NOISE_SPEED: float = 90.0

var _trauma: float = 0.0
var _noise_time: float = 0.0

@onready var _noise: FastNoiseLite = FastNoiseLite.new()


func _ready() -> void:
	_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	_noise.seed = randi()
	_noise.frequency = 0.5


## Añade trauma al sistema. Clamp entre 0 y 1.
## amount: valor entre 0.0 (nada) y 1.0 (máximo temblor).
func add_trauma(amount: float) -> void:
	_trauma = clampf(_trauma + amount, 0.0, 1.0)


func _process(delta: float) -> void:
	if _trauma <= 0.0:
		offset = Vector2.ZERO
		rotation = 0.0
		return

	_trauma = maxf(_trauma - TRAUMA_DECAY_SPEED * delta, 0.0)
	_noise_time += delta * NOISE_SPEED

	var shake_amount: float = _trauma * _trauma  # Cuadrático = más control

	offset = Vector2(
		MAX_OFFSET * shake_amount * _noise.get_noise_2d(_noise_time, 0.0),
		MAX_OFFSET * shake_amount * _noise.get_noise_2d(0.0, _noise_time)
	)
	rotation = MAX_ROTATION_RAD * shake_amount * _noise.get_noise_2d(_noise_time, _noise_time)
