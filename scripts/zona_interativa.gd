class_name ZonaInterativa
extends Area3D

func _ready() -> void:
	body_entered.connect(_ao_corpo_entrar)

func _ao_corpo_entrar(corpo: Node3D) -> void:
	if corpo is Jogador:
		_ao_jogador_entrar(corpo as Jogador)

func _ao_jogador_entrar(_jogador: Jogador) -> void:
	pass
