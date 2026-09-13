extends Node

const CAMINHOS: Dictionary[String, String] = {
	"pulo": "res://audio/pulo.wav",
	"coleta": "res://audio/coleta.wav",
	"entrega": "res://audio/entrega.wav",
	"vitoria": "res://audio/vitoria.wav",
	"derrota": "res://audio/derrota.wav",
	"queda": "res://audio/queda.wav",
	"clique": "res://audio/clique.wav",
}

var _tocadores: Dictionary[String, AudioStreamPlayer] = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for nome: String in CAMINHOS:
		var tocador := AudioStreamPlayer.new()
		tocador.stream = load(CAMINHOS[nome])
		add_child(tocador)
		_tocadores[nome] = tocador

func tocar(nome: String) -> void:
	if _tocadores.has(nome):
		_tocadores[nome].play()
	else:
		push_warning("Som desconhecido: %s" % nome)
