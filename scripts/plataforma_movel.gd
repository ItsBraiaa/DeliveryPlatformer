class_name PlataformaMovel
extends AnimatableBody3D

@export var deslocamento: Vector3 = Vector3(3.5, 0.0, 0.0)
@export_range(0.1, 60.0, 0.1, "or_greater") var periodo: float = 4.0

var _origem: Vector3
var _tempo: float = 0.0

func _ready() -> void:
	_origem = global_position

func _physics_process(delta: float) -> void:
	_tempo += delta
	var fator := 0.5 - 0.5 * cos(TAU * _tempo / periodo)
	global_position = _origem + deslocamento * fator
