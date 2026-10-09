extends ScreenBase
## Ayarlar: dil, müzik/efekt/titreşim, konum ve yapımcı adları.


func _build() -> void:
	var back: String = str(params.get("from", "management")) if Game.started and str(params.get("from", "management")) != "splash" else "splash"
	UI.header(self, Loc.t("settings_title"), back)
	var sc := UI.scroll_area(self)
	var appearance := UI.add_card(sc)
	appearance.add_child(UI.lbl(Loc.t("appearance"), 18, UI.C_ACCENT, -1, true))
	var modes := UI.hbox(appearance, 8)
	for night in [false, true]:
		var value: bool = night
		modes.add_child(UI.btn(Loc.t("theme_dark" if night else "theme_light"), "chipon" if bool(Game.settings.get("dark_mode", false)) == night else "chip", func():
			Game.settings["dark_mode"] = value
			Game.save_settings()
			Game.theme_changed.emit(), 48))
	appearance.add_child(UI.btn(Loc.t("street_modes") + " · " + Loc.t("on" if bool(Game.settings.get("street_events", true)) else "off"), "chip", func():
		Game.settings["street_events"] = not bool(Game.settings.get("street_events", true))
		Game.save_settings()
		rebuild(), 44))
	sc.add_child(UI.btn_icon("user", Loc.t("account_title"), "ghost", func(): AccountBridge.open(), 48))
	var notifications := UI.add_card(sc)
	notifications.add_child(UI.lbl(Loc.t("push_title"), 18, UI.C_ACCENT, -1, true))
	notifications.add_child(UI.lbl(Loc.t("push_hint"), 13, UI.C_MUTED))
	notifications.add_child(UI.btn(Loc.t("push_setup"), "ghost", func():
		if OS.has_feature("web"):
			JavaScriptBridge.eval("window.otoPush?.openSettings()", true)
		else:
			Game.toast(Loc.t("push_web_only")), 48))
	# Dil
	var lc := UI.add_card(sc)
	lc.add_child(UI.lbl(Loc.t("language"), 18, UI.C_ACCENT, -1, true))
	var g := GridContainer.new()
	g.columns = 2
	g.add_theme_constant_override("h_separation", 8)
	g.add_theme_constant_override("v_separation", 8)
	g.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lc.add_child(g)
	for code in Loc.LANGS.keys():
		var cd: String = code
		g.add_child(UI.btn(str(Loc.LANGS[cd]), "chipon" if Loc.lang == cd else "chip", func():
			Game.settings["lang"] = cd
			Game.save_settings()
			Loc.set_lang(cd)
			Fx.play("click"), 50))
	# Ses
	var ac := UI.add_card(sc)
	ac.add_child(UI.lbl(Loc.t("sound"), 18, UI.C_ACCENT, -1, true))
	_slider(ac, Loc.t("music"), "music")
	_slider(ac, Loc.t("sfx"), "sfx")
	var vib: bool = bool(Game.settings.get("vibe", true))
	ac.add_child(UI.btn(Loc.t("vibration") + ": " + Loc.t("on" if vib else "off"), "chipon" if vib else "chip", func():
		Game.settings["vibe"] = not bool(Game.settings.get("vibe", true))
		Game.save_settings()
		if bool(Game.settings["vibe"]):
			Fx.vibrate(60)
		rebuild(), 50))
	# Şehir
	if Game.started:
		var sv := UI.add_card(sc)
		sv.add_child(UI.lbl(Loc.t("save_load"), 18, UI.C_ACCENT, -1, true))
		var sr := UI.hbox(sv, 8)
		sr.add_child(UI.btn_icon("save", Loc.t("btn_save"), "chip", func():
			Game.save_game()
			Fx.play("success")
			Game.toast(Loc.t("saved"), "good"), 50))
		sr.add_child(UI.btn_icon("play", Loc.t("btn_load"), "chip", func():
			if Game.load_game():
				Fx.play("success")
				Game.toast(Loc.t("loaded"), "good")
			else:
				Game.toast(Loc.t("no_save"), "bad"), 50))
		sv.add_child(UI.btn("%s" % Loc.t("btn_main_menu"), "ghost", func():
			Game.save_game()
			Game.go("splash"), 48))
		var rc := UI.add_card(sc)
		rc.add_child(UI.btn(Loc.t("btn_reset"), "danger", _confirm_reset, 48))
	# Yapımcılar
	UI.spacer(sc, 10)
	sc.add_child(UI.lbl(Loc.t("credits"), 13, UI.C_MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	sc.add_child(UI.lbl("Ramazan ÖZKESKİN – Sudenur GÜVEZ", 17, UI.C_GOLD, HORIZONTAL_ALIGNMENT_CENTER, true))
	sc.add_child(UI.lbl("OtoPatron — Galeri Simülatörü  v%s" % ReleaseInfo.VERSION, 12, UI.C_MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	sc.add_child(UI.btn(Loc.t("release_notes"), "ghost", func(): ReleaseInfo.show_notes(), 46))
	UI.spacer(sc, 8)


func _slider(parent: Node, title: String, key: String) -> void:
	parent.add_child(UI.lbl(title, 14, UI.C_MUTED))
	var s := HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.05
	s.value = float(Game.settings.get(key, 0.6))
	s.custom_minimum_size = Vector2(0, 36)
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.value_changed.connect(func(v: float):
		Game.settings[key] = v
		Game.save_settings()
		Fx.apply_volumes())
	s.drag_ended.connect(func(_changed: bool):
		if key == "sfx":
			Fx.play("coin"))
	parent.add_child(s)


func _confirm_reset() -> void:
	var v := UI.dialog_card(Loc.t("btn_reset"))
	v.add_child(UI.lbl(Loc.t("reset_confirm"), 16, UI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER))
	var root := UI.show_dialog(v)
	var r := UI.hbox(v, 10)
	r.add_child(UI.btn(Loc.t("cancel"), "ghost", func(): root.queue_free()))
	r.add_child(UI.btn(Loc.t("ok"), "danger", func():
		Game.delete_save()
		Game.started = false
		root.queue_free()
		Game.go("splash")))
