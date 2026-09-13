class_name ZonaQueda
extends ZonaInterativa

func _ao_jogador_entrar(jogador: Jogador) -> void:
	Audio.tocar("queda")
	jogador.reaparecer()
