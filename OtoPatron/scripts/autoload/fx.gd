extends Node
## Ses efektleri, arka plan mÃ¼ziÄŸi ve titreÅŸim.

const SFX: Array = ["click", "coin", "success", "error", "levelup", "notify", "ring", "crate", "msg_in", "msg_out", "sale", "customer", "repair"]

var _streams: Dictionary = {}
var _players: Array = []
var _next: int = 0
var _music: AudioStreamPlayer
var _visibility_timer: float = 0.0
var _music_started: bool = false

func _exit_tree() -> void:
	if is_instance_valid(_music):
		_music.stop()
		_music.stream = null
	for player in _players:
		if is_instance_valid(player):
			player.stop()
			player.stream = null
	_streams.clear()
	_players.clear()


func _ready() -> void:
	for n in SFX:
		var p := "res://audio/%s.wav" % n
		if ResourceLoader.exists(p):
			_streams[n] = load(p)
	for i in 6:
		var pl := AudioStreamPlayer.new()
		add_child(pl)
		_players.append(pl)
	_music = AudioStreamPlayer.new()
	add_child(_music)
	var mp := "res://audio/ambient.wav"
	if not OS.has_feature("web") and ResourceLoader.exists(mp):
		var s: AudioStreamWAV = load(mp)
		s.loop_mode = AudioStreamWAV.LOOP_FORWARD
		s.loop_begin = 0
		s.loop_end = int(round(s.get_length() * s.mix_rate))
		_music.stream = s
	apply_volumes()


func start_music() -> void:
	_music_started = true
	if OS.has_feature("web"): JavaScriptBridge.eval("window.otoMusic?.start()", true)
	apply_volumes()


func apply_volumes() -> void:
	var mv: float = float(Game.settings.get("music", 0.6))
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.otoMusic?.volume(" + str(mv) + ")", true)
		if Game._web_hidden:
			for player in _players: player.stop()
		return
	_music.volume_db = linear_to_db(maxf(mv * 0.55, 0.0001))
	if mv <= 0.01 or Game._web_hidden:
		_music.stop()
		if Game._web_hidden:
			for player in _players: player.stop()
		return
	_music.stream_paused = false
	if _music_started and _music.stream and not _music.playing: _music.play()


func play(name: String) -> void:
	var sv: float = float(Game.settings.get("sfx", 0.8))
	if Game._web_hidden or sv <= 0.01 or not _streams.has(name):
		return
	var pl: AudioStreamPlayer = _players[_next]
	_next = (_next + 1) % _players.size()
	pl.stream = _streams[name]
	pl.volume_db = linear_to_db(sv)
	pl.play()


func vibrate(ms: int = 30) -> void:
	if not bool(Game.settings.get("vibe", true)):
		return
	if OS.has_feature("mobile") or OS.get_name() == "Android" or OS.get_name() == "iOS":
		Input.vibrate_handheld(ms)

func _process(dt: float) -> void:
	_visibility_timer += dt
	if _visibility_timer < 0.5: return
	_visibility_timer = 0.0
	apply_volumes()
