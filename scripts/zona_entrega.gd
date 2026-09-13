class_name ZonaEntrega
extends ZonaInterativa

signal entrega_realizada(zona: ZonaEntrega)
signal entrega_recusada(zona: ZonaEntrega)

@export var destino: IdentidadeEntrega.Destino = IdentidadeEntrega.Destino.LIVRE
@export var telhado_nevado: bool = false
@export_range(0.0, 1.0) var intensidade_marcador: float = 1.0

var _ativa: bool = true

@onready var _luz: OmniLight3D = $Luz
@onready var _marcador: MeshInstance3D = $Marcador

func _ready() -> void:
	super._ready()
	_luz.light_energy *= intensidade_marcador
	if destino != IdentidadeEntrega.Destino.LIVRE:
		$Casa/Paredes.material_override = IdentidadeEntrega.material(destino)
		var material := IdentidadeEntrega.material(destino)
		material.emission_enabled = true
		material.emission = IdentidadeEntrega.cor(destino)
		material.emission_energy_multiplier = 0.5 * intensidade_marcador
		_marcador.material_override = material
		_luz.light_color = IdentidadeEntrega.cor(destino)
	if telhado_nevado:
		var neve := StandardMaterial3D.new()
		neve.albedo_color = Color(0.94, 0.97, 1.0)
		neve.roughness = 0.95
		$Casa/Telhado.material_override = neve

func _ao_jogador_entrar(jogador: Jogador) -> void:
	if not _ativa or not jogador.carregando_pacote:
		return
	if not jogador.entregar_pacote(destino):
		entrega_recusada.emit(self)
		return
	_ativa = false
	_marcar_concluida()
	entrega_realizada.emit(self)

func _marcar_concluida() -> void:
	if destino != IdentidadeEntrega.Destino.LIVRE:
		var concluido := StandardMaterial3D.new()
		concluido.albedo_color = Color(0.55, 0.61, 0.66)
		_marcador.material_override = concluido
		_luz.light_energy = 0.0
		$Rotulo.text = "ENTREGUE"
		$Rotulo.show()
		return
	_luz.light_color = Color(0.35, 1.0, 0.45)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.3, 0.85, 0.4)
	material.emission_enabled = true
	material.emission = Color(0.15, 0.6, 0.25)
	_marcador.material_override = material
