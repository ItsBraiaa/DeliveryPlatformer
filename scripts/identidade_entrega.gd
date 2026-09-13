class_name IdentidadeEntrega
extends RefCounted

enum Destino { LIVRE, VERMELHO, AZUL, AMARELO, VERDE, ROXO }

const CORES: Array[Color] = [
	Color(0.85, 0.6, 0.3), Color(0.9, 0.12, 0.13),
	Color(0.12, 0.35, 0.9), Color(1.0, 0.72, 0.08),
	Color(0.12, 0.65, 0.26), Color(0.6, 0.18, 0.82),
]

static func cor(destino: Destino) -> Color:
	return CORES[destino]

static func material(destino: Destino) -> StandardMaterial3D:
	var resultado := StandardMaterial3D.new()
	resultado.albedo_color = cor(destino)
	return resultado
