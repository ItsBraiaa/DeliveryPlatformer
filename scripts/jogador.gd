class_name Jogador
extends CharacterBody3D

signal reapareceu

@export var velocidade: float = 6.5
@export var forca_pulo: float = 8.5
@export var gravidade: float = 20.0
@export var sensibilidade_mouse: float = 0.003
@export var aceleracao_gelo: float = 8.0
@export var frenagem_gelo: float = 3.5
@export var usar_lanterna: bool = false

var carregando_pacote: bool:
	get:
		return not _pacotes_carregados.is_empty()
var _pacotes_carregados: Array[Pacote] = []
var _visuais_pilha: Array[MeshInstance3D] = []
var _ultimo_respawn: int = -1
var _ponto_respawn: Vector3
var _movimento_gelo: bool = false

@onready var _pivo_camera: Node3D = $PivoCamera
@onready var _braco_camera: SpringArm3D = $PivoCamera/BracoCamera
@onready var _visual: Node3D = $Visual
@onready var _pacote_visual: MeshInstance3D = $Visual/Mochila/PacoteVisual

func _ready() -> void:
	_ponto_respawn = global_position
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if usar_lanterna:
		var lanterna := preload("res://scenes/lanterna.tscn").instantiate()
		$PivoCamera/BracoCamera/Camera.add_child(lanterna)
		for malha: MeshInstance3D in _visual.find_children("*", "MeshInstance3D", true, false):
			malha.layers = 2
			malha.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _unhandled_input(evento: InputEvent) -> void:
	if evento is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var movimento := evento as InputEventMouseMotion
		_pivo_camera.rotate_y(-movimento.screen_relative.x * sensibilidade_mouse)
		_braco_camera.rotation.x = clampf(
			_braco_camera.rotation.x - movimento.screen_relative.y * sensibilidade_mouse,
			deg_to_rad(-70.0), deg_to_rad(-5.0))

func _physics_process(delta: float) -> void:
	if is_on_floor():
		_movimento_gelo = _esta_sobre_gelo()
		if Input.is_action_just_pressed("pular"):
			velocity.y = forca_pulo
			Audio.tocar("pulo")
	else:
		velocity.y -= gravidade * delta

	var entrada := Input.get_vector("mover_esquerda", "mover_direita", "mover_frente", "mover_tras")
	var base := Basis(Vector3.UP, _pivo_camera.rotation.y)
	var direcao := (base * Vector3(entrada.x, 0.0, entrada.y)).normalized()
	if _movimento_gelo:
		var horizontal := Vector2(velocity.x, velocity.z)
		var alvo := Vector2(direcao.x, direcao.z) * velocidade
		var taxa := aceleracao_gelo if direcao != Vector3.ZERO else frenagem_gelo
		horizontal = horizontal.move_toward(alvo, taxa * delta)
		velocity.x = horizontal.x
		velocity.z = horizontal.y
	elif direcao != Vector3.ZERO:
		velocity.x = direcao.x * velocidade
		velocity.z = direcao.z * velocidade
	else:
		velocity.x = move_toward(velocity.x, 0.0, velocidade)
		velocity.z = move_toward(velocity.z, 0.0, velocidade)
	if direcao != Vector3.ZERO:
		_visual.rotation.y = lerp_angle(_visual.rotation.y, atan2(-direcao.x, -direcao.z), 12.0 * delta)

	move_and_slide()

func _esta_sobre_gelo() -> bool:
	var consulta := PhysicsRayQueryParameters3D.create(
		global_position + up_direction * 0.2,
		global_position - up_direction * 0.3, collision_mask, [get_rid()])
	var resultado := get_world_3d().direct_space_state.intersect_ray(consulta)
	if not resultado.is_empty():
		var piso_atual := resultado["collider"] as Node
		return piso_atual != null and piso_atual.is_in_group("gelo")
	for i in range(get_slide_collision_count()):
		var colisao := get_slide_collision(i)
		if colisao.get_normal().dot(up_direction) >= cos(floor_max_angle):
			var piso := colisao.get_collider() as Node
			if piso != null:
				return piso.is_in_group("gelo")
	return _movimento_gelo

func destino_carregado() -> IdentidadeEntrega.Destino:
	if carregando_pacote:
		return _pacotes_carregados.back().destino
	return IdentidadeEntrega.Destino.LIVRE

func coletar_pacote(pacote: Pacote) -> void:
	if _pacotes_carregados.has(pacote):
		return
	_pacotes_carregados.append(pacote)
	_atualizar_pilha()

func entregar_pacote(destino: IdentidadeEntrega.Destino = IdentidadeEntrega.Destino.LIVRE) -> bool:
	for i in range(_pacotes_carregados.size() - 1, -1, -1):
		var pacote := _pacotes_carregados[i]
		if destino == IdentidadeEntrega.Destino.LIVRE or pacote.destino == destino:
			_pacotes_carregados.remove_at(i)
			pacote.queue_free()
			_atualizar_pilha()
			return true
	return false

func reaparecer() -> void:
	var quadro := Engine.get_physics_frames()
	if get_tree().paused or _ultimo_respawn == quadro:
		return
	_ultimo_respawn = quadro
	_movimento_gelo = false
	global_position = _ponto_respawn
	velocity = Vector3.ZERO
	var devolvidos := _pacotes_carregados.duplicate()
	_pacotes_carregados.clear()
	_atualizar_pilha()
	for pacote: Pacote in devolvidos:
		pacote.devolver_a_origem()
	reapareceu.emit()

func _atualizar_pilha() -> void:
	if _visuais_pilha.is_empty():
		_visuais_pilha.append(_pacote_visual)
	while _visuais_pilha.size() < _pacotes_carregados.size():
		var visual := _pacote_visual.duplicate() as MeshInstance3D
		_pacote_visual.get_parent().add_child(visual)
		visual.position = _pacote_visual.position + Vector3.UP * 0.4 * _visuais_pilha.size()
		_visuais_pilha.append(visual)
	for i in range(_visuais_pilha.size()):
		var visual := _visuais_pilha[i]
		visual.visible = i < _pacotes_carregados.size()
		if visual.visible:
			visual.material_override = IdentidadeEntrega.material(_pacotes_carregados[i].destino)
