class_name Pacote
extends ZonaInterativa

signal coletado(pacote: Pacote)
signal devolvido(pacote: Pacote)

@export var velocidade_giro: float = 2.0
@export var destino: IdentidadeEntrega.Destino = IdentidadeEntrega.Destino.LIVRE

var _disponivel: bool = true
var _transform_origem: Transform3D

func _ready() -> void:
	super._ready()
	_transform_origem = global_transform
	if destino != IdentidadeEntrega.Destino.LIVRE:
		$Caixa.material_override = IdentidadeEntrega.material(destino)
		$Luz.light_color = IdentidadeEntrega.cor(destino)

func _process(delta: float) -> void:
	if _disponivel:
		rotate_y(velocidade_giro * delta)

func _ao_jogador_entrar(jogador: Jogador) -> void:
	if not _disponivel:
		return
	_disponivel = false
	hide()
	set_deferred("monitoring", false)
	jogador.coletar_pacote(self)
	coletado.emit(self)

func devolver_a_origem() -> void:
	global_transform = _transform_origem
	_disponivel = true
	show()
	set_deferred("monitoring", true)
	devolvido.emit(self)
