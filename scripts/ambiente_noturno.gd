class_name AmbienteNoturno
extends AudioStreamPlayer

func _ready() -> void:
	var taxa := 11025
	var quantidade := taxa * 8
	var dados := PackedByteArray()
	dados.resize(quantidade * 2)
	var aleatorio := RandomNumberGenerator.new()
	aleatorio.seed = 4317
	var vento := 0.0
	for i in range(quantidade):
		vento = lerpf(vento, aleatorio.randf_range(-1.0, 1.0), 0.025)
		var fase := float(i) / quantidade
		var envelope := minf(1.0, minf(i / 600.0, (quantidade - 1 - i) / 600.0))
		var amostra := vento * (0.7 + 0.2 * sin(TAU * fase)) * envelope
		dados.encode_s16(i * 2, int(clampf(amostra, -1.0, 1.0) * 32767))
	var som := AudioStreamWAV.new()
	som.format = AudioStreamWAV.FORMAT_16_BITS
	som.mix_rate = taxa
	som.data = dados
	som.loop_mode = AudioStreamWAV.LOOP_FORWARD
	som.loop_end = quantidade
	stream = som
	volume_db = -22.0
	play()
