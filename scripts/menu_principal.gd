class_name MenuPrincipal
extends Control

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$Centro/Conteudo/BotaoJogar.pressed.connect(_abrir_cena.bind("res://scenes/jogo.tscn"))
	$Centro/Conteudo/BotaoNivel2.pressed.connect(_abrir_cena.bind("res://scenes/nivel_2.tscn"))
	$Centro/Conteudo/BotaoNivel3.pressed.connect(_abrir_cena.bind("res://scenes/nivel_3.tscn"))
	$Centro/Conteudo/BotaoNivel4.pressed.connect(_abrir_cena.bind("res://scenes/nivel_4.tscn"))
	$Centro/Conteudo/BotaoSair.pressed.connect(_ao_sair)

func _abrir_cena(caminho: String) -> void:
	Audio.tocar("clique")
	get_tree().change_scene_to_file(caminho)

func _ao_sair() -> void:
	get_tree().quit()
