extends Node


const SAMPLE_RATE := 44100
const XP_VOLUME_DB := -14.0
const LEVEL_VOLUME_DB := -9.0
const MELODY_RESET_MILLISECONDS := 10000
const MELODY_FREQUENCIES: Array[float] = [
	523.25,
	587.33,
	659.25,
	783.99,
	880.00,
	783.99,
	659.25,
	587.33
]


var _feedback_player: AudioStreamPlayer
var _melody_index: int = 0
var _last_note_milliseconds: int = 0


func _ready() -> void:
	_feedback_player = AudioStreamPlayer.new()
	_feedback_player.name = "FeedbackPlayer"
	add_child(_feedback_player)


func play_xp_gained(skill_id: String = "") -> void:
	var now_milliseconds: int = Time.get_ticks_msec()
	if (
		_last_note_milliseconds <= 0
		or now_milliseconds - _last_note_milliseconds
		> MELODY_RESET_MILLISECONDS
	):
		_melody_index = 0

	var frequency: float = MELODY_FREQUENCIES[_melody_index]
	_melody_index = (_melody_index + 1) % MELODY_FREQUENCIES.size()
	_last_note_milliseconds = now_milliseconds

	_play_feedback(
		_build_natural_note(skill_id, frequency, 0.16),
		XP_VOLUME_DB
	)


func play_level_up(skill_id: String = "") -> void:
	var notes: Array[float] = [
		MELODY_FREQUENCIES[_melody_index],
		MELODY_FREQUENCIES[(_melody_index + 2) % MELODY_FREQUENCIES.size()],
		MELODY_FREQUENCIES[(_melody_index + 4) % MELODY_FREQUENCIES.size()],
		1046.50
	]
	var samples := PackedFloat32Array()

	for note_index: int in range(notes.size()):
		var duration := 0.14 if note_index < notes.size() - 1 else 0.28
		_append_natural_tone(
			samples,
			skill_id,
			notes[note_index],
			duration,
			true
		)
		_append_silence(samples, 0.025)

	_melody_index = 0
	_last_note_milliseconds = Time.get_ticks_msec()
	_play_feedback(_samples_to_stream(samples), LEVEL_VOLUME_DB)


func _play_feedback(stream: AudioStreamWAV, volume_db: float) -> void:
	if _feedback_player == null or stream == null:
		return

	_feedback_player.stop()
	_feedback_player.stream = stream
	_feedback_player.volume_db = volume_db
	_feedback_player.play()


func _build_natural_note(
	skill_id: String,
	frequency: float,
	duration: float
) -> AudioStreamWAV:
	var samples := PackedFloat32Array()
	_append_natural_tone(samples, skill_id, frequency, duration, false)
	return _samples_to_stream(samples)


func _append_natural_tone(
	samples: PackedFloat32Array,
	skill_id: String,
	frequency: float,
	duration: float,
	is_flourish: bool
) -> void:
	match skill_id:
		"strength":
			_append_drum(samples, frequency, duration, is_flourish)
		"crafting":
			_append_stone_clack(samples, frequency, duration, is_flourish)
		"gathering":
			_append_wood_knock(samples, frequency, duration, is_flourish)
		_:
			_append_bird_chirp(samples, frequency, duration, is_flourish)


func _append_bird_chirp(
	samples: PackedFloat32Array,
	frequency: float,
	duration: float,
	is_flourish: bool
) -> void:
	var sample_count: int = maxi(int(duration * SAMPLE_RATE), 1)
	var phase := 0.0
	for sample_index: int in range(sample_count):
		var progress: float = float(sample_index) / float(sample_count)
		var pulse: float = sin(progress * PI * (3.0 if is_flourish else 2.0))
		var envelope: float = sin(progress * PI) * clampf(pulse * 1.4, 0.2, 1.0)
		var glide: float = lerpf(0.88, 1.12, progress)
		phase += TAU * frequency * glide / float(SAMPLE_RATE)
		var tone: float = sin(phase) + sin(phase * 2.0) * 0.18
		samples.append(tone * envelope * 0.28)


func _append_wood_knock(
	samples: PackedFloat32Array,
	frequency: float,
	duration: float,
	is_flourish: bool
) -> void:
	var sample_count: int = maxi(int(duration * SAMPLE_RATE), 1)
	var resonance: float = frequency * 0.72
	for sample_index: int in range(sample_count):
		var time_seconds: float = float(sample_index) / float(SAMPLE_RATE)
		var envelope: float = exp(-time_seconds * (20.0 if is_flourish else 25.0))
		var knock: float = sin(TAU * resonance * time_seconds)
		knock += sin(TAU * resonance * 1.47 * time_seconds) * 0.42
		var noise: float = _deterministic_noise(sample_index) * exp(-time_seconds * 65.0)
		samples.append((knock * 0.30 + noise * 0.16) * envelope)


func _append_stone_clack(
	samples: PackedFloat32Array,
	frequency: float,
	duration: float,
	is_flourish: bool
) -> void:
	var sample_count: int = maxi(int(duration * SAMPLE_RATE), 1)
	for sample_index: int in range(sample_count):
		var time_seconds: float = float(sample_index) / float(SAMPLE_RATE)
		var envelope: float = exp(-time_seconds * (24.0 if is_flourish else 31.0))
		var clack: float = sin(TAU * frequency * 1.35 * time_seconds)
		clack += sin(TAU * frequency * 2.11 * time_seconds) * 0.48
		clack += _deterministic_noise(sample_index + 37) * exp(-time_seconds * 85.0) * 0.35
		samples.append(clack * envelope * 0.24)


func _append_drum(
	samples: PackedFloat32Array,
	frequency: float,
	duration: float,
	is_flourish: bool
) -> void:
	var sample_count: int = maxi(int(duration * SAMPLE_RATE), 1)
	var base_frequency: float = frequency * 0.20
	var phase := 0.0
	for sample_index: int in range(sample_count):
		var time_seconds: float = float(sample_index) / float(SAMPLE_RATE)
		var progress: float = float(sample_index) / float(sample_count)
		var pitch_drop: float = lerpf(1.65, 0.92, sqrt(progress))
		phase += TAU * base_frequency * pitch_drop / float(SAMPLE_RATE)
		var envelope: float = exp(-time_seconds * (8.0 if is_flourish else 11.0))
		var attack: float = _deterministic_noise(sample_index + 79) * exp(-time_seconds * 75.0)
		samples.append((sin(phase) * 0.42 + attack * 0.12) * envelope)


func _deterministic_noise(sample_index: int) -> float:
	var raw_value: float = sin(float(sample_index * 91 + 17) * 12.9898) * 43758.5453
	return (raw_value - floor(raw_value)) * 2.0 - 1.0


func _samples_to_stream(samples: PackedFloat32Array) -> AudioStreamWAV:
	var data := PackedByteArray()
	data.resize(samples.size() * 2)

	for sample_index: int in range(samples.size()):
		var sample_value: int = int(
			clampf(samples[sample_index], -1.0, 1.0) * 32767.0
		)
		data[sample_index * 2] = sample_value & 0xff
		data[sample_index * 2 + 1] = (sample_value >> 8) & 0xff

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = data
	return stream


func _append_silence(
	samples: PackedFloat32Array,
	duration: float
) -> void:
	var sample_count: int = maxi(int(duration * SAMPLE_RATE), 0)
	for _sample_index: int in range(sample_count):
		samples.append(0.0)
