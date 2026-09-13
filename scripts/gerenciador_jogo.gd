class_name GerenciadorJogo
extends Node3D

signal jogo_terminou(vitoria: bool)

@export_range(1.0, 3600.0, 1.0, "or_greater") var tempo_limite: float = 180.0
@export var nome_nivel: String = "Nível 1"
@export var dica_inicial: String = "Pegue um pacote!"
@export var mostrar_dicas: bool = true
@export var ocultar_dicas_apos_coleta: bool = false
@export_range(0, 99, 1) var vidas_iniciais: int = 0
@export_file("*.tscn") var proximo_nivel: String = ""

var _entregas: int = 0
var _total_entregas: int = 0
var _partida_terminada: bool = false
var _vidas: int = 0

@onready var _hud: HUD = $InterfaceJogo/HUD
@onready var _cronometro: Timer = $Cronometro

func _ready() -> void:
	_vidas = vidas_iniciais
	_hud.atualizar_vidas(_vidas, vidas_iniciais > 0)
	$Jogador.reapareceu.connect(_ao_reaparecer)
	for pacote: Pacote in get_tree().get_nodes_in_group("pacotes"):
		pacote.coletado.connect(_ao_coletar_pacote)
		pacote.devolvido.connect(_ao_devolver_pacote)

	var zonas := get_tree().get_nodes_in_group("zonas_entrega")
	_total_entregas = zonas.size()
	for zona: ZonaEntrega in zonas:
		zona.entrega_realizada.connect(_ao_entregar)
		zona.entrega_recusada.connect(_ao_entrega_recusada)

	jogo_terminou.connect(_ao_jogo_terminar)
	_hud.reiniciar_pressionado.connect(_reiniciar)
	_hud.menu_pressionado.connect(_ir_para_menu)
	_hud.pausa_solicitada.connect(_alternar_pausa)
	_hud.proximo_nivel_pressionado.connect(_avancar_nivel)
	_hud.atualizar_nivel(nome_nivel)

	_cronometro.wait_time = tempo_limite
	_cronometro.timeout.connect(_ao_tempo_esgotar)
	_cronometro.start()

	_hud.atualizar_entregas(0, _total_entregas)
	_hud.atualizar_dica(dica_inicial)
	_hud.definir_dicas_visiveis(mostrar_dicas)

func _process(_delta: float) -> void:
	_hud.atualizar_tempo(_cronometro.time_left)

func _ao_coletar_pacote(pacote: Pacote) -> void:
	Audio.tocar("coleta")
	if ocultar_dicas_apos_coleta:
		_hud.definir_dicas_visiveis(false)
	if pacote.destino == IdentidadeEntrega.Destino.LIVRE:
		_hud.atualizar_dica("Leve o pacote até uma casa iluminada!")
	else:
		_hud.atualizar_dica("Pacote coletado.")

func _ao_entrega_recusada(_zona: ZonaEntrega) -> void:
	_hud.atualizar_dica("Esta não é a casa deste pacote.")

func _ao_devolver_pacote(_pacote: Pacote) -> void:
	_hud.atualizar_dica("O pacote voltou à origem. Pegue-o novamente!")

func _alternar_pausa() -> void:
	if _partida_terminada:
		return
	var pausada := not get_tree().paused
	get_tree().paused = pausada
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if pausada else Input.MOUSE_MODE_CAPTURED
	_hud.mostrar_pausa(pausada)

func _ao_reaparecer() -> void:
	if _partida_terminada or vidas_iniciais == 0:
		return
	_vidas = maxi(0, _vidas - 1)
	_hud.atualizar_vidas(_vidas, true)
	if _vidas == 0:
		jogo_terminou.emit(false)

func _ao_entregar(_zona: ZonaEntrega) -> void:
	Audio.tocar("entrega")
	_entregas += 1
	_hud.atualizar_entregas(_entregas, _total_entregas)
	if _entregas >= _total_entregas:
		jogo_terminou.emit(true)
	else:
		_hud.atualizar_dica("Pegue outro pacote!")

func _ao_tempo_esgotar() -> void:
	jogo_terminou.emit(false)

func _ao_jogo_terminar(vitoria: bool) -> void:
	if _partida_terminada:
		return
	_partida_terminada = true
	_cronometro.stop()
	Audio.tocar("vitoria" if vitoria else "derrota")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_hud.mostrar_fim(vitoria, _entregas, _total_entregas, vidas_iniciais > 0 and _vidas == 0)
	_hud.permitir_proximo_nivel(vitoria and not proximo_nivel.is_empty())
	get_tree().paused = true

func _avancar_nivel() -> void:
	if not _partida_terminada or _entregas < _total_entregas or proximo_nivel.is_empty():
		return
	Audio.tocar("clique")
	get_tree().paused = false
	get_tree().change_scene_to_file(proximo_nivel)

func _reiniciar() -> void:
	Audio.tocar("clique")
	get_tree().paused = false
	get_tree().reload_current_scene()

func _ir_para_menu() -> void:
	Audio.tocar("clique")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
