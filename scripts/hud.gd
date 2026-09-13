class_name HUD
extends Control

signal reiniciar_pressionado
signal menu_pressionado
signal pausa_solicitada
signal proximo_nivel_pressionado

@onready var _rotulo_entregas: Label = $RotuloEntregas
@onready var _rotulo_tempo: Label = $RotuloTempo
@onready var _rotulo_nivel: Label = $RotuloNivel
@onready var _rotulo_dica: Label = $RotuloDica
@onready var _painel_fim: Control = $PainelFim
@onready var _rotulo_resultado: Label = $PainelFim/Centro/Caixa/Margem/Conteudo/RotuloResultado
@onready var _rotulo_detalhe: Label = $PainelFim/Centro/Caixa/Margem/Conteudo/RotuloDetalhe
@onready var _botao_continuar: Button = $PainelFim/Centro/Caixa/Margem/Conteudo/BotaoContinuar
@onready var _botao_proximo_nivel: Button = $PainelFim/Centro/Caixa/Margem/Conteudo/BotaoProximoNivel
@onready var _botao_reiniciar: Button = $PainelFim/Centro/Caixa/Margem/Conteudo/BotaoReiniciar
@onready var _botao_menu: Button = $PainelFim/Centro/Caixa/Margem/Conteudo/BotaoMenu

func _ready() -> void:
	_painel_fim.visible = false
	_botao_reiniciar.pressed.connect(_ao_reiniciar)
	_botao_menu.pressed.connect(_ao_menu)
	_botao_continuar.pressed.connect(_ao_continuar)
	_botao_proximo_nivel.pressed.connect(_ao_proximo_nivel)

func _ao_proximo_nivel() -> void:
	proximo_nivel_pressionado.emit()

func atualizar_nivel(nome: String) -> void:
	_rotulo_nivel.text = nome

func permitir_proximo_nivel(permitir: bool) -> void:
	_botao_proximo_nivel.visible = permitir
	if permitir:
		_botao_proximo_nivel.grab_focus()

func _input(evento: InputEvent) -> void:
	if evento.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		pausa_solicitada.emit()

func _ao_continuar() -> void:
	pausa_solicitada.emit()

func mostrar_pausa(pausada: bool) -> void:
	_painel_fim.visible = pausada
	_botao_continuar.visible = pausada
	if pausada:
		_rotulo_resultado.text = "PARTIDA PAUSADA"
		_rotulo_detalhe.text = "Pressione Esc ou Continuar para retomar."
		_botao_continuar.grab_focus()
	else:
		_botao_continuar.release_focus()

func atualizar_entregas(atual: int, total: int) -> void:
	_rotulo_entregas.text = "Entregas: %d/%d" % [atual, total]

func atualizar_tempo(segundos: float) -> void:
	var total := maxi(0, ceili(segundos))
	var minutos := floori(total / 60.0)
	_rotulo_tempo.text = "Tempo: %02d:%02d" % [minutos, total % 60]

func atualizar_vidas(vidas: int, mostrar: bool) -> void:
	$RotuloVidas.text = "Vidas: %d" % vidas
	$RotuloVidas.visible = mostrar

func atualizar_dica(texto: String) -> void:
	_rotulo_dica.text = texto

func definir_dicas_visiveis(visiveis: bool) -> void:
	_rotulo_dica.visible = visiveis

func mostrar_fim(vitoria: bool, entregas: int, total: int, sem_vidas: bool = false) -> void:
	_botao_continuar.hide()
	_painel_fim.visible = true
	if vitoria:
		_rotulo_resultado.text = "VOCÊ VENCEU!"
		_rotulo_detalhe.text = "Todas as %d entregas foram concluídas!" % total
	else:
		_rotulo_resultado.text = "SEM VIDAS!" if sem_vidas else "TEMPO ESGOTADO!"
		_rotulo_detalhe.text = "Você entregou %d de %d pacotes." % [entregas, total]

func _ao_reiniciar() -> void:
	reiniciar_pressionado.emit()

func _ao_menu() -> void:
	menu_pressionado.emit()
