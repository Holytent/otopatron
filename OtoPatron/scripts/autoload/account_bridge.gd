extends Node
var _callback: JavaScriptObject
var _update_callback: JavaScriptObject
var _opening_shown: bool = false

func show_opening() -> void:
	if _opening_shown: return
	_opening_shown = true
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.otoAccount?.start()", true)
	else:
		ReleaseInfo.show_if_new.call_deferred()

func _ready() -> void:
	if OS.has_feature("web"):
		_update_callback = JavaScriptBridge.create_callback(_update)
		JavaScriptBridge.eval("window.otoUpdates = {}", true)
		var updates: JavaScriptObject = JavaScriptBridge.get_interface("otoUpdates")
		updates.save = _update_callback
		_callback = JavaScriptBridge.create_callback(_receive)
		var api: JavaScriptObject = JavaScriptBridge.get_interface("otoAccount")
		if api != null: api.bind(_callback)

func open() -> void:
	if OS.has_feature("web"): JavaScriptBridge.eval("window.otoAccount?.open()", true)
	else: Game.toast(Loc.t("account_web"))

func queue_save(snapshot: Dictionary) -> void:
	if not OS.has_feature("web"): return
	var api: JavaScriptObject = JavaScriptBridge.get_interface("otoAccount")
	if api != null: api.queue(JSON.stringify(snapshot))

func _receive(args: Array) -> void:
	if args.is_empty(): return
	var result: Variant = JSON.parse_string(str(args[0]))
	if not result is Dictionary: return
	match str(result.get("type", "")):
		"gate_done": ReleaseInfo.show_if_new.call_deferred()
		"load":
			var snapshot: Variant = result.get("snapshot", {})
			if not snapshot is Dictionary or not Game.valid_snapshot(snapshot):
				Game.toast(Loc.t("no_save"),"bad")
				return
			# Preserve the device save separately before applying the account snapshot.
			if Game.has_save(): DirAccess.copy_absolute(Game.save_path(), Game.save_path() + ".device_backup")
			Game.from_dict(snapshot)
			Game.save_game()
			Game.changed.emit()
			Game.go("home")
		"save_request":
			if Game.started: queue_save(Game.to_dict())
		"notice": Game.toast(str(result.get("message", "")), "info")

func _update(_args: Array) -> void:
	Game.save_game()
	JavaScriptBridge.eval("Promise.race([Promise.resolve(window.otoAccount?.flush()),new Promise(r=>setTimeout(r,15000))]).finally(()=>location.reload())", true)
