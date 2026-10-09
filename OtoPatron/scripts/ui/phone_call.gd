class_name PhoneCall
extends RefCounted
static func present(incoming: bool, caller: String, subject: String, answer: Callable, decline: Callable, expires_at: float = 0.0) -> Control:
	var v := UI.dialog_card(Loc.t("phone_incoming" if incoming else "phone_outgoing"))
	v.add_child(CallPulse.new())
	v.add_child(UI.lbl(caller, 26, UI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER, true))
	v.add_child(UI.lbl(subject, 14, UI.C_MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	var status := UI.lbl(Loc.t("phone_wait"), 13, UI.C_ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
	v.add_child(status)
	var root := UI.show_dialog(v)
	var audio := AudioStreamPlayer.new()
	audio.stream = load("res://audio/ring.wav")
	audio.volume_db = linear_to_db(maxf(0.0001, float(Game.settings.get("sfx", 0.8))))
	root.add_child(audio)
	audio.play()
	var closed := [false]
	var finish := func(action: Callable):
		if closed[0]: return
		closed[0] = true
		audio.stop()
		root.queue_free()
		if action.is_valid(): action.call()
	var timer := Timer.new()
	timer.wait_time = 0.2
	root.add_child(timer)
	var started := Game.now_seconds()
	var last_ring := [started]
	timer.timeout.connect(func():
		if closed[0]: return
		var now := Game.now_seconds()
		if now-last_ring[0] >= 2.4:
			last_ring[0] = now
			audio.play()
			Fx.vibrate(35)
		if incoming and expires_at > 0:
			var remaining := maxi(0,int(ceil(expires_at-now)))
			status.text = Loc.t("phone_remaining", [remaining])
			if remaining <= 0: finish.call(decline)
		elif not incoming:
			status.text = Loc.t("phone_connecting") + " · " + str(int(now-started)) + "s"
			if now-started >= 2.4: finish.call(answer))
	timer.start()
	if incoming:
		var row := UI.hbox(v, 10)
		row.add_child(UI.btn_icon("phone", Loc.t("phone_answer"), "primary", func(): finish.call(answer), 54))
		row.add_child(UI.btn(Loc.t("phone_decline"), "danger", func(): finish.call(decline), 54))
	else:
		v.add_child(UI.btn(Loc.t("phone_cancel"), "ghost", func(): finish.call(decline), 50))
	return root
